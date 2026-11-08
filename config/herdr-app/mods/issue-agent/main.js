// Start an agent on a GitHub issue: props { issue: {number, title, labels}, cwd, on }.
// Makes a worktree from the default branch and a space running the agent with the issue as its task.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, run, props, closeOverlay, theme, knownAgents, home, shared, setShared } from "herdr";
import { adapterFor } from "./agents.js";

const LAST_CHOICE = "issue-agent.last";
const MODEL_CACHE = "issue-agent.models";
const CACHE_MS = 60 * 60 * 1000;
const BRANCH_TYPES = { bug: "fix", documentation: "docs", docs: "docs", refactor: "refactor", chore: "chore" };

const slug = (text) => text.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase()
  .replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").split("-").slice(0, 5).join("-");
const folderName = (branch) => branch.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "");

function branchFor(issue) {
  const type = issue.labels.map((l) => BRANCH_TYPES[l.name.toLowerCase()]).find(Boolean) ?? "feat";
  return `${type}/${issue.number}-${slug(issue.title)}`;
}

function taskFor(issue, branch) {
  return [
    `Work on GitHub issue #${issue.number}: ${issue.title}. Read it with \`gh issue view ${issue.number}\`.`,
    `You are in a fresh worktree on branch ${branch}.`,
    "Read the repo's AGENTS.md / CLAUDE.md before changing code.",
    "Run the project's lint, typecheck and tests before committing.",
    `Commit with conventional commits, push the branch and open a PR with "Closes #${issue.number}".`,
    "Do not merge or deploy.",
  ].join(" ");
}

async function git(cwd, args, on) {
  const r = await exec("git", args, { cwd, on });
  return { ok: r.code === 0, out: (r.stdout ?? "").trim(), err: (r.stderr || r.stdout || "").trim() };
}

async function userHome(on) {
  if (!on) return home();
  const r = await exec("sh", ["-c", 'printf %s "$HOME"'], { on });
  if (r.code !== 0 || !r.stdout.trim()) throw new Error("Could not find the remote home folder.");
  return r.stdout.trim();
}

// origin/<default branch>, fetched; HEAD when there's no remote to fetch from.
async function baseRef(cwd, on) {
  const r = await exec("gh", ["repo", "view", "--json", "defaultBranchRef", "-q", ".defaultBranchRef.name"], { cwd, on });
  const name = r.code === 0 ? r.stdout.trim() : "";
  if (!name || !(await git(cwd, ["fetch", "origin", name], on)).ok) return "HEAD";
  return `origin/${name}`;
}

async function createWorktree(cwd, on, branch) {
  const common = await git(cwd, ["rev-parse", "--path-format=absolute", "--git-common-dir"], on);
  if (!common.ok) throw new Error("Not a git repository");
  const main = common.out.endsWith("/.git") ? common.out.slice(0, -5) : common.out;
  const path = `${await userHome(on)}/.herdr/worktrees/${main.split("/").pop()}/${folderName(branch)}`;
  const exists = (await git(main, ["show-ref", "--verify", "--quiet", `refs/heads/${branch}`], on)).ok;
  const add = exists ? ["worktree", "add", path, branch] : ["worktree", "add", "-b", branch, path, await baseRef(cwd, on)];
  const r = await git(main, add, on);
  if (!r.ok) throw new Error(r.err.split("\n").pop() || "git worktree add failed");
  return path;
}

async function modelsFor(agent, on) {
  const cache = shared(MODEL_CACHE) ?? {};
  const key = `${on ?? ""}:${agent.key}`;
  if (cache[key] && Date.now() - cache[key].at < CACHE_MS) return cache[key].models;
  const models = await adapterFor(agent).models(on);
  setShared(MODEL_CACHE, { ...cache, [key]: { at: Date.now(), models } });
  return models;
}

