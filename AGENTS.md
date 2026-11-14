# Installing CatalEx 0.1.10 (for agents)

This repository holds built releases of CatalEx `0.1.10`: binaries as
GitHub Release assets on [`v0.1.10`](https://github.com/catalex-ai/catalex-builds/releases/tag/v0.1.10),
the install scripts under [`install/`](install/), the agent skills under
[`skills/`](skills/), the [`catalex` command reference](docs/cli/catalex.md)
and [`latest.json`](latest.json). It holds no source code and is written by
the release pipeline; do not edit it.

## Index

Start from the task. Read a skill's `SKILL.md` in full before following it.

| Task | Read |
| --- | --- |
| Install CatalEx and set it up end to end with CatalEx Cloud; repair, update or remove it | [`skills/catalex-setup/SKILL.md`](skills/catalex-setup/SKILL.md) |
| Make an existing agent (yourself) reachable in CatalEx chats, Slack or WhatsApp | [`skills/catalex-onboard-agent/SKILL.md`](skills/catalex-onboard-agent/SKILL.md) |
| An agent package's setup says to add CatalEx: install CatalEx if needed, then onboard each of its agents | [`skills/catalex-agent-addon/SKILL.md`](skills/catalex-agent-addon/SKILL.md) |
| Look up any `catalex` command, flag or example | [`docs/cli/catalex.md`](docs/cli/catalex.md), or `catalex <command> --help` |
| Install by hand | [Install the client first](#install-the-client-first) below |
| Download links, checksums and versions | [`latest.json`](latest.json) |

Fetch any file here without cloning:

```sh
curl -fsSL https://raw.githubusercontent.com/catalex-ai/catalex-builds/main/skills/catalex-onboard-agent/SKILL.md
```

How CatalEx runs an agent: for each chat it starts the agent's own Claude Code
or Codex in the agent's folder and gives it CatalEx's chat tools. An agent
therefore needs no SDK or code change: its folder's instructions and settings
are what CatalEx runs.

## Rules

- Install only from this repository's releases, and only after checksum
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
curl -fsSL https://raw.githubusercontent.com/catalex-ai/catalex-builds/main/install/catalex.sh -o /tmp/catalex-install.sh
sh /tmp/catalex-install.sh --yes --no-launch --version 0.1.10
~/.local/bin/catalex install service web --version 0.1.10
~/.local/bin/catalex install status --json
~/.local/bin/catalex setup --preset cloud --native-providers claude --start
```

`--no-launch` keeps the app closed until `catalex setup --start` has CatalEx
running; `--no-app` installs no app. `--yes` quits a running CatalEx that the
update must replace. `catalex install` installs only the named components
(`catalex`, `service`, `web`, `app`) from one verified release, without setup or
sign-in. `catalex update --check` reports newer releases; `catalex update
--restart` replaces owned components while CatalEx runs.
`catalex uninstall [COMPONENT...]` keeps saved data unless `--purge`.

Signing in to CatalEx Cloud needs the person: `catalex login --google` opens
their browser.

## Skills

| Skill | Use |
| --- | --- |
| [`catalex-setup`](skills/catalex-setup/SKILL.md) | Installs CatalEx, sets it up, adds a first agent and verifies a chat reply. Works before anything is installed. |
| [`catalex-onboard-agent`](skills/catalex-onboard-agent/SKILL.md) | An agent onboards itself: makes its folder's instructions, MCP servers and tool limits apply when CatalEx starts it, registers itself, adds channels and verifies a reply. |
| [`catalex-agent-addon`](skills/catalex-agent-addon/SKILL.md) | The line an agent package adds to its own setup instructions; installs and sets up CatalEx when missing and onboards each of the package's agents. |

For Claude Code, copy a skill folder to `~/.claude/skills/<name>`, or read it
straight from this repository as shown above.

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
