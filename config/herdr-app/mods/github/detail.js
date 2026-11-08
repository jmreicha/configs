// One PR or issue, read in the side panel instead of the browser.

const FIELDS = {
  prs: "number,title,body,author,url,state,isDraft,headRefName,comments,createdAt",
  issues: "number,title,body,author,url,state,labels,comments,createdAt",
};

export function detailArgs(kind, number) {
  return [kind === "prs" ? "pr" : "issue", "view", String(number), "--json", FIELDS[kind]];
}

// Body then each comment, as one markdown document for TextView.
export function detailMarkdown(item) {
  const comments = (item.comments ?? []).map((c) =>
    `---\n\n**${c.author?.login ?? "?"}** · ${(c.createdAt ?? "").slice(0, 10)}\n\n${c.body ?? ""}`);
  return [item.body?.trim() || "_No description._", ...comments].join("\n\n");
}