export default class IssueAgent extends View {
  init(_props, cx) {
    this.issue = props()?.issue ?? { number: 0, title: "Open this from an issue in the GitHub panel", labels: [] };
    this.agents = []; this.models = []; this.filter = "";
    this.branchInput = InputState.new({ value: branchFor(this.issue), placeholder: "branch name" });
    this.filterInput = InputState.new({ placeholder: "filter or type a model" });
    this.filterInput.on("change", (_e, cx) => { this.filter = this.filterInput.value().trim(); cx.notify(); });
    this.branchInput.on("submit", (_e, cx) => this.start(cx));
    this.loadAgents(cx);
  }

  loadAgents(cx) {
    cx.spawn(async (cx) => {
      try {
        this.agents = (await knownAgents({ on: props().on })).filter((a) => a.installed);
        const last = shared(LAST_CHOICE) ?? {};
        this.pickAgent(this.agents.find((a) => a.key === last.agent) ?? this.agents[0], cx, last);
      } catch (e) { this.error = `Could not list agents: ${e}`; }
      cx.notify();
    });
  }

  pickAgent(agent, cx, last = {}) {
    if (!agent) { this.error = "No agent installed on this machine"; return; }
    this.agent = agent; this.models = []; this.model = null; this.effort = null; this.modelsError = null;
    this.filterInput.set_value(""); this.filter = "";
    if (!adapterFor(agent)) return cx.notify();
    this.loadingModels = true;
    cx.spawn(async (cx) => {
      try {
        const models = await modelsFor(agent, props().on);
        if (this.agent !== agent) return;
        this.models = models;
        const remembered = last.agent === agent.key ? models.find((m) => m.id === last.model) : null;
        this.pickModel(remembered ?? null, remembered ? last.effort : null);
      } catch (e) { if (this.agent === agent) this.modelsError = String(e.message ?? e); }
      finally { if (this.agent === agent) this.loadingModels = false; cx.notify(); }
    });
    cx.notify();
  }

  pickModel(model, effort = null) {
    this.model = model;
    const efforts = model?.efforts ?? [];
    this.effort = efforts.includes(effort) ? effort : efforts.includes(model?.effort) ? model.effort : null;
  }

  // The typed model when it matches none, so models a CLI can't list still work.
  chosenModelId() {
    if (this.model) return this.model.id;
    return this.filter && !this.models.some((m) => m.id === this.filter) ? this.filter : null;
  }

  start(cx) {
    const branch = this.branchInput.value().trim();
    if (this.busy || !this.agent || !branch || !this.issue.number) return;
    const { cwd, on } = props(), agent = this.agent, model = this.chosenModelId(), effort = this.effort;
    const argv = [...agent.run, ...(adapterFor(agent)?.flags(model, effort) ?? [])];
    this.busy = true; this.error = null;
    cx.spawn(async (cx) => {
      try {
        const folder = await createWorktree(cwd, on, branch);
        setShared(LAST_CHOICE, { agent: agent.key, model, effort });
        run("space.new", { folder, machine: on, tab: `#${this.issue.number}`, argv, task: taskFor(this.issue, branch) });
        closeOverlay(props().overlay);
      } catch (e) { this.error = String(e.message ?? e); }
      finally { this.busy = false; cx.notify(); }
    });
    cx.notify();
  }

  section(title, child, t) {
    return v_flex().gap(6).child(div().text_size(11).text_color(t.dim).child(title)).child(child);
  }

  chip(id, label, selected, onClick, t, icon = null) {
    return h_flex().id(id).h(26).px(9).gap(6).items_center().rounded(7).cursor_pointer().flex_none()
      .bg(selected ? t.selected : t.raised).text_color(selected ? t.foreground : t.muted)
      .hover((s) => s.bg(t.hover)).on_click((_e, cx) => { onClick(cx); cx.notify(); })
      .when(Boolean(icon), (e) => e.child(icon)).child(label);
  }

  field(state, t) {
    return div().h(30).px(10).flex().items_center().rounded(8).border_1().border_color(t.border).bg(t.background)
      .child(Input.new(state).h_full().text_size(12).text_color(t.foreground));
  }

