import { div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, exec, theme, notify } from "herdr";
import { summarizeChecks, finishedState } from "./checks.js";
import { safeUrl } from "./urls.js";
import { openUrl } from "./open.js";

const FAST_MS = 30000;
const SLOW_MS = 90000;

// Where a space is now: its first terminal's live folder, else where it was made.
function place(space) {
  const tabs = new Set((space.tabs ?? []).map((c) => c.id));
  return panes().find((p) => tabs.has(p.tab) && p.cwd)?.cwd || space.folder || null;
}

// One target per folder and machine: spaces showing the same checkout share it.
function targets() {
  const seen = new Map();
  for (const space of spaces()) {
    const folder = place(space), key = `${space.machine ?? ""}:${folder}`;
    if (folder && !seen.has(key)) seen.set(key, { key, folder, on: space.machine ?? null, space });
  }
  return [...seen.values()];
}

const activeKey = () => targets().find((t) => t.space.active)?.key;

// The PR of the folder's branch, or null: no PR, not a repo, or gh can't tell.
async function loadPr(folder, on) {
  const r = await exec("gh", ["pr", "view", "--json", "number,title,url,statusCheckRollup"], { cwd: folder, on });
  if (r.code !== 0) return null;
  const pr = JSON.parse(r.stdout);
  return { number: pr.number, title: pr.title, url: pr.url, checks: summarizeChecks(pr.statusCheckRollup) };
}

// The status-bar badge for the shown space; notifies when any space's checks finish.
export class CiBadge {
  init(_props, cx) {
    this.prs = {}; this.lastRun = 0;
    this.refreshAll(cx);
    cx.timer.every(FAST_MS, (cx) => {
      const running = Object.values(this.prs).some((pr) => pr?.checks.state === "pending");
      if (running || Date.now() - this.lastRun >= SLOW_MS) this.refreshAll(cx);
    });
  }

  refreshAll(cx) {
    if (this.loading) return;
    const list = targets();
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const results = await Promise.all(list.map(async (t) => [t, await loadPr(t.folder, t.on).catch(() => null)]));
        for (const [t, pr] of results) { this.announce(t, this.prs[t.key], pr); this.prs[t.key] = pr; }
        this.lastRun = Date.now();
      } finally { this.loading = false; cx.notify(); }
    });
  }

  announce(target, before, after) {
    const state = finishedState(before, after);
    if (!state) return;
    const { failed, total } = after.checks, where = target.space.name;
    if (state === "fail") {
      const names = failed.slice(0, 3).map((c) => c.name).join(", ");
      notify({ title: `CI failed · #${after.number}`, body: `${where} · ${names}`, level: "error", action: { name: "space.select", args: { id: target.space.id } } });
    }
    if (state === "pass") notify({ title: `CI passed · #${after.number}`, body: `${where} · ${total} checks`, level: "success", timeout: 6000 });
  }

  badge(pr, t) {
    const { state, failed, passed, total } = pr.checks;
    if (state === "fail") return { color: t.ansi1, text: `CI ✗ ${failed.length} failed`, url: safeUrl(failed[0].url) ?? `${pr.url}/checks` };
    if (state === "pending") return { color: t.working, text: `CI ${passed}/${total}`, url: `${pr.url}/checks`, spin: true };
    if (state === "pass") return { color: t.ansi2, text: "CI ✓ passed", url: `${pr.url}/checks` };
    return { color: t.dim, text: "CI · no checks", url: pr.url };
  }

  render(cx) {
    const t = theme(), key = activeKey();
    if (key && !(key in this.prs) && !this.loading) this.refreshAll(cx);
    const pr = key ? this.prs[key] : null;
    const bar = h_flex().id("ci").size_full().px(14).gap(6).items_center().justify_end()
      .bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted);
    if (!pr) return bar;
    const b = this.badge(pr, t);
    return bar.child(h_flex().id("ci-badge").gap(6).items_center().cursor_pointer().text_color(b.color)
      .on_click(() => openUrl(b.url))
      .when(Boolean(b.spin), (e) => e.child(svg("mods/workspace-chrome/spinner.svg").size(12).spin(900)))
      .child(`#${pr.number}`).child(div().child(b.text)));
  }
}
