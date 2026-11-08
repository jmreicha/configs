// PRs change state (CI, reviews) on their own; issues rarely matter between manual looks.
export const AUTO_REFRESH_MS = 30 * 60 * 1000;
export const kindsFor = (reason) => (reason === "timer" ? ["prs"] : ["prs", "issues"]);
