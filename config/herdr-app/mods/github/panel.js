import { div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, TextView } from "gpui-base";
import { spaces, panes, focused, exec, theme, nextCommand, openOverlay } from "herdr";
import { summarizeChecks, checksIcon } from "./checks.js";
import { openUrl } from "./open.js";
import { detailArgs, detailMarkdown } from "./detail.js";
import { kindsFor, AUTO_REFRESH_MS } from "./schedule.js";

const LIMIT = "50";
const KINDS = {
  prs: { label: "PRs", args: ["pr", "list", "--state", "open", "--limit", LIMIT, "--json", "number,title,author,url,isDraft,createdAt,updatedAt,reviewDecision,headRefName,labels,statusCheckRollup"] },
  issues: { label: "Issues", args: ["issue", "list", "--state", "open", "--limit", LIMIT, "--json", "number,title,author,url,labels,createdAt,updatedAt"] },
};
// Sorted by GitHub's search, so "Oldest" reaches past the newest 50.
const SORTS = [
  { id: "created-desc", label: "Newest", date: "createdAt" },
  { id: "created-asc", label: "Oldest", date: "createdAt" },
  { id: "updated-desc", label: "Updated", date: "updatedAt" },
];

function location() {
  const space = spaces().find((s) => s.active), f = focused();
  const pane = f?.pane ? panes().find(p => p.pane === f.pane) : null;
  const on = f?.pane === null ? (f.terminal?.includes("/") ? f.terminal.split("/")[0] : null) : space?.machine ?? null;
  return { cwd: pane?.cwd || f?.cwd || space?.folder, on };
}
const key = () => JSON.stringify(location());

function ago(iso) {
  const minutes = Math.max(0, Math.round((Date.now() - Date.parse(iso)) / 60000));
  if (minutes < 60) return `${minutes}m`;
  if (minutes < 1440) return `${Math.round(minutes / 60)}h`;
  return `${Math.round(minutes / 1440)}d`;
}

function reviewBadge(pr, t) {
  if (pr.isDraft) return { text: "draft", color: t.dim };
  if (pr.reviewDecision === "APPROVED") return { text: "approved", color: t.ansi2 };
  if (pr.reviewDecision === "CHANGES_REQUESTED") return { text: "changes", color: t.ansi1 };
  return { text: "review", color: t.blocked };
}

function friendlyError(output) {
  if (/not a git repository/i.test(output)) return "Not a git repository";
  if (/no git remotes|none of the git remotes/i.test(output)) return "No GitHub remote in this repo";
  if (/gh auth login|not logged/i.test(output)) return "Run gh auth login first";
  return output.trim().split("\n")[0];
}

async function gh(args, cwd, on) {
  const r = await exec("gh", args, { cwd, on });
  if (r.code !== 0) throw new Error(friendlyError(r.stderr || r.stdout));
  return JSON.parse(r.stdout);
}

function listArgs(kind, filters) {
  const search = [`sort:${filters.sort.id}`, filters.text].filter(Boolean).join(" ");
  return [...KINDS[kind].args, "--search", search, ...[...filters.labels].flatMap((l) => ["--label", l])];
}

// The PRs and issues panel (also the cmd-shift-g popup).
export class Panel {
  init(_props, cx) {
    this.tab = "prs"; this.items = { prs: [], issues: [] }; this.repoLabels = []; this.generation = 0;
    this.filters = { sort: SORTS[0], labels: new Set(), text: "" };
    this.search = InputState.new({ placeholder: "Search, then Enter" });
    this.search.on("submit", (_e, cx) => this.setText(this.search.value().trim(), cx));
    this.search.on("change", (_e, cx) => { if (!this.search.value().trim() && this.filters.text) this.setText("", cx); });
    this.refresh(cx);
    cx.timer.every(AUTO_REFRESH_MS, (cx) => this.refresh(cx, "timer"));
    this.listenCommands(cx);
  }

