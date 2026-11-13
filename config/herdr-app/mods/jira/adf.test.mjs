// Run: node adf.test.mjs
import assert from "node:assert/strict";
import { adfToMarkdown } from "./adf.js";

const doc = (...content) => ({ type: "doc", content });
const p = (...content) => ({ type: "paragraph", content });
const text = (t, marks) => ({ type: "text", text: t, ...(marks && { marks }) });

assert.equal(adfToMarkdown(null), "");
assert.equal(adfToMarkdown(doc(p(text("Hello "), text("bold", [{ type: "strong" }])))), "Hello **bold**");
assert.equal(adfToMarkdown(doc(p(text("site", [{ type: "link", attrs: { href: "https://x.io" } }])))), "[site](https://x.io)");
assert.equal(adfToMarkdown(doc(p({ type: "inlineCard", attrs: { url: "https://x.io/a" } }))), "<https://x.io/a>");
assert.equal(adfToMarkdown(doc(p({ type: "mention", attrs: { text: "@Amy" } }))), "@Amy");
assert.equal(adfToMarkdown(doc({ type: "heading", attrs: { level: 2 }, content: [text("Title")] })), "## Title");
assert.equal(adfToMarkdown(doc({ type: "bulletList", content: [{ type: "listItem", content: [p(text("a"))] }, { type: "listItem", content: [p(text("b"))] }] })), "- a\n- b");
assert.equal(adfToMarkdown(doc({ type: "orderedList", content: [{ type: "listItem", content: [p(text("a"))] }] })), "1. a");
assert.equal(adfToMarkdown(doc({ type: "taskList", content: [{ type: "taskItem", attrs: { state: "DONE" }, content: [text("done")] }, { type: "taskItem", attrs: { state: "TODO" }, content: [text("todo")] }] })), "- [x] done\n- [ ] todo");
assert.equal(adfToMarkdown(doc({ type: "codeBlock", content: [text("ls -la")] })), "```\nls -la\n```");
assert.equal(adfToMarkdown(doc(p(text("a")), p(text("b")))), "a\n\nb");
// Unknown nodes keep their text rather than vanishing.
assert.equal(adfToMarkdown(doc({ type: "panel", content: [p(text("note"))] })), "note");
// Tables need a header separator row, or markdown shows raw pipes.
const cell = (type, t) => ({ type, content: [p(text(t))] });
assert.equal(adfToMarkdown(doc({ type: "table", content: [
  { type: "tableRow", content: [cell("tableHeader", "Repo"), cell("tableHeader", "Modules")] },
  { type: "tableRow", content: [cell("tableCell", "org"), cell("tableCell", "folder")] },
] })), "| Repo | Modules |\n| --- | --- |\n| org | folder |");
console.log("ok");