  agentIcon(a, t) {
    if (!a.icon) return null;
    return a.tint ? svg(a.icon).size(14).text_color(t.foreground) : image(a.icon).size(14);
  }

  agentRow(t) {
    if (!this.agents.length) return div().text_color(t.dim).child(this.error ?? "Checking installed agents…");
    return h_flex().flex_wrap().gap(6).children(this.agents.map((a) =>
      this.chip(`agent-${a.key}`, a.name, this.agent === a, (cx) => this.pickAgent(a, cx), t, this.agentIcon(a, t))));
  }

  modelList(t) {
    const f = this.filter.toLowerCase();
    const shown = this.models.filter((m) => !f || `${m.id} ${m.label ?? ""}`.toLowerCase().includes(f)).slice(0, 100);
    const custom = this.chosenModelId() && !this.model ? this.chosenModelId() : null;
    const row = (id, label, selected, onClick) => h_flex().id(`model-${id}`).h(26).px(8).gap(8).items_center().rounded(6).flex_none().cursor_pointer()
      .when(selected, (e) => e.bg(t.selected)).hover((s) => s.bg(t.hover)).on_click((_e, cx) => { onClick(); cx.notify(); })
      .child(div().flex_1().min_w(0).truncate().text_color(selected ? t.foreground : t.muted).child(label));
    return v_flex().gap(6).child(this.field(this.filterInput, t))
      .child(v_flex().id("models").h(170).overflow_y_scrollbar().gap(1)
        .child(row("default", custom ? `Use "${custom}"` : "Agent's default", !this.model, () => this.pickModel(null)))
        .children(shown.map((m) => row(m.id, m.label && m.label !== m.id ? `${m.label}  ·  ${m.id}` : m.id, this.model === m, () => this.pickModel(m, this.effort))))
        .when(this.loadingModels, (e) => e.child(div().px(8).py(4).text_color(t.dim).child("Loading models…")))
        .when(Boolean(this.modelsError), (e) => e.child(div().px(8).py(4).text_color(t.ansi1).child(this.modelsError))));
  }

  effortRow(t) {
    const efforts = this.model?.efforts ?? [];
    if (!efforts.length) return div().text_color(t.dim).child(this.model ? "This model has no reasoning levels" : "Agent's default");
    return h_flex().flex_wrap().gap(6).children(efforts.map((e) =>
      this.chip(`effort-${e}`, e, this.effort === e, () => { this.effort = this.effort === e ? null : e; }, t)));
  }

  footer(t) {
    const ready = Boolean(this.agent) && !this.busy;
    return h_flex().gap(8).items_center()
      .child(div().flex_1().min_w(0).text_size(11).text_color(t.ansi1).child(this.error ?? ""))
      .child(h_flex().id("cancel").h(30).px(12).items_center().rounded(8).cursor_pointer().text_color(t.muted)
        .hover((s) => s.bg(t.hover)).on_click(() => closeOverlay(props().overlay)).child("Cancel"))
      .child(h_flex().id("start").h(30).px(14).items_center().rounded(8).cursor_pointer()
        .bg(ready ? t.solid : t.raised).text_color(ready ? t.solid_foreground : t.dim)
        .on_click((_e, cx) => this.start(cx)).child(this.busy ? "Starting…" : "Start agent"));
  }

  render(cx) {
    const t = theme(), hasModels = this.agent && adapterFor(this.agent);
    return v_flex().id("issue-agent").size_full().p(16).gap(14).bg(t.popover).text_color(t.foreground).text_size(12.5)
      .child(v_flex().gap(2)
        .child(div().text_size(14).font_semibold().child(`Start an agent on #${this.issue.number}`))
        .child(div().text_color(t.dim).truncate().child(this.issue.title)))
      .child(this.section("Branch", this.field(this.branchInput, t), t))
      .child(this.section("Agent", this.agentRow(t), t))
      .when(Boolean(hasModels), (e) => e.child(this.section("Model", this.modelList(t), t)).child(this.section("Reasoning", this.effortRow(t), t)))
      .child(div().flex_1())
      .child(this.footer(t));
  }
}
