// Run: node order.test.mjs
import assert from "node:assert/strict";
import { order } from "./order.js";

const g = (name, status, n = 1) => ({ w: { name, status }, ctxs: Array(n).fill({}) });
const names = (gs) => order(gs).map((p) => p.w.name);

// Every space with tabs shows: busy first (blocked before working), then quiet ones, none folded away.
assert.deepEqual(names([g("a"), g("b", "working"), g("c", "blocked"), g("d")]), ["c", "b", "a", "d"]);
// A space whose tabs all fail the filter drops out.
assert.deepEqual(names([g("a"), g("b", null, 0)]), ["a"]);
console.log("ok");