  listenCommands(cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command in KINDS) this.tab = command;
        if (command === "refresh") this.refresh(cx);
        if (command === "sort") this.cycleSort(cx);
        if (command === "labels") this.showLabels = !this.showLabels;
        cx.notify();
      }
    });
  }

  refresh(cx, reason = "manual") {
    const { cwd, on } = location(), context = key();
    if (context !== this.context) this.resetFor(context, cwd, on, cx);
    if (!cwd) return;
    const generation = ++this.generation, filters = this.filters;
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const kinds = kindsFor(reason);
        const lists = await Promise.all(kinds.map((kind) => gh(listArgs(kind, filters), cwd, on)));
        if (generation === this.generation) { this.items = { ...this.items, ...Object.fromEntries(kinds.map((k, i) => [k, lists[i]])) }; this.error = null; }
      } catch (e) { if (generation === this.generation) this.error = String(e.message ?? e); }
      finally { if (generation === this.generation) this.loading = false; cx.notify(); }
    });
    cx.notify();
  }

  // A new repo: its own labels, and filters on labels it may not have are dropped.
  resetFor(context, cwd, on, cx) {
    this.context = context; this.items = { prs: [], issues: [] }; this.error = null; this.repoLabels = []; this.detail = null;
    this.filters = { ...this.filters, labels: new Set() };
    if (!cwd) return;
    cx.spawn(async (cx) => {
      try {
        const labels = await gh(["label", "list", "--limit", "200", "--json", "name,color"], cwd, on);
        if (key() === context) this.repoLabels = labels;
      } catch { if (key() === context) this.repoLabels = []; }
      cx.notify();
    });
  }

  setFilters(change, cx) {
    this.filters = { ...this.filters, ...change };
    this.refresh(cx);
  }

  setText(text, cx) {
    if (text !== this.filters.text) this.setFilters({ text }, cx);
  }

  cycleSort(cx) {
    const next = SORTS[(SORTS.indexOf(this.filters.sort) + 1) % SORTS.length];
    this.setFilters({ sort: next }, cx);
  }

  toggleLabel(name, cx) {
    const labels = new Set(this.filters.labels);
    if (labels.has(name)) labels.delete(name); else labels.add(name);
    this.setFilters({ labels }, cx);
  }

  clearFilters(cx) {
    this.search.set_value("");
    this.setFilters({ sort: SORTS[0], labels: new Set(), text: "" }, cx);
  }

  hasFilters() {
    return this.filters.sort !== SORTS[0] || this.filters.labels.size > 0 || Boolean(this.filters.text);
  }

  tabButton(kind, t) {
    const active = this.tab === kind, count = this.items[kind].length;
    return h_flex().id(`gh-tab-${kind}`).h(26).px(10).gap(6).items_center().rounded(7).cursor_pointer()
      .when(active, (e) => e.bg(t.selected)).hover((s) => s.bg(t.hover))
      .on_click((_e, cx) => { this.tab = kind; cx.notify(); })
      .child(div().text_color(active ? t.foreground : t.muted).child(KINDS[kind].label))
      .child(div().text_size(10).text_color(t.dim).child(String(count)));
  }

  filterChip(id, label, active, onClick, t) {
    return h_flex().id(id).h(24).px(8).gap(4).flex_none().items_center().rounded(6).cursor_pointer().text_size(11)
      .bg(active ? t.selected : t.raised).text_color(active ? t.foreground : t.muted)
      .hover((s) => s.bg(t.hover)).on_click((_e, cx) => onClick(cx)).child(label);
  }

  filterBar(t) {
    const count = this.filters.labels.size;
    return h_flex().h(38).flex_none().px(8).gap(6).items_center().border_b(1).border_color(t.border)
      .child(this.filterChip("gh-sort", `${this.filters.sort.label} ↕`, this.filters.sort !== SORTS[0], (cx) => this.cycleSort(cx), t))
      .child(this.filterChip("gh-labels", count ? `Labels · ${count}` : "Labels", count > 0 || this.showLabels,
        (cx) => { this.showLabels = !this.showLabels; cx.notify(); }, t))
      .child(div().flex_1().min_w(0).h(24).px(8).flex().items_center().rounded(6).border_1()
        .border_color(this.filters.text ? t.accent : t.border).bg(t.background)
        .child(Input.new(this.search).h_full().text_size(11).text_color(t.foreground)))
      .when(this.hasFilters(), (e) => e.child(this.filterChip("gh-clear", "Clear", false, (cx) => this.clearFilters(cx), t)));
  }

  labelPicker(t) {
    const picked = this.filters.labels;
    return v_flex().id("gh-label-picker").flex_none().max_h(132).overflow_y_scrollbar().p(8).border_b(1).border_color(t.border)
      .child(h_flex().flex_wrap().gap(5).children(this.repoLabels.map((l) => {
        const on = picked.has(l.name);
        return div().id(`gh-label-${l.name}`).px(6).h(20).flex().items_center().rounded(5).cursor_pointer().text_size(11)
          .border_1().border_color(`#${l.color}${on ? "" : "88"}`).bg(on ? `#${l.color}44` : t.background)
          .text_color(on ? t.foreground : t.muted).hover((s) => s.bg(`#${l.color}22`))
          .on_click((_e, cx) => this.toggleLabel(l.name, cx)).child(l.name);
      })))
      .when(!this.repoLabels.length, (e) => e.child(div().text_size(11).text_color(t.dim).child("No labels in this repo")));
  }

  prMeta(pr, t) {
    const badge = reviewBadge(pr, t), ci = checksIcon(summarizeChecks(pr.statusCheckRollup).state, t);
    return h_flex().gap(8).text_size(11).text_color(t.dim)
      .when(Boolean(ci), (e) => e.child(div().text_color(ci.color).child(ci.text)))
      .child(div().text_color(badge.color).child(badge.text))
      .child(div().min_w(0).truncate().child(pr.headRefName));
  }

  issueMeta(issue, t) {
    return h_flex().gap(6).text_size(11).text_color(t.dim).min_w(0).overflow_hidden()
      .children(issue.labels.slice(0, 3).map((l) => div().px(5).rounded(4).border_1().border_color(`#${l.color}88`).text_color(t.muted).child(l.name)));
  }

  startAgent(issue) {
    const { cwd, on } = location();
    openOverlay({ mod: "issue-agent", kind: "dialog", width: 480, height: 620, props: { issue, cwd, on } });
  }

  agentButton(issue, t) {
    return div().id(`gh-agent-${issue.number}`).flex_none().px(7).h(20).flex().items_center().rounded(6)
      .text_size(11).text_color(t.muted).border_1().border_color(t.border).hover((s) => s.bg(t.raised).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); this.startAgent(issue); }).child("Agent");
  }

  row(item, t) {
    const meta = this.tab === "prs" ? this.prMeta(item, t) : this.issueMeta(item, t);
    const date = item[this.filters.sort.date] ?? item.updatedAt;
    return v_flex().id(`gh-${this.tab}-${item.number}`).flex_none().px(10).py(7).gap(3).rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((e, cx) => (e.modifiers?.shift ? openUrl(item.url) : this.openDetail(item, cx)))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_none().text_size(11).text_color(t.accent).child(`#${item.number}`))
        .child(div().flex_1().min_w(0).truncate().child(item.title))
        .when(this.tab === "issues", (e) => e.child(this.agentButton(item, t))))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_1().min_w(0).child(meta))
        .child(div().flex_none().text_size(11).text_color(t.dim).child(`${item.author?.login ?? ""} · ${ago(date)}`)));
  }

  // Click reads it here; shift+click (or "Open") goes to the browser.
  openDetail(item, cx) {
    const { cwd, on } = location(), kind = this.tab;
    const detail = this.detail = { kind, item, loading: true };
    cx.spawn(async (cx) => {
      try { detail.item = await gh(detailArgs(kind, item.number), cwd, on); }
      catch (e) { detail.error = String(e.message ?? e); }
      finally { detail.loading = false; cx.notify(); }
    });
    cx.notify();
  }

  detailView(t) {
    const { item, loading, error } = this.detail;
    const link = (id, label, onClick) => div().id(id).px(8).h(26).flex().items_center().rounded(7).cursor_pointer()
      .text_size(11).text_color(t.muted).hover((s) => s.bg(t.hover)).on_click(onClick).child(label);
    const body = error ? div().p(8).text_color(t.ansi1).child(error)
      : loading ? div().p(8).text_color(t.dim).child("Loading…")
      : TextView.markdown(`gh-detail-${item.number}`, detailMarkdown(item)).selectable().scrollable().on_link_click((url) => openUrl(url));
    return v_flex().flex_1().min_h(0)
      .child(h_flex().h(42).flex_none().px(10).gap(4).items_center().border_b(1).border_color(t.border)
        .child(link("gh-back", "← Back", (_e, cx) => { this.detail = null; cx.notify(); }))
        .child(div().flex_1())
        .child(link("gh-open", "Open ↗", () => openUrl(item.url))))
      .child(v_flex().flex_none().px(12).pt(10).pb(8).gap(3).border_b(1).border_color(t.border)
        .child(h_flex().gap(8).child(div().flex_none().text_color(t.accent).child(`#${item.number}`)).child(div().min_w(0).child(item.title)))
        .child(div().text_size(11).text_color(t.dim).child([item.author?.login, item.headRefName, item.state?.toLowerCase()].filter(Boolean).join(" · "))))
      .child(div().flex_1().min_h(0).p(12).child(body));
  }

  emptyText() {
    if (this.error) return this.error;
    if (this.loading) return "Loading…";
    const what = this.tab === "prs" ? "pull requests" : "issues";
    return this.hasFilters() ? `No open ${what} match these filters` : `No open ${what}`;
  }

  render(cx) {
    if (key() !== this.context) this.refresh(cx);
    const t = theme(), list = this.items[this.tab];
    if (this.detail) return v_flex().id("github").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13).child(this.detailView(t));
    return v_flex().id("github").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(10).gap(4).items_center().border_b(1).border_color(t.border)
        .child(this.tabButton("prs", t)).child(this.tabButton("issues", t)).child(div().flex_1())
        .child(div().id("gh-refresh").px(8).h(26).flex().items_center().rounded(7).cursor_pointer().text_size(11).text_color(t.muted)
          .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.refresh(cx)).child(this.loading ? "…" : "Refresh")))
      .child(this.filterBar(t))
      .when(Boolean(this.showLabels), (e) => e.child(this.labelPicker(t)))
      .child(v_flex().id("github-list").flex_1().min_h(0).overflow_y_scrollbar().p(6).gap(2)
        .children(list.map((item) => this.row(item, t)))
        .when(!list.length, (e) => e.child(div().p(8).text_color(this.error ? t.ansi1 : t.dim).child(this.emptyText()))));
  }
}
