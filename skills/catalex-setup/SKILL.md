---
name: catalex-setup
description: Download the catalex command with CatalEx's one-command installer and use it to set CatalEx up end to end (connected to CatalEx Cloud), add a first agent and verify a reply in a CatalEx native chat. Also repairs, updates, stops or uninstalls a setup.
---

# Set up CatalEx with `catalex`

`catalex` is the command-line equivalent of the CatalEx app. Do the whole
setup with the installer and `catalex` commands. Never edit CatalEx
configuration, databases or credential files, never call its APIs
yourself (`curl`), never start or kill its processes by hand, and never stop a
process you did not start.

Ask the person only for what needs them: a provider sign-in and the
CatalEx Cloud Google sign-in in their browser. Do not explain
servers, databases, tokens or modes unless they ask; decide everything else
and proceed. Never ask for a secret in chat, put one on a command line, or print
one (`cat`, `echo`, logs): secrets reach `catalex` only as a private file path
(`--token-file`, mode 0600) or piped standard input that the person supplies.

Every `catalex` command accepts `--json` and prints one `catalex.result.v1`
result; use it when you need fields. Read `catalex <command> --help` before
using a flag not shown here.

## 1. Install `catalex`

Skip this step when `catalex version` works. Otherwise download it with the
one-command installer from the public `catalex-ai/catalex-builds` repository
(no GitHub account or token is needed):

```sh
curl -fsSL https://downloads.catalex.co/install/catalex.sh | sh -s -- --no-launch
export PATH="$HOME/.local/bin:$PATH"
catalex version
```

If `downloads.catalex.co` is unreachable, use the same script from GitHub: `https://raw.githubusercontent.com/catalex-ai/catalex-builds/main/install/catalex.sh`.

The installer asks nothing. It verifies every download against the release's
`SHA256SUMS`, puts `~/.local/bin` on new login shells' `PATH` (the `export`
covers this shell) and, on a Mac with Apple Silicon, installs the CatalEx app
too. `--no-launch` keeps the app closed until setup has CatalEx running
(step 4 opens it). Add `--no-app` only when the person says they do not want
the app; elsewhere the installer installs only `catalex`. Running it again is
safe. To install from a local release build
folder (`assets/` and `tree/`) instead of GitHub, run that folder's
`tree/install/catalex.sh` with `--from-dir FOLDER`, and add the same
`--from-dir FOLDER` to `catalex install` and `catalex update` below.

## 2. The setup

Use CatalEx Cloud without asking: agents and native chats run on this
computer, CatalEx Cloud carries their messages, and the person needs no
server, database or public address. The setup command (step 4) is
`catalex setup --preset cloud`.

## 3. Install the components

```sh
catalex install
catalex install status
```

A plain `catalex install` installs everything this computer needs: the
service that runs agents, the web app and, on macOS with Apple Silicon, the
app. To install only some pieces, name them (`catalex install service web`).
Each one is verified the same way and lands beside `catalex`, except `web`,
which stays off `PATH` in the installation folder: it is not a command for the
person, and `catalex open` runs it. Nothing is set up yet.

## 4. Providers, then setup

Agents run on Codex or Claude Code, installed and signed in on this computer.

```sh
catalex providers
```

Choose the providers the person uses (`claude`, `codex` or both). If a chosen
provider is missing, too old or signed out, stop and ask the person: they
install or update it themselves, or sign in with
`catalex providers login claude` (or `codex`), which opens the provider's own
sign-in for them to complete. Never sign in for them. Check `catalex providers`
again before continuing. Then set up and start:

```sh
catalex setup --preset cloud --native-providers claude --start --no-launch
catalex status
```

