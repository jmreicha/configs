// `git diff --shortstat` -> line counts; git omits a side when it is zero.
export function shortstat(s) {
  const n = (re) => parseInt(s.match(re)?.[1] ?? "0", 10);
  return { added: n(/(\d+) insertions?\(\+\)/), removed: n(/(\d+) deletions?\(-\)/) };
}

// Sum of `grep -Ic ''` counts (the number after the last colon); binary files are skipped by -I.
export function untracked(s) {
  return s.split("\n").reduce((sum, line) => sum + (parseInt(line.split(":").pop(), 10) || 0), 0);
}
