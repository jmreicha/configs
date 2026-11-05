// Run: node jira.test.mjs
import assert from "node:assert/strict";
import { parentOf, mapLimit, isOpen, childArgs, byStatus, projectOf, groupByProject, matches, statusRank, browseUrl, siteFrom, relatedPrs, detailRows, linkedWork, prTone, ago } from "./jira.js";

const issue = (key, status, category, summary = "s") => ({ key, fields: { summary, status: { name: status, statusCategory: { key: category } } } });

assert.equal(projectOf("EAB-12"), "EAB");

// In progress first, blocked next, backlog last; projects alphabetical.
const groups = groupByProject([issue("EAB-1", "Backlog", "new"), issue("COST-2", "To Do", "new"), issue("EAB-3", "In Progress", "indeterminate"), issue("EAB-4", "Blocked", "indeterminate")]);
assert.deepEqual(groups.map((g) => g.project), ["COST", "EAB"]);
assert.deepEqual(groups[1].issues.map((i) => i.key), ["EAB-3", "EAB-4", "EAB-1"]);
assert.ok(statusRank(issue("X-1", "In Progress", "indeterminate")) < statusRank(issue("X-2", "To Do", "new")));
// Finished children sink below everything still open.
assert.ok(statusRank(issue("X-3", "Done", "done")) > statusRank(issue("X-4", "Backlog", "new")));
assert.deepEqual(byStatus([issue("X-5", "Done", "done"), issue("X-6", "In Progress", "indeterminate")]).map((i) => i.key), ["X-6", "X-5"]);

const f = { text: "", projects: new Set(), statuses: new Set() };
assert.ok(matches(issue("EAB-1", "To Do", "new", "Fix VPN"), f));
assert.ok(matches(issue("EAB-1", "To Do", "new", "Fix VPN"), { ...f, text: "vpn" }));
assert.ok(matches(issue("EAB-1", "To Do", "new", "Fix VPN"), { ...f, text: "eab-1" }));
assert.ok(!matches(issue("EAB-1", "To Do", "new"), { ...f, projects: new Set(["COST"]) }));
assert.ok(!matches(issue("EAB-1", "To Do", "new"), { ...f, statuses: new Set(["In Progress"]) }));

assert.equal(siteFrom("✓ Authenticated\n  Site: acme.atlassian.net\n  Email: a@b.c"), "acme.atlassian.net");
assert.equal(siteFrom("✗ Error: unauthorized"), null);
assert.equal(browseUrl("acme.atlassian.net", "EAB-1"), "https://acme.atlassian.net/browse/EAB-1");

// GitHub search is fuzzy; keep only PRs that actually name the ticket.
const prs = [{ title: "feat(EAB-12): x", body: "" }, { title: "other", body: "Refs eab-12" }, { title: "EAB-123 nope", body: "" }, { title: "unrelated", body: "" }];
assert.deepEqual(relatedPrs(prs, "EAB-12").map((p) => p.title), ["feat(EAB-12): x", "other"]);

const NOW = Date.parse("2026-11-05T12:00:00Z");
const fields = {
  reporter: { displayName: "Al" }, assignee: { displayName: "Josh" },
  created: "2026-10-01T08:00:00.000-0700", updated: "2026-11-04T08:00:00.000-0700",
  statuscategorychangedate: "2026-10-29T08:00:00.000-0700", duedate: "2026-11-01",
  priority: { name: "High" }, labels: ["infra", "q4"], components: [{ name: "Net" }],
  parent: { key: "EAB-0", fields: { summary: "Epic thing" } },
};
const rows = Object.fromEntries(detailRows(fields, NOW).map((r) => [r.label, r]));
assert.equal(rows.Reporter.value, "Al");
assert.equal(rows.Assignee.value, "Josh");
assert.deepEqual([rows.Created.value, rows.Created.note], ["Oct 1, 2026", "35d ago"]);
assert.deepEqual([rows.Updated.value, rows.Updated.note], ["Nov 4, 2026", "21h ago"]);
assert.equal(rows["In status"].value, "7d");
assert.deepEqual([rows.Due.value, rows.Due.note, rows.Due.tone], ["Nov 1, 2026", "overdue", "blocked"]);
assert.equal(rows.Parent.value, "EAB-0 Epic thing");
assert.equal(rows.Parent.key, "EAB-0");
assert.deepEqual(rows.Labels.chips, ["infra", "q4"]);
assert.deepEqual(rows.Components.chips, ["Net"]);
// Empty fields are dropped rather than shown blank.
assert.deepEqual(detailRows({}, NOW), []);
assert.ok(!("Due" in Object.fromEntries(detailRows({ duedate: null }, NOW).map((r) => [r.label, r]))));

assert.deepEqual(linkedWork([{ type: { outward: "blocks", inward: "is blocked by" }, inwardIssue: { key: "EAB-2", fields: {} } }]),
  [{ relation: "is blocked by", issue: { key: "EAB-2", fields: {} } }]);

assert.equal(prTone({ state: "merged" }), "merged");
assert.equal(prTone({ state: "open", isDraft: true }), "draft");
assert.equal(prTone({ state: "OPEN" }), "open");
assert.equal(ago("2026-11-05T11:30:00Z", NOW), "30m");
assert.ok(isOpen(issue("X-1", "In Progress", "indeterminate")));
assert.ok(!isOpen(issue("X-2", "Done", "done")));
assert.ok(isOpen({ key: "X-3", fields: {} }), "unknown status stays visible");
assert.match(childArgs("EAB-1")[4], /statusCategory != Done/);
assert.deepEqual(parentOf({ key: "EAB-1", fields: { parent: { key: "EAB-0", fields: { summary: "Epic", issuetype: { name: "Epic" } } } } }),
  { key: "EAB-0", summary: "Epic", epic: true });
assert.equal(parentOf({ key: "EAB-1", fields: {} }), null);

// mapLimit runs at most n at once and keeps input order.
let running = 0, peak = 0;
const out = await mapLimit([30, 10, 20, 5], 2, async (ms) => { running++; peak = Math.max(peak, running); await new Promise((r) => setTimeout(r, ms)); running--; return ms; });
assert.deepEqual(out, [30, 10, 20, 5]);
assert.equal(peak, 2);
console.log("ok");
