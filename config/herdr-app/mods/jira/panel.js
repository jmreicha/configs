import { div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, TextView } from "gpui-base";
import { exec, home, theme, nextCommand } from "herdr";
import { openUrl } from "./open.js";
import { adfToMarkdown } from "./adf.js";
import { SEARCH_ARGS, parentArgs, parentOf, mapLimit, viewArgs, childArgs, prSearchArgs, projectOf, groupByProject, matches, siteFrom, browseUrl, relatedPrs, detailRows, linkedWork, prTone, ago, byStatus, isOpen } from "./jira.js";

function friendlyError(output) {
  if (/unauthorized|auth login/i.test(output)) return "Run acli jira auth login --web first";
  if (/not found|ENOENT/i.test(output)) return "Install acli (Brewfile.extras)";
  return output.trim().split("\n")[0];
}

// Jira isn't tied to a workspace, so everything runs locally from home.
async function run(cmd, args) {
  const r = await exec(cmd, args, { cwd: home() });
  if (r.code !== 0) throw new Error(friendlyError(r.stderr || r.stdout));
  return r.stdout;
}
const acli = async (args) => JSON.parse(await run("acli", args));

function statusColor(issue, t) {
  const s = issue.fields?.status, name = s?.name ?? "";
  if (/block/i.test(name)) return t.blocked;
  if (s?.statusCategory?.key === "indeterminate") return t.working;
  if (s?.statusCategory?.key === "done") return t.done;
  return /backlog/i.test(name) ? t.dim : t.muted;
}

// Assigned, not-done tickets grouped by project. Refreshed by hand only: tickets change slowly.
export class Panel {
  init(_props, cx) {
    this.issues = []; this.generation = 0;
    // Remembered across restarts so quiet projects stay out of the way.
    this.collapsed = new Set(JSON.parse(localStorage.getItem("collapsed") ?? "[]"));
    // key -> parent (or null); cached so labels show at once and only new tickets are looked up.
    this.parents = JSON.parse(localStorage.getItem("parents") ?? "{}");
    this.filters = { text: "", projects: new Set(), statuses: new Set() };
    this.search = InputState.new({ placeholder: "Filter by key or title" });
    this.search.on("change", (_e, cx) => { this.filters = { ...this.filters, text: this.search.value() }; cx.notify(); });
    cx.spawn(async (cx) => {
      try { this.site = siteFrom(await run("acli", ["jira", "auth", "status"])); } catch { this.site = null; }
      cx.notify();
    });
    this.refresh(cx, { reloadParents: false });
    this.listenCommands(cx);
  }

