import { exec } from "herdr";

// How each agent CLI lists its models and takes a model and reasoning level.
// A model is { id, label?, efforts: string[], effort? } (effort: its default).

const CLAUDE_EFFORTS = ["low", "medium", "high", "xhigh", "max"];
const PI_THINKING = ["off", "minimal", "low", "medium", "high", "xhigh", "max"];

async function run(command, args, on) {
  let r;
  try { r = await exec(command, args, { on }); } catch { r = null; }
  // Shell functions (pi often is one) only exist inside an interactive shell.
  if (!r || r.code !== 0) r = await exec("sh", ["-c", `"\${SHELL:-sh}" -ic '${[command, ...args].join(" ")}'`], { on });
  if (r.code !== 0) throw new Error((r.stderr || r.stdout).trim().split("\n")[0] || `${command} failed`);
  return r.stdout;
}

function codexModels(out) {
  return JSON.parse(out).models.filter((m) => m.visibility === "list").map((m) => ({
    id: m.slug, label: m.display_name,
    efforts: (m.supported_reasoning_levels ?? []).map((l) => l.effort), effort: m.default_reasoning_level,
  }));
}

function cursorModels(out) {
  return out.split("\n").map((l) => /^(\S+) - (.+)$/.exec(l.trim())).filter(Boolean)
    .map(([, id, label]) => ({ id, label, efforts: [] }));
}

function piModels(out) {
  return out.split("\n").slice(1).map((l) => l.trim().split(/\s+/)).filter((c) => c.length >= 5)
    .map(([provider, model, , , thinking]) => ({ id: `${provider}/${model}`, efforts: thinking === "yes" ? PI_THINKING : [] }));
}

function lineModels(out) {
  return out.split("\n").map((l) => l.trim()).filter((l) => /^\S+\/\S+$/.test(l)).map((id) => ({ id, efforts: [] }));
}

const ADAPTERS = {
  claude: {
    models: async () => ["fable", "opus", "sonnet", "haiku"].map((id) => ({ id, efforts: CLAUDE_EFFORTS, effort: "high" })),
    flags: (model, effort) => [...(model ? ["--model", model] : []), ...(effort ? ["--effort", effort] : [])],
  },
  codex: {
    models: async (on) => codexModels(await run("codex", ["debug", "models"], on)),
    flags: (model, effort) => [...(model ? ["-m", model] : []), ...(effort ? ["-c", `model_reasoning_effort=${effort}`] : [])],
  },
  gemini: {
    models: async () => [],
    flags: (model) => (model ? ["--model", model] : []),
  },
  opencode: {
    models: async (on) => lineModels(await run("opencode", ["models"], on)),
    flags: (model) => (model ? ["--model", model] : []),
  },
  cursor: {
    models: async (on) => cursorModels(await run("cursor-agent", ["--list-models"], on)),
    flags: (model) => (model ? ["--model", model] : []),
  },
  pi: {
    models: async (on) => piModels(await run("pi", ["--list-models"], on)),
    flags: (model, effort) => [...(model ? ["--model", model] : []), ...(effort && effort !== "off" ? ["--thinking", effort] : [])],
  },
};

const ALIASES = { "cursor-agent": "cursor", agent: "cursor" };

// The adapter for a knownAgents() entry, by its key or the program it runs; null: no model choice.
export function adapterFor(agent) {
  const name = ALIASES[agent.key] ?? agent.key;
  const program = agent.run?.[0]?.split("/").pop();
  return ADAPTERS[name] ?? ADAPTERS[ALIASES[program] ?? program] ?? null;
}
