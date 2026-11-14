# Install CatalEx 0.1.11

Install, update and uninstall guide for CatalEx release `0.1.11` (GitHub
Release [`v0.1.11`](https://github.com/catalex-ai/catalex-builds/releases/tag/v0.1.11)). This
repository holds built releases, install scripts and agent skills only; it
contains no CatalEx source code. It is written by the release pipeline: do not
edit it by hand.

CatalEx is an early development build, not a supported product release.

## What CatalEx is

CatalEx connects AI agents you already run (Claude Code, Codex) to the places
people talk to them: chats in the CatalEx app, Slack and WhatsApp. It is
installed from these parts:

| Part | What it does |
| --- | --- |
| CatalEx app | The macOS app: set up CatalEx, add agents and chat with them. |
| `catalex` command | The terminal equivalent of the app; also installs and updates the other parts. |
| Service | Runs your agents on this computer. Installed and started by `catalex`. |
| Web app | The interface the CatalEx app shows. Installed by `catalex`; `catalex open` and the app run it. |

## Install

### The Mac app

[Download CatalEx for Mac (Apple silicon)](https://github.com/catalex-ai/catalex-builds/releases/latest/download/CatalEx-arm64.dmg),
open the disk image and drag CatalEx to Applications. The build is not yet
notarized, so on first open choose **System Settings > Privacy & Security >
Open Anyway**. The app's setup wizard signs you in and installs the rest.

### Install the app: one command

```sh
curl -fsSL https://raw.githubusercontent.com/catalex-ai/catalex-builds/main/install/catalex.sh | sh
```

[`install/catalex.sh`](install/catalex.sh) installs the `catalex` command into
`~/.local/bin` and adds that folder to your login shell's `PATH`. On a Mac with
Apple silicon it also installs the CatalEx app into `/Applications` and opens
it. Elsewhere it installs only `catalex`. It asks nothing, so it works the same
from a terminal, a pipe or an AI agent, and running it again is safe. Every
download is checked against the release's `SHA256SUMS`; nothing is installed
from a file that fails the check.

Pass options after `sh -s --`, for example
`curl -fsSL .../install/catalex.sh | sh -s -- --no-app`:

| Flag | Meaning |
| --- | --- |
| `--no-app` | Install only `catalex`, not the app. |
| `--app` | Install the app too (the default on a Mac with Apple silicon; refused elsewhere). |
| `--app-only` | Install only the app. |
| `--version V` | Install release `V` instead of the newest. |
| `--bin-dir DIR`, `--no-path` | Put `catalex` in `DIR`; leave `PATH` alone. |
| `--apps-dir DIR`, `--no-launch` | Put the app in `DIR` (absolute) instead of `/Applications`; do not open it now. |
| `--yes` | Quit a running CatalEx that must be replaced. |
| `--from-dir DIR` | Install from a local release folder (`assets/` and `tree/`). |

Downloads use `gh` when it is signed in, else `GITHUB_TOKEN` or `GH_TOKEN`,
else an anonymous download; no account is needed.

### With your AI agent

Paste into Claude Code or Codex:

```text
Read skills/catalex-setup/SKILL.md from the catalex-ai/catalex-builds GitHub repository (raw.githubusercontent.com) and set up CatalEx on this computer.
```

To make an agent you already use reachable in CatalEx, Slack or WhatsApp, tell
that agent:

```text
Read skills/catalex-onboard-agent/SKILL.md from the catalex-ai/catalex-builds GitHub repository (raw.githubusercontent.com) and onboard yourself onto CatalEx.
```

[AGENTS.md](AGENTS.md) is the index for agents.

### Install parts on their own

With `catalex` installed, `catalex install service web` installs the service
and the web app next to it, checked the same way and without setting anything
up. `catalex install app` installs only the app. `catalex install status` shows
what is installed, from which release, and whether each file is still the one
installed.

## Requirements

- **The CatalEx app:** macOS on Apple silicon.
- **Claude Code and/or Codex**, installed and signed in on each computer that
  runs agents.
- `curl`, `tar`, and `sha256sum` or `shasum` (present on macOS).

## Set up and add an agent

The app's setup wizard does this for you. From a terminal:

```sh
catalex login --google                       # opens your browser
catalex setup --preset cloud --start         # connect this computer to CatalEx Cloud
catalex agents add --name my-agent --folder /absolute/folder --agent claude
catalex open                                 # open the CatalEx app
```

Use `--agent codex` for Codex. Check any time with `catalex status`.

### Sign in to Codex or Claude Code

```sh
codex login                 # Codex
claude auth login           # Claude Code
catalex providers           # installed, version, signed in
```

### Add Slack or WhatsApp

In the app, open **Settings > Channels**. From a terminal:

```sh
catalex accounts list
catalex channels add --agent=AGENT_ID --type=slack --account=ACCOUNT_ID --name=Slack
```

`catalex agents list` prints the agent IDs.

## Set up later from the terminal

When you chose **Set up later** in the app, choose **Set Up CatalEx...** in the
menu bar whenever you are ready, or run:

```sh
catalex setup --preset cloud --start
```

## When CatalEx could not start

The app's launch screen offers **Retry** and shows the log under **Show
details**. In a terminal run `catalex start`, then `catalex open`; `catalex
status` says which part is not ready.

## Update

```sh
catalex update --check     # what is installed and what is newer; changes nothing
catalex update             # replace everything the installers installed
```

`catalex update` updates every part the installers recorded, never downgrades,
and keeps a command that was changed since it was installed. While CatalEx runs
it stops and asks for `--restart`, which stops CatalEx, installs the new
release and starts it again. A running CatalEx app is replaced only with
`--yes`, which quits it first. Saved chats and settings are kept.

## Uninstall

```sh
catalex uninstall                  # everything the installers installed; saved data is kept
catalex uninstall service          # only the service; the other parts stay
catalex uninstall app              # only the CatalEx app (quit it first)
```

CatalEx is stopped first. A part you do not name keeps its files and its place
on `PATH`; the `PATH` block goes with the last command. A command changed since
it was installed is kept. `catalex uninstall --purge` also deletes saved
conversations, credentials and the release files, so installing again starts
afresh. Use it only when you mean it.

## Restart CatalEx

```sh
catalex stop --all
catalex start
```

Saved agents, channels and conversations are retained.

## Command reference

Every command has `--help` with examples; `--json` prints one result for
scripts. The complete reference, every command with its flags and examples, is
[docs/cli/catalex.md](docs/cli/catalex.md).

## Troubleshooting

| Symptom | What to do |
| --- | --- |
| `checksum mismatch` | The download was damaged or replaced. Delete it and download again; never install a file that fails the check. |
| An AI provider command is missing | Install the provider using its own instructions, then sign in as the user that runs agents. |
| macOS says the app is damaged or from an unidentified developer | The build is not notarized: right-click > **Open**, or **System Settings > Privacy & Security > Open Anyway**. |
| `catalex: command not found` | Open a new terminal: the installer's `PATH` change reaches new ones only. If the installer could not change your profile (or you used `--no-path`), add `export PATH="$HOME/.local/bin:$PATH"` to your shell's login profile, or run `~/.local/bin/catalex`. |
| Anything else | `catalex status` shows what is running and why it stopped. |

Agents installing CatalEx should read [AGENTS.md](AGENTS.md).
