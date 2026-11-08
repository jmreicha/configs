// Run: node schedule.test.mjs
import assert from "node:assert/strict";
import { kindsFor, AUTO_REFRESH_MS } from "./schedule.js";

// The timer only reloads PRs; issues wait for Refresh, a repo switch or a filter change.
assert.deepEqual(kindsFor("timer"), ["prs"]);
assert.deepEqual(kindsFor("manual"), ["prs", "issues"]);
assert.equal(AUTO_REFRESH_MS, 30 * 60 * 1000);
console.log("ok");