For CatalEx Cloud, `catalex setup --preset cloud ...` (with or without
`--start`) first signs in with Google when this computer has no CatalEx sign-in:
it opens a sign-in page in the person's browser, prints the same link, joins this
computer to the account and then sets up. Tell the person in
plain words, for example: "A CatalEx Cloud sign-in page has opened in your
browser. Sign in with Google there; I'll carry on as soon as you're done. If
it didn't open, use this link: ...". Do not wait for them to reply: the
setup command itself waits, confirms the Google account they chose, and the
page then says they can close it. Run it with a long timeout (up to ten
minutes; in Claude Code, in the background). If sign-in expires or the
person cancels, the command says so; run it again to start a new sign-in.
If the person does not want to sign in now, use
`catalex setup --mode native_chat --native-providers claude --start` instead:
native chats work, and they can connect CatalEx Cloud later with `catalex setup --preset cloud --start`.

After setup, `catalex providers` lists both providers with a `CONNECTED`
column. To use another installed, signed-in provider later, connect it; this
keeps the setup and its agents and needs no stop or start:

```sh
catalex providers connect codex
```

`catalex providers discover` checks them again; `catalex providers disconnect
codex` stops using one, and is refused (`PROVIDER_IN_USE`) while an agent uses
it.

`--no-launch` keeps the app closed while you finish; step 5 opens it once the
agent has replied. Without `--no-launch`, setup opens the app as soon as
CatalEx runs (the result's `app_launch` is `requested`).

Setup reuses saved choices, so rerunning the same command after an
interruption or a fix is safe and continues where it stopped. If it reports
an occupied port, pick free ports and pass them, for example
`--control-port 53101 --service-port 53106` (see `catalex setup --help` for
all the port flags).

## 5. First agent and a verified reply

Add an agent on a provider chosen in step 4, working in a folder the person
names (default: a new empty folder such as `~/catalex-agent`). Without
`--model` it uses the provider's own default; `catalex defaults show` lists
the verified models if the person wants another.

```sh
catalex agents add --name Helper --folder /absolute/folder --agent claude
catalex channels list
catalex chats create --channel NATIVE_CHAT_CHANNEL_ID --name "Setup check" --json
printf 'Reply with exactly: CatalEx ready\n' | catalex chats send CHAT_ID --wait
```

Use the ID of the agent's `native_chat` channel from `catalex channels list`
(type `browser` on an older CatalEx) and the `data.id` of the `chats create`
result as CHAT_ID. The setup is verified only when the reply contains
`CatalEx ready`. Keep that chat. If the app is
installed, run `catalex open` unless the person asked for it to stay closed,
and tell them the app is where they chat with their agent.

## 6. Report

Report these separately, each as observed: installed (`catalex install
status`), configured and running (`catalex status` component states),
connected (CatalEx Cloud: the signed-in email), and verified (the reply in
step 5). Name anything pending, such as a provider sign-in or a channel
without its account, and the next command. Do
not claim Slack, WhatsApp or Google Chat delivery without a real exchanged
message.

## When something fails

Read the error code and message; `catalex` names the cause and the next step.
Check `catalex status` and the command's `--help`, fix the input, and rerun
the same command. To restart: `catalex stop`, then `catalex start`. Report a
failure you cannot fix through `catalex` with its exact error rather than
working around it.

## Messaging accounts, updates and removal

- Slack, WhatsApp and Google Chat: the person adds them in the CatalEx app's
  Settings > Channels; `catalex accounts list` and `catalex channels list` show
  what is saved. Never collect a secret in chat.
- WhatsApp Personal (the person's own number, linked as a device): the
  person scans the QR code that `catalex destinations setup ACCOUNT_ID
  --whatsapp_personal --action link` draws in a terminal (or enters the
  pairing code that `--value phone=+<digits>` shows); never ask for a
  password or code to type for them. Then `catalex accounts list`.
- Update: `catalex update --check`, then `catalex update` (add `--restart`
  while CatalEx is running; it stops, updates and starts it again).
- Stop or start: `catalex stop`, `catalex start`.
- Remove: `catalex uninstall` keeps saved chats and settings. Use
  `catalex uninstall --purge` only when the person explicitly asks to delete
  their data.