  listenCommands(cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "refresh") this.refresh(cx);
        // "open:KEY" drills into a ticket, e.g. from a key binding.
        if (command.startsWith("open:")) this.openDetail({ key: command.slice(5), fields: {} }, cx);
        cx.notify();
      }
    });
  }

  refresh(cx, { reloadParents = true } = {}) {
    const generation = ++this.generation;
    this.loading = true;
    cx.spawn(async (cx) => {
      try { const issues = await acli(SEARCH_ARGS); if (generation === this.generation) { this.issues = issues; this.error = null; } }
      catch (e) { if (generation === this.generation) this.error = String(e.message ?? e); }
      finally { if (generation === this.generation) this.loading = false; cx.notify(); }
      if (generation === this.generation && !this.error) this.loadParents(generation, reloadParents, cx);
    });
    cx.notify();
  }

  // Startup only fills gaps from the cache; a manual refresh re-checks every parent.
  async loadParents(generation, all, cx) {
    const keys = this.issues.map((i) => i.key).filter((k) => all || !(k in this.parents));
    const fresh = Object.fromEntries(this.issues.map((i) => [i.key, this.parents[i.key] ?? null]));
    await mapLimit(keys, 6, async (key) => {
      try { fresh[key] = parentOf(await acli(parentArgs(key))); } catch { return; }
      if (generation !== this.generation) return;
      this.parents = { ...this.parents, [key]: fresh[key] };
      cx.notify();
    });
    if (generation !== this.generation) return;
    // Keep only current tickets so the cache doesn't grow forever.
    this.parents = fresh;
    localStorage.setItem("parents", JSON.stringify(fresh));
    cx.notify();
  }

  toggle(set, value, cx) {
    const next = new Set(this.filters[set]);
    if (next.has(value)) next.delete(value); else next.add(value);
    this.filters = { ...this.filters, [set]: next };
    cx.notify();
  }

  clearFilters(cx) {
    this.search.set_value("");
    this.filters = { text: "", projects: new Set(), statuses: new Set() };
    cx.notify();
  }

  hasFilters() {
    const f = this.filters;
    return Boolean(f.text.trim()) || f.projects.size > 0 || f.statuses.size > 0;
  }

  chip(id, label, active, onClick, t) {
    return h_flex().id(id).h(24).px(8).gap(4).flex_none().items_center().rounded(6).cursor_pointer().text_size(11)
      .bg(active ? t.selected : t.raised).text_color(active ? t.foreground : t.muted)
      .hover((s) => s.bg(t.hover)).on_click((_e, cx) => onClick(cx)).child(label);
  }

  filterBar(t) {
    const { projects, statuses } = this.filters;
    return h_flex().h(38).flex_none().px(8).gap(6).items_center().border_b(1).border_color(t.border)
      .child(this.chip("jira-projects", projects.size ? `Projects · ${projects.size}` : "Projects", projects.size > 0 || this.picker === "projects",
        (cx) => { this.picker = this.picker === "projects" ? null : "projects"; cx.notify(); }, t))
      .child(this.chip("jira-statuses", statuses.size ? `Status · ${statuses.size}` : "Status", statuses.size > 0 || this.picker === "statuses",
        (cx) => { this.picker = this.picker === "statuses" ? null : "statuses"; cx.notify(); }, t))
      .child(div().flex_1().min_w(0).h(24).px(8).flex().items_center().rounded(6).border_1()
        .border_color(this.filters.text ? t.accent : t.border).bg(t.background)
        .child(Input.new(this.search).h_full().text_size(11).text_color(t.foreground)))
      .when(this.hasFilters(), (e) => e.child(this.chip("jira-clear", "Clear", false, (cx) => this.clearFilters(cx), t)));
  }

  // Options come from the tickets you have, so there's never an empty choice.
  pickerView(t) {
    const set = this.picker, picked = this.filters[set];
    const values = [...new Set(this.issues.map((i) => set === "projects" ? projectOf(i.key) : i.fields?.status?.name).filter(Boolean))].sort();
    return h_flex().id("jira-picker").flex_none().flex_wrap().gap(5).p(8).border_b(1).border_color(t.border)
      .children(values.map((v) => this.chip(`jira-${set}-${v}`, v, picked.has(v), (cx) => this.toggle(set, v, cx), t)));
  }

  row(issue, t) {
    const f = issue.fields ?? {}, color = statusColor(issue, t), parent = this.parents[issue.key];
    return v_flex().id(`jira-${issue.key}`).flex_none().px(10).py(6).gap(3).rounded(7).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((e, cx) => (e.modifiers?.shift && this.site ? openUrl(browseUrl(this.site, issue.key)) : this.openDetail(issue, cx)))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_none().w(6).h(6).rounded(3).bg(color))
        .child(div().flex_none().text_size(11).text_color(t.accent).child(issue.key))
        .child(div().flex_1().min_w(0).truncate().child(f.summary ?? "")))
      .child(h_flex().pl(14).gap(8).text_size(11).text_color(t.dim)
        .child(div().flex_none().text_color(color).child(f.status?.name ?? ""))
        .child(div().flex_none().child(f.issuetype?.name ?? ""))
        .when(f.priority?.name && f.priority.name !== "None", (e) => e.child(div().flex_none().child(f.priority.name)))
        .when(Boolean(parent), (e) => e.child(div().min_w(0).truncate().text_color(parent.epic ? t.ansi5 : t.muted)
          .child(`${parent.epic ? "◆" : "↳"} ${parent.summary || parent.key}`))));
  }

  toggleGroup(project, cx) {
    if (this.collapsed.has(project)) this.collapsed.delete(project); else this.collapsed.add(project);
    localStorage.setItem("collapsed", JSON.stringify([...this.collapsed]));
    cx.notify();
  }

  group({ project, issues }, t) {
    const open = !this.collapsed.has(project);
    return v_flex().flex_none().gap(2)
      .child(h_flex().id(`jira-group-${project}`).h(26).px(10).gap(6).items_center().rounded(6).bg(t.raised).cursor_pointer()
        .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.toggleGroup(project, cx))
        .child(div().w(10).text_size(10).text_color(t.dim).child(open ? "▾" : "▸"))
        .child(div().text_size(11).text_color(t.foreground).child(project))
        .child(div().text_size(10).text_color(t.dim).child(String(issues.length))))
      .when(open, (e) => e.children(issues.map((i) => this.row(i, t))));
  }

  // Click reads it here; shift+click (or "Open") goes to the browser. Drilling into
  // a parent, child or link stacks, so Back walks out the way you came in.
  openDetail(issue, cx, { push = false } = {}) {
    if (push && this.detail) (this.trail ??= []).push(this.detail); else if (!push) this.trail = [];
    const detail = this.detail = { issue, prs: [], children: [], loading: true, allPrs: false };
    cx.spawn(async (cx) => {
      try {
        // PRs are best-effort: Jira's own dev panel isn't reachable from acli, so ask GitHub by key.
        // Children are fetched for every ticket: only epics have them, but we may not know the type yet.
        const [full, prs, children] = await Promise.all([acli(viewArgs(issue.key)),
          run("gh", prSearchArgs(issue.key)).then((s) => relatedPrs(JSON.parse(s), issue.key)).catch(() => []),
          acli(childArgs(issue.key)).catch(() => [])]);
        Object.assign(detail, { issue: full, prs, children: byStatus(children) });
      } catch (e) { detail.error = String(e.message ?? e); }
      finally { detail.loading = false; cx.notify(); }
    });
    cx.notify();
  }

  back(cx) {
    this.detail = this.trail?.pop() ?? null;
    cx.notify();
  }

  pill(text, color, t) {
    return div().flex_none().px(6).h(18).flex().items_center().rounded(5).bg(color + "26").text_size(10.5).font_semibold().text_color(color).child(text);
  }

  section(title, count, t) {
    return h_flex().pt(14).pb(6).gap(6).items_center()
      .child(div().text_size(10.5).font_semibold().text_color(t.muted).child(title.toUpperCase()))
      .when(count !== undefined, (e) => e.child(div().text_size(10).text_color(t.dim).child(String(count))))
      .child(div().flex_1().h(1).bg(t.border));
  }

  detailsCard(f, t) {
    const rows = detailRows(f);
    return v_flex().gap(5).p(10).rounded(8).bg(t.raised).children(rows.map((r) => h_flex().gap(10).items_start().text_size(12)
      .child(div().flex_none().w(78).text_size(11).text_color(t.dim).child(r.label))
      .child(r.chips
        ? h_flex().flex_1().flex_wrap().gap(4).children(r.chips.map((c) => div().px(6).h(18).flex().items_center().rounded(5).border_1().border_color(t.border).text_size(11).text_color(t.muted).child(c)))
        : h_flex().flex_1().min_w(0).gap(6)
          .child(div().id(`jira-row-${r.label}`).min_w(0).truncate().text_color(r.key ? t.accent : t.foreground)
            .when(Boolean(r.key), (e) => e.cursor_pointer().on_click((_e, cx) => this.openDetail({ key: r.key, fields: {} }, cx, { push: true })))
            .child(r.value))
          .when(Boolean(r.note), (e) => e.child(div().flex_none().text_color(r.tone ? t[r.tone] : t.dim).child(r.note))))));
  }

  workRow(issue, relation, t) {
    const color = statusColor(issue, t);
    return h_flex().id(`jira-work-${relation ?? ""}-${issue.key}`).flex_none().px(8).py(5).gap(8).items_center().rounded(6).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.openDetail(issue, cx, { push: true }))
      .child(div().flex_none().w(6).h(6).rounded(3).bg(color))
      .when(Boolean(relation), (e) => e.child(div().flex_none().text_size(11).text_color(t.dim).child(relation)))
      .child(div().flex_none().text_size(11).text_color(t.accent).child(issue.key))
      .child(div().flex_1().min_w(0).truncate().text_size(12).child(issue.fields?.summary ?? ""))
      .child(div().flex_none().text_size(11).text_color(color).child(issue.fields?.status?.name ?? ""));
  }

  prRow(pr, t) {
    const tone = prTone(pr), color = { open: t.done, merged: t.ansi5, closed: t.ansi1, draft: t.dim }[tone] ?? t.muted;
    return h_flex().id(`jira-pr-${pr.url}`).flex_none().px(8).py(5).gap(8).items_center().rounded(6).cursor_pointer()
      .hover((s) => s.bg(t.hover)).on_click(() => openUrl(pr.url))
      .child(this.pill(tone, color, t))
      .child(div().flex_none().text_size(11).text_color(t.dim).child(`${pr.repository?.name ?? ""}#${pr.number}`))
      .child(div().flex_1().min_w(0).truncate().text_size(12).child(pr.title));
  }

  prSection(t) {
    const d = this.detail, prs = d.prs, shown = d.allPrs ? prs : prs.slice(0, 5);
    return v_flex().gap(1)
      .child(this.section("Pull requests", prs.length, t))
      .children(shown.map((pr) => this.prRow(pr, t)))
      .when(!prs.length, (e) => e.child(div().px(8).text_size(12).text_color(t.dim).child("None found")))
      .when(prs.length > shown.length, (e) => e.child(div().id("jira-prs-more").px(8).py(4).text_size(11).text_color(t.accent).cursor_pointer()
        .on_click((_e, cx) => { d.allPrs = true; cx.notify(); }).child(`Show all ${prs.length}`)));
  }

  comment(c, i, t) {
    return v_flex().gap(4).p(10).rounded(8).border_1().border_color(t.border)
      .child(h_flex().gap(6).text_size(11)
        .child(div().font_semibold().text_color(t.foreground).child(c.author?.displayName ?? "?"))
        .child(div().text_color(t.dim).child(c.created ? `${ago(c.created)} ago` : "")))
      .child(TextView.markdown(`jira-comment-${this.detail.issue.key}-${i}`, adfToMarkdown(c.body) || "_Empty_").selectable().on_link_click((url) => openUrl(url)));
  }

  detailBody(t) {
    const { issue, children, loading, error } = this.detail, f = issue.fields ?? {};
    if (error) return div().p(8).text_color(t.ansi1).child(error);
    if (loading) return div().p(8).text_color(t.dim).child("Loading…");
    const links = linkedWork(f.issuelinks).filter((l) => isOpen(l.issue)), comments = f.comment?.comments ?? [], subtasks = (f.subtasks ?? []).filter(isOpen);
    return v_flex()
      .child(this.section("Info", undefined, t).pt(0))
      .child(this.detailsCard(f, t))
      .child(this.section("Description", undefined, t))
      .child(TextView.markdown(`jira-desc-${issue.key}`, adfToMarkdown(f.description) || "_No description._").selectable().on_link_click((url) => openUrl(url)))
      .when(subtasks.length > 0, (e) => e.child(this.section("Sub-tasks", subtasks.length, t)).children(subtasks.map((i) => this.workRow(i, null, t))))
      .when(children.length > 0, (e) => e.child(this.section("Child work", children.length, t)).children(children.map((i) => this.workRow(i, null, t))))
      .when(links.length > 0, (e) => e.child(this.section("Linked work", links.length, t)).children(links.map((l) => this.workRow(l.issue, l.relation, t))))
      .child(this.section("Comments", comments.length, t))
      .when(!comments.length, (e) => e.child(div().px(8).text_size(12).text_color(t.dim).child("No comments")))
      .child(v_flex().gap(6).children(comments.map((c, i) => this.comment(c, i, t))))
      .child(this.prSection(t));
  }

  detailView(t) {
    const { issue } = this.detail, f = issue.fields ?? {};
    const link = (id, label, onClick) => div().id(id).px(8).h(26).flex().items_center().rounded(7).cursor_pointer()
      .text_size(11).text_color(t.muted).hover((s) => s.bg(t.hover)).on_click(onClick).child(label);
    const priority = f.priority?.name && f.priority.name !== "None" ? f.priority.name : null;
    return v_flex().flex_1().min_h(0)
      .child(h_flex().h(42).flex_none().px(10).gap(4).items_center().border_b(1).border_color(t.border)
        .child(link("jira-back", this.trail?.length ? `← ${this.trail.at(-1).issue.key}` : "← Back", (_e, cx) => this.back(cx)))
        .child(div().flex_1())
        .when(Boolean(this.site), (e) => e.child(link("jira-open", "Open ↗", () => openUrl(browseUrl(this.site, issue.key))))))
      .child(v_flex().flex_none().px(12).pt(12).pb(10).gap(6).border_b(1).border_color(t.border)
        .child(div().id("jira-detail-key").text_size(11).text_color(t.accent).when(Boolean(this.site), (e) => e.cursor_pointer().underline()
          .on_click(() => openUrl(browseUrl(this.site, issue.key)))).child(issue.key))
        .child(div().text_size(15).font_semibold().child(f.summary ?? ""))
        .child(h_flex().gap(5).flex_wrap()
          .when(Boolean(f.status?.name), (e) => e.child(this.pill(f.status.name, statusColor(issue, t), t)))
          .when(Boolean(f.issuetype?.name), (e) => e.child(this.pill(f.issuetype.name, t.muted, t)))
          .when(Boolean(priority), (e) => e.child(this.pill(priority, /high/i.test(priority) ? t.blocked : t.muted, t)))))
      .child(v_flex().id("jira-detail-scroll").flex_1().min_h(0).overflow_y_scrollbar().px(12).pt(10).pb(16).child(this.detailBody(t)));
  }

  emptyText() {
    if (this.error) return this.error;
    if (this.loading) return "Loading…";
    return this.hasFilters() ? "No tickets match these filters" : "Nothing assigned to you";
  }

  render(cx) {
    const t = theme();
    const shell = () => v_flex().id("jira").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13);
    if (this.detail) return shell().child(this.detailView(t));
    const groups = groupByProject(this.issues.filter((i) => matches(i, this.filters)));
    const shown = groups.reduce((n, g) => n + g.issues.length, 0);
    return shell()
      .child(h_flex().h(42).flex_none().px(12).gap(6).items_center().border_b(1).border_color(t.border)
        .child(div().child("My work"))
        .child(div().text_size(10).text_color(t.dim).child(shown === this.issues.length ? String(shown) : `${shown} / ${this.issues.length}`))
        .child(div().flex_1())
        .child(div().id("jira-refresh").px(8).h(26).flex().items_center().rounded(7).cursor_pointer().text_size(11).text_color(t.muted)
          .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.refresh(cx)).child(this.loading ? "…" : "Refresh")))
      .child(this.filterBar(t))
      .when(Boolean(this.picker), (e) => e.child(this.pickerView(t)))
      .child(v_flex().id("jira-list").flex_1().min_h(0).overflow_y_scrollbar().p(6).gap(8)
        .children(groups.map((g) => this.group(g, t)))
        .when(!shown, (e) => e.child(div().p(8).text_color(this.error ? t.ansi1 : t.dim).child(this.emptyText()))));
  }
}
