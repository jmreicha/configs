---
description: "Bootstrap a new AI agent host with scoped 1Password access for homelab credentials"
---

# Agent bootstrap

How to give a new agent (Claude Code, OpenClaw, etc.) on a new host read access
to homelab credentials through 1Password, without plaintext secrets on disk or in
prompts.

## 1. Create a service account (in 1Password, by a human)

Docs: <https://developer.1password.com/docs/service-accounts/get-started/>

- One service account per agent host, so access can be revoked individually.
- Grant it only the vault(s) the agent needs, read-only unless it must write.
  Service accounts can't access Personal/Private or the default Shared vault, so
  keep agent-usable logins in a dedicated vault (default here: `Pinchy`).
- Copy the token (`ops_...`). It's shown once.

## 2. Run the bootstrap on the agent host

```bash
git clone https://github.com/jmreicha/configs.git
cd configs
./bin/bootstrap-agent                      # prompts for the token (hidden)
# unattended:
OP_SERVICE_ACCOUNT_TOKEN=ops_... OP_VAULT=Pinchy ./bin/bootstrap-agent
```

It installs Homebrew if missing, installs `op` (`brew install --cask 1password-cli`),
writes the token to `~/.config/op/credentials` (mode 600), loads it in bash/zsh,
and verifies the vault is visible. Re-running is safe.

Never put the token in chat, git, or a shell history line on a shared machine.

## 3. Verify

```bash
op whoami        # User Type: SERVICE_ACCOUNT
op vault list
op item list --vault Pinchy
```

## Rules for agents

- Fetch secrets at use time: `op read "op://<vault>/<item>/<field>"`.
- Pass secrets via env vars or stdin, never as literal values in commands you echo.
- Never print, log, or write secret values to notes, memory, files, or chat.
  Refer to them by `op://` reference instead.
- If an item is missing or the vault isn't visible, ask the human; don't hunt
  for credentials elsewhere.
- Non-interactive shells may not read rc files. Load the token explicitly:
  `export OP_SERVICE_ACCOUNT_TOKEN="$(tr -d '[:space:]' < ~/.config/op/credentials)"`

## Revoke

Delete or rotate the service account in 1Password, then on the host:
`rm ~/.config/op/credentials`.

## Gotcha

When `OP_SERVICE_ACCOUNT_TOKEN` is set, `op` uses the service account instead of
your personal account (breaking `op plugin run` and desktop-app integration).
That's why the shell only loads it when `~/.config/op/credentials` exists; don't
create that file on personal machines.
