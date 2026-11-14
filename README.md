# CatalEx

Put the AI agents you already use, Claude Code and Codex, to work in chats,
Slack and WhatsApp, from your own computer.

[**Download for Mac (Apple silicon)**](https://github.com/catalex-ai/catalex-builds/releases/latest/download/CatalEx-arm64.dmg)

Latest release: **0.1.12**
([release notes](https://github.com/catalex-ai/catalex-builds/releases/tag/v0.1.12)).

## Install from a terminal

```sh
curl -fsSL https://raw.githubusercontent.com/catalex-ai/catalex-builds/main/install/catalex.sh | sh
```

This installs the `catalex` command and, on a Mac with Apple silicon, the
CatalEx app. It asks nothing, checks every download against the release's
`SHA256SUMS` and is safe to run again. Pass options after `sh -s --`, for
example `sh -s -- --no-app`.

## Requirements

- macOS on Apple silicon for the app.
- Claude Code or Codex, installed and signed in on the computer that runs your
  agents.
- `curl`, `tar` and `sha256sum` or `shasum`.

## Quickstart

1. **Install.** Open the downloaded app, or run the command above.
2. **Sign in.** The app's setup wizard signs you in to CatalEx Cloud in your
   browser. From a terminal: `catalex setup --preset cloud --start`.
3. **Add an agent and chat.** Pick a folder where Claude Code or Codex works,
   add it as an agent, and open a chat with it in the app. From a terminal:
   `catalex agents add --name my-agent --folder /absolute/folder --agent claude`.

## Documentation

- [docs.catalex.co](https://docs.catalex.co): product documentation.
- [INSTALL.md](INSTALL.md): install, update and uninstall, step by step.
- [AGENTS.md](AGENTS.md): for coding agents that set CatalEx up for you.
- [Command reference](docs/cli/catalex.md): every `catalex` command.
- [Releases](https://github.com/catalex-ai/catalex-builds/releases): all versions.

## What is in a release

| File | What it is |
| --- | --- |
| `CatalEx-arm64.dmg` | The CatalEx app for macOS on Apple silicon. |
| `catalex-<version>-<os>-<arch>.tar.gz` | The `catalex` command. |
| `catalex-service-<version>-<os>-<arch>.tar.gz` | Runs your agents on a computer. |
| `catalex-web-<version>-<os>-<arch>.tar.gz` | The web app that the CatalEx app shows. |
| `SHA256SUMS` | Checksums of every file above. |

Releases carry binaries only, no source code.
