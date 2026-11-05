// Same https-only opener as the github mod; mods cannot import across folders.
import { exec } from "herdr";
import { safeUrl } from "./urls.js";

export function openUrl(url) {
  const safe = safeUrl(url);
  if (safe) exec("open", ["--", safe]).catch(() => {});
}
