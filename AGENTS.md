# Installing CatalEx 0.1.35 (for agents)

This repository holds built releases of CatalEx `0.1.35`: binaries as
GitHub Release assets on [`v0.1.35`](https://github.com/catalex-ai/catalex-builds/releases/tag/v0.1.35),
the install scripts under [`install/`](install/), the [`catalex` command reference](docs/cli/catalex.md)
and [`latest.json`](latest.json). It holds no source code and is written by
the release pipeline; do not edit it.

## Index

Start from the task. Read the linked guide in full before following it.

| Task | Read |
| --- | --- |
| Install CatalEx and set it up end to end with CatalEx Cloud | [https://docs.catalex.co/getting-started/agent-setup.md](https://docs.catalex.co/getting-started/agent-setup.md) |
| Make an existing agent (yourself) reachable in CatalEx chats, Slack or WhatsApp | [https://docs.catalex.co/agents/add-an-agent.md](https://docs.catalex.co/agents/add-an-agent.md) |
| Look up any `catalex` command, flag or example | [`docs/cli/catalex.md`](docs/cli/catalex.md), or `catalex <command> --help` |
| Install by hand | [Install the client first](#install-the-client-first) below |
| Download links, checksums and versions | [`latest.json`](latest.json) |

Everything installs from `https://downloads.catalex.co`; no GitHub access is needed.

How CatalEx runs an agent: for each chat it starts the agent's own Claude Code
or Codex in the agent's folder and gives it CatalEx's chat tools. An agent
therefore needs no SDK or code change: its folder's instructions and settings
are what CatalEx runs.

## Rules

- Install only from CatalEx's releases on downloads.catalex.co, and only after checksum
  verification; the installers stop on any mismatch. Never bypass that check.
- Use the `catalex` command for configuration and lifecycle. Do not write
  CatalEx configuration or databases yourself.
- Never print or store a token.
- Ask before `catalex uninstall --purge`; it deletes saved data.

## Install the client first

`install/catalex.sh` installs `catalex` into `~/.local/bin`, puts that folder
on the login shell's `PATH` and, on macOS arm64, installs the CatalEx app. It
asks nothing, verifies every download and sets nothing up.

```sh
curl -fsSL https://downloads.catalex.co/install/catalex.sh -o /tmp/catalex-install.sh
sh /tmp/catalex-install.sh --yes --no-launch --version 0.1.35
~/.local/bin/catalex install service web --version 0.1.35
~/.local/bin/catalex install status --json
~/.local/bin/catalex setup --preset cloud --native-providers claude --start
```

The installer leaves CatalEx running when it finishes (it waits up to
`CATALEX_START_TIMEOUT` seconds, default 120, and says so); `--no-launch` only
keeps the app window closed until `catalex setup --start`. `--no-app` installs
no app. `--yes` quits a running CatalEx that the
update must replace. `catalex install` installs only the named components
(`catalex`, `service`, `web`, `app`) from one verified release, without setup or
sign-in. `catalex update --check` reports newer releases; `catalex update
--restart` replaces owned components while CatalEx runs.
`catalex uninstall [COMPONENT...]` keeps saved data unless `--purge`.

Signing in to CatalEx Cloud needs the person: `catalex login --google` opens
their browser.

## Verify

```sh
~/.local/bin/catalex status                 # components and their states
~/.local/bin/catalex install status --json  # where each component is installed
```

A URL alone is not proof of a working agent. Report each component's state,
and claim a working chat only after a real reply in a native chat.

## Stop or remove

```sh
catalex stop --all
catalex uninstall    # removes every installed component, keeps saved data
```
