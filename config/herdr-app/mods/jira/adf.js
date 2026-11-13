// Jira returns descriptions and comments as ADF (Atlassian's rich-text JSON); TextView wants markdown.

function marked(text, marks = []) {
  return marks.reduce((s, m) => {
    if (m.type === "strong") return `**${s}**`;
    if (m.type === "em") return `_${s}_`;
    if (m.type === "code") return `\`${s}\``;
    if (m.type === "strike") return `~~${s}~~`;
    if (m.type === "link") return `[${s}](${m.attrs?.href ?? ""})`;
    return s;
  }, text);
}

const inline = (nodes = []) => nodes.map(node).join("");
const blocks = (nodes = [], sep = "\n\n") => nodes.map(node).filter(Boolean).join(sep);
const indent = (s) => s.replace(/\n/g, "\n  ");

function node(n) {
  const c = n.content;
  switch (n.type) {
    case "doc": return blocks(c);
    case "text": return marked(n.text ?? "", n.marks);
    case "hardBreak": return "\n";
    case "paragraph": return inline(c);
    case "heading": return `${"#".repeat(n.attrs?.level ?? 1)} ${inline(c)}`;
    case "bulletList": return c.map((li) => `- ${indent(blocks(li.content, "\n"))}`).join("\n");
    case "orderedList": return c.map((li, i) => `${i + 1}. ${indent(blocks(li.content, "\n"))}`).join("\n");
    case "taskList": return c.map((t) => `- [${t.attrs?.state === "DONE" ? "x" : " "}] ${inline(t.content)}`).join("\n");
    case "codeBlock": return `\`\`\`\n${(c ?? []).map((t) => t.text ?? "").join("")}\n\`\`\``;
    case "blockquote": return blocks(c).split("\n").map((l) => `> ${l}`).join("\n");
    case "rule": return "---";
    case "inlineCard": case "blockCard": case "embedCard": return `<${n.attrs?.url ?? ""}>`;
    case "mention": case "emoji": case "status": return n.attrs?.text ?? "";
    case "date": return n.attrs?.timestamp ? new Date(Number(n.attrs.timestamp)).toISOString().slice(0, 10) : "";
    case "tableRow": return `| ${c.map((cell) => blocks(cell.content, " ").replace(/\|/g, "\\|").replace(/\n/g, " ")).join(" | ")} |`;
    // Markdown only renders a table after a header separator, so add one under the first row.
    case "table": {
      const rows = c.map(node), cols = c[0]?.content?.length ?? 0;
      return [rows[0], `|${" --- |".repeat(cols)}`, ...rows.slice(1)].join("\n");
    }
    case "mediaSingle": case "mediaGroup": case "media": return "_[attachment]_";
    // Panels, expands and anything newer: keep the text.
    default: return c ? blocks(c) : n.text ?? "";
  }
}

export function adfToMarkdown(doc) {
  if (!doc) return "";
  if (typeof doc === "string") return doc;
  return node(doc).trim();
}
