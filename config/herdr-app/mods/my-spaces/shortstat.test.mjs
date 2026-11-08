// Run: node shortstat.test.mjs
import assert from "node:assert/strict";
import { shortstat, untracked } from "./shortstat.js";

assert.deepEqual(shortstat(" 3 files changed, 12 insertions(+), 4 deletions(-)\n"), { added: 12, removed: 4 });
assert.deepEqual(shortstat(" 1 file changed, 1 insertion(+)\n"), { added: 1, removed: 0 });
assert.deepEqual(shortstat(" 1 file changed, 2 deletions(-)\n"), { added: 0, removed: 2 });
assert.deepEqual(shortstat(""), { added: 0, removed: 0 });
// `grep -Ic ''` output: "file:count" per file, a bare count when only one file.
assert.equal(untracked("a.js:10\nb/c.md:5\n"), 15);
assert.equal(untracked("7\n"), 7);
assert.equal(untracked("weird:name.txt:3\n"), 3);
assert.equal(untracked(""), 0);
console.log("ok");
