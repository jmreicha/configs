// Pure helpers for the Jira panel, kept apart from the UI so node can test them.
import { adfToMarkdown } from "./adf.js";

export const SEARCH_ARGS = ["jira", "workitem", "search", "--jql",
  "assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC", "--paginate", "--json"];
const DETAIL_FIELDS = "summary,status,priority,issuetype,reporter,assignee,parent,labels,components,fixVersions,duedate,subtasks,statuscategorychangedate,description,comment,issuelinks,created,updated";
export const viewArgs = (key) => ["jira", "workitem", "view", key, "--fields", DETAIL_FIELDS, "--json"];
export const childArgs = (key) => ["jira", "workitem", "search", "--jql", `parent = ${key} AND statusCategory != Done ORDER BY updated DESC`, "--limit", "50", "--json"];
// Search can't return parent, so each ticket's parent comes from its own small view.
export const parentArgs = (key) => ["jira", "workitem", "view", key, "--fields", "parent", "--json"];
export const prSearchArgs = (key) => ["search", "prs", key, "--limit", "20", "--json", "number,title,body,url,state,isDraft,repository,updatedAt"];

// The drilled-in view is about what is left; finished work is noise there.
export const isOpen = (issue) => issue.fields?.status?.statusCategory?.key !== "done";

export const projectOf = (key) => key.split("-")[0];

// What you're working on floats up; blocked is called out before the queue.
export function statusRank(issue) {
  const s = issue.fields?.status, name = s?.name ?? "";
  if (s?.statusCategory?.key === "done") return 4;
  if (/block/i.test(name)) return 1;
  if (s?.statusCategory?.key === "indeterminate") return 0;
  if (/backlog/i.test(name)) return 3;
  return 2;
}

// Array sort is stable, so Jira's own order holds within a status.
export const byStatus = (issues) => [...issues].sort((a, b) => statusRank(a) - statusRank(b));

export function groupByProject(issues) {
  const groups = new Map();
  for (const i of issues) {
    const p = projectOf(i.key);
    if (!groups.has(p)) groups.set(p, []);
    groups.get(p).push(i);
  }
  return [...groups].sort(([a], [b]) => a.localeCompare(b)).map(([project, list]) => ({ project, issues: byStatus(list) }));
}

export function matches(issue, { text, projects, statuses }) {
  if (projects.size && !projects.has(projectOf(issue.key))) return false;
  if (statuses.size && !statuses.has(issue.fields?.status?.name)) return false;
  const q = text.trim().toLowerCase();
  return !q || `${issue.key} ${issue.fields?.summary ?? ""}`.toLowerCase().includes(q);
}

export function siteFrom(authStatus) {
  return authStatus.match(/Site:\s*(\S+)/)?.[1] ?? null;
}
export const browseUrl = (site, key) => `https://${site}/browse/${key}`;

export function relatedPrs(prs, key) {
  const re = new RegExp(`\\b${key}(?!\\d)`, "i");
  return prs.filter((p) => re.test(`${p.title} ${p.body ?? ""}`));
}

export function ago(iso, now = Date.now()) {
  const minutes = Math.max(0, Math.round((now - Date.parse(iso)) / 60000));
  if (minutes < 60) return `${minutes}m`;
  if (minutes < 1440) return `${Math.round(minutes / 60)}h`;
  return `${Math.round(minutes / 1440)}d`;
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
// Read the calendar day as written, so a late-evening timestamp doesn't shift by timezone.
function day(iso) {
  const [y, m, d] = iso.slice(0, 10).split("-").map(Number);
  return `${MONTHS[m - 1]} ${d}, ${y}`;
}

// The "Details" block as label/value rows; tone names a theme color, chips render as pills.
export function detailRows(f, now = Date.now()) {
  const names = (list) => (list ?? []).map((x) => x.name ?? x).filter(Boolean);
  // Due dates are plain days; past the end of that day counts as overdue.
  const overdue = f.duedate && Date.parse(`${f.duedate}T23:59:59`) < now;
  return [
    { label: "Reporter", value: f.reporter?.displayName },
    { label: "Assignee", value: f.assignee?.displayName },
    { label: "Created", value: f.created && day(f.created), note: f.created && `${ago(f.created, now)} ago` },
    { label: "Updated", value: f.updated && day(f.updated), note: f.updated && `${ago(f.updated, now)} ago` },
    { label: "In status", value: f.statuscategorychangedate && ago(f.statuscategorychangedate, now) },
    { label: "Due", value: f.duedate && day(f.duedate), ...(overdue && { note: "overdue", tone: "blocked" }) },
    { label: "Parent", value: f.parent?.key && `${f.parent.key} ${f.parent.fields?.summary ?? ""}`.trim(), key: f.parent?.key },
    { label: "Labels", chips: names(f.labels) },
    { label: "Components", chips: names(f.components) },
    { label: "Fix versions", chips: names(f.fixVersions) },
  ].filter((r) => r.value || r.chips?.length);
}

export const linkedWork = (links = []) => links.map((l) => l.outwardIssue
  ? { relation: l.type?.outward, issue: l.outwardIssue }
  : { relation: l.type?.inward, issue: l.inwardIssue });

export function prTone(pr) {
  if (pr.isDraft) return "draft";
  return (pr.state ?? "").toLowerCase();
}

export function parentOf(issue) {
  const p = issue.fields?.parent;
  return p?.key ? { key: p.key, summary: p.fields?.summary ?? "", epic: p.fields?.issuetype?.name === "Epic" } : null;
}

// Like Promise.all over items, but at most n in flight so acli isn't hit 50 times at once.
export async function mapLimit(items, n, fn) {
  const out = new Array(items.length);
  let next = 0;
  const worker = async () => { while (next < items.length) { const i = next++; out[i] = await fn(items[i], i); } };
  await Promise.all(Array.from({ length: Math.min(n, items.length) }, worker));
  return out;
}
