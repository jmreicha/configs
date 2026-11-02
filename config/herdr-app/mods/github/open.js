import { exec } from "herdr";
import { safeUrl } from "./urls.js";

export function openUrl(url) {
  const safe = safeUrl(url);
  if (safe) exec("open", ["--", safe]).catch(() => {});
}
