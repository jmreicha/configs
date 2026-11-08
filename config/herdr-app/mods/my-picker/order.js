// All spaces up front so typing filters them; busy ones (blocked first) lead, nothing folds into "earlier".
export function order(groups) {
  const shown = groups.filter((p) => p.ctxs.length);
  const busy = shown.filter((p) => p.w.status).sort((a, b) => (b.w.status === "blocked") - (a.w.status === "blocked"));
  return [...busy, ...shown.filter((p) => !p.w.status)];
}
