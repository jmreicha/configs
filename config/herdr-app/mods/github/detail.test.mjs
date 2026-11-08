// Run: node detail.test.mjs
import assert from "node:assert/strict";
import { detailArgs, detailMarkdown } from "./detail.js";

assert.deepEqual(detailArgs("prs", 12).slice(0, 3), ["pr", "view", "12"]);
assert.deepEqual(detailArgs("issues", 7).slice(0, 3), ["issue", "view", "7"]);

const md = detailMarkdown({
  body: "Fixes the thing.",
  comments: [{ author: { login: "amy" }, createdAt: "2026-11-01T00:00:00Z", body: "LGTM" }],
});
assert.match(md, /^Fixes the thing\./);
assert.match(md, /\*\*amy\*\*/);
assert.match(md, /LGTM/);
assert.equal(detailMarkdown({ body: "", comments: [] }), "_No description._");
console.log("ok");
