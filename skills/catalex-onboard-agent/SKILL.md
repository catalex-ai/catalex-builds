---
name: catalex-onboard-agent
description: Use when an existing Claude Code or Codex agent should start working through CatalEx that is already installed and running - so people can reach it in CatalEx native chats, Slack, WhatsApp or Google Chat. The agent registers its own folder with catalex, adapts its instructions, files and tool settings so they still apply when CatalEx runs the agent, connects channels and proves it with a real reply.
---

# Onboard this agent onto CatalEx

> **Three rules; read them before anything else.**
>
> 1. **Setup and onboarding need no asking:** the person asked for them. Use
>    `--preset cloud` unless they ask otherwise; their only steps are the
>    sign-ins in their browser. **Ask before changing what the agent may do
>    or who can reach it** (file access, connected tools, web, channels,
>    message caps): suggest it, then stop and wait for a yes.
> 2. **Keep the app closed until everything else is done.** Never open the
>    CatalEx app before or during the install, sign-in or setup (it can get
>    stuck): pass `--no-launch` to the installer and to `catalex setup`.
>    Connecting the channel the person chose is part of the setup and
>    happens here in the terminal, so the app stays closed until it is
>    verified too. Write the summary in chat, then run `catalex open` as the
>    very last step, unless the person asked for the app to stay closed. Write no
>    summary document (no artifact, Sites page or file).
>    ([step 9 of agent setup](https://docs.catalex.co/getting-started/agent-setup.md))
> 3. **Never message a real person or number to test.** Test only in a
>    CatalEx native chat.

CatalEx runs your agent for you: for every chat it starts Claude Code
(`claude -p`) or Codex **in your agent folder**, gives it CatalEx's chat tools
(`relay_emit`, `relay_ask`, `relay_attach`, `relay_context`, ...) and the
`relay-communication` skill, and delivers messages from native chats, Slack,
WhatsApp and Google Chat to it. Onboarding therefore means: make your folder work when
CatalEx starts it, register it, connect channels and verify a reply.

Assume the person knows nothing about CatalEx or what it can and cannot limit.
Whenever a limit, a permission or a setting first matters (what the agent may
read or edit, the terminal, connected tools, approvals, caps), say what it
means in plain words, in a sentence or two, before you ask about it. No
internal names, only CatalEx and the agent.

Do every step with `catalex` commands and edits inside your own folder.
Never edit CatalEx configuration or databases, never call its
APIs (`curl`), never start or stop its processes yourself, and never put a
secret in chat, on a command line or in a file you print. Read
`catalex <command> --help` before using a flag not shown here; every command
takes `--json` and prints one `catalex.result.v1` result.

## 1. Check CatalEx is ready

```sh
catalex version && catalex status && catalex providers discover
```

- `catalex` missing, or `status` reports no setup: stop and follow the
  `catalex-setup` skill (or the `catalex-agent-addon` skill, which installs
  and sets everything up), then come back. With `catalex` installed,
  `catalex setup --preset cloud --native-providers claude --start` (`codex`
  for Codex) sets CatalEx up and signs in with Google; run it yourself, in the
  background or with a long timeout, because it waits up to 10 minutes while
  the person finishes the sign-in at the link it prints. If it stops with
  `DEVICE_NOT_TRUSTED`, the account already has a trusted device: the person
  trusts this device in the CatalEx app's device list (or
  `catalex devices trust CLIENT_ID` on a trusted device), then run the same
  setup again. A refusal with remedy `start_setup` means the same setup.
- The provider you run on (`claude` or `codex`) must show as installed and
  signed in. If not, ask the person to sign in
  (`catalex providers login claude`); never sign in for them. If it shows
  `CONNECTED no`, connect it with `catalex providers connect codex` (or
  `claude`); this keeps the setup and needs no stop or start.
- `native_chat` and `agent` components must be `ready` (an older CatalEx
  names the first `browser`); the CatalEx Cloud connection is needed only for
  Slack, WhatsApp or Google Chat.

## 2. Choose the agent folder

The **agent folder** is the absolute folder CatalEx starts you in. It is
usually the folder holding your own `CLAUDE.md`/`AGENTS.md` (for a packaged
agent, the per-role folder its launcher `cd`s into, such as
`doctor-agent/`). One folder can back one agent; for several roles (for
example a Patient and a Doctor assistant) onboard each folder as its own
agent. Use the existing folder; do not copy the agent elsewhere.

## 3. Check the folder

```sh
catalex agents onboard --folder /absolute/agent/folder --name "Doctor Assistant" --json
```

Nothing changes yet. `data.findings` lists what stands between the folder and
a working CatalEx agent; branch on each `code`, never on message text:

| Code | What you do |
| --- | --- |
| `repairable: true` (instructions import, CatalEx block, MCP approval, CatalEx tool permissions, registration) | Nothing yet: `--apply` in step 5 repairs them inside the folder |
| `AGENT_FOLDER_NOT_TRUSTED` with `repairable: true` | Nothing yet: choosing the folder is the person's trust decision, and `--apply` records it silently in the provider's own configuration. Do not mention it or edit `~/.claude.json` or Codex's `config.toml` yourself |
| `AGENT_FOLDER_NOT_TRUSTED` with `repairable: false` | The provider's configuration file cannot be read, so it was left untouched: ask the person to open the provider in that exact folder once and accept its trust prompt (`cd FOLDER && claude`), then check again. Folder isolation (below) does not need it |
| `RELAY_TOOLS_BLOCKED` with `repairable: false` (folder isolation) | Nothing to do and never change the folder: the agent's own permissions decide, and its replies still arrive, as plain text |
| `TOOL_HOOK_UNVERIFIED` with folder isolation (`data.isolation` `folder`) | Nothing to do: the package's own hook keeps deciding which tools run. Continue |
| `TOOL_HOOK_UNVERIFIED` otherwise | Read the folder's `PreToolUse` hook. If it is the agent's own and the agent's rules allow changing it, preserve its guards and allow only the exact minimum communication tools below; otherwise tell the person what it blocks |
| `AGENT_ISOLATION_NOT_REPRODUCIBLE` | `repairable: true` (Claude Code): `--apply` chooses folder isolation, so CatalEx starts the agent the way its launcher does and the folder stays as it is. Otherwise (Codex) stop for this agent and tell the person it needs a CatalEx-ready mode from its package. Never weaken the agent to onboard it |
| `PROVIDER_NOT_READY` | Ask the person to sign in: `catalex providers login PROVIDER` |
| `AGENT_INSTRUCTIONS_MISSING` (repairable) | `--apply` writes an instructions file holding only the CatalEx block. If the agent's real instructions live elsewhere, you chose the wrong folder: find the one holding them |
| `AGENT_FOLDER_NOT_FOUND` | Wrong folder: find the one the agent's AI starts in |
| `PERSON_AGENT_UNREACHABLE` (repairable) | Nothing yet: this agent and another saved agent run the same tool, and one of them serves one person per chat; `--apply` lets the other message it about those people (`data.sends`) |

Unless the agent uses folder isolation, also move anything else the agent's
launcher passes as flags (an instructions file, environment variables the
tools need, a pre-session script) into the folder's own files. With folder
isolation, change nothing in the folder's settings, tools or guards.

### Minimum communication access

Where the person's request and the agent's own rules permit a hook repair,
limit its exception to `ToolSearch` and these exact Claude MCP names:
`mcp__relay__relay_context`, `mcp__relay__relay_emit`,
`mcp__relay__relay_ask`, `mcp__relay__relay_validate`,
`mcp__relay__relay_history`, `mcp__relay__relay_react` and
`mcp__relay__relay_activity`. Keep optional attachments, delegation, reporting
and person tools subject to their own native rules. Never exempt the entire
CatalEx server or all skills, weaken a package guard, or change global settings
to make verification pass. Folder isolation keeps original package files intact.

## 4. Settle the person's steps

Ask for each person step in one short message, wait, then rerun step 3.
Continue when every finding left is `repairable: true`, a folder-isolation
warning above, or a `TOOL_HOOK_UNVERIFIED` you have checked. These warnings
never block `--apply`; only person steps do.

### Serve each person in their own chat

Each CatalEx chat is one person, with its own person ref. If the agent's
tools serve one person per launch (`PERSON_FIXED_IN_TOOLS`, or anything you
see in the folder: a `--patient`/`--user` flag, a default customer, a
config naming one account), switch them to the ref:

1. Find the flag that picks the person: read the tool's `--help` or its
   source (for example `--patient`, `--user`). A tool that falls back to a
   default person when the flag is missing counts too.
2. Save it with the agent. CatalEx then starts that server with the flag
   set to each chat's person ref; the agent's files, including `.mcp.json`
   and its launchers, stay exactly as they are:

   ```sh
   catalex agents onboard --folder /absolute/agent/folder --person-arg SERVER=FLAG --apply --json
   ```

   `SERVER` is the server's name in the folder's `.mcp.json`. This is
   CatalEx's own launch setting, not a change to the package, so a package
   that forbids editing its files still allows it. When the package's tool
   takes the person's details (a JSON object with a name and phone number),
   write `SERVER=FLAG,DETAILS_FLAG`, for example
   `--person-arg clinic=--patient,--patient-details`; the second flag must
   differ from the first, and CatalEx leaves it out when it has no details.
3. The tool must accept any ID of letters, digits, `_` and `-` (a ref looks
   like `ct_…`) and create the person on first use. If it accepts only fixed
   IDs, that is a change to the agent's own code: list it in the report as
   the next step.

The CatalEx block tells the agent to call `relay_person` for the person's
ref and known name. Its deprecated `channels: []` member is uniformly empty;
it does not describe where the person can be reached.

## 5. Repair and register

```sh
catalex agents onboard --folder /absolute/agent/folder --name "Doctor Assistant" --apply --json
```

`state` is `onboarded` when it worked: `data.agent.id` is AGENT_ID and
`data.agent.native_chat_channel` its native chat channel; `data.overview` (and
the text output) says what the agent can use: file reading and editing, the
terminal, the web, connected tools by name, approvals, folders, limits and
channels, with the next steps and their exact commands (the same as
`catalex agents show AGENT_ID`);
`data.changed` names the
files it repaired (without folder isolation it adds the CatalEx block,
between `catalex:begin` and `catalex:end`, to the agent's instructions, and
refreshes an outdated one; with `data.isolation` `folder` that block is the
only change in the folder). `action_required` means a person
step remains: go back to step 4. Rerunning is safe: it changes nothing twice
and reuses the saved agent.

## 6. Connect channels

The agent's native chat channel is `data.agent.native_chat_channel` from
step 5 (also in `catalex channels list --json`).

The native chat always works, so it is never the recommended stopping point:
an agent is useful once people reach it where they already talk. Recommend
one channel from the agent's context, its instructions, tools and the people
it serves:

| Who the agent serves | Recommend |
| --- | --- |
| Customers, patients or the public (bookings, support, orders) | WhatsApp: a business number, or WhatsApp Personal for a small business run from the owner's phone |
| The person themselves, friends or family (a personal assistant, a fun or hobby agent) | WhatsApp Personal |
| A team or workplace | Slack, or Google Chat when the team uses Google Workspace |
| Anyone who should try it once, with nothing to install (a demo, an agent to show off) | Shared link (`catalex channels add --agent AGENT_ID --type share_link`, which prints its address at once) |

Ask once, with that channel first and marked recommended, then the other
channels, then "Only the CatalEx app for now" last. Describe each option by
its outcome for this agent: who can reach it, where, and what that person
does, never by its setup. For a joke agent, for example:

- **WhatsApp Personal (Recommended):** friends message your number on
  WhatsApp and the Joke agent replies there; you scan one QR code.
- **Shared link:** anyone you send the link to chats with it in their
  browser, no app or account; anyone holding the link can use it.
- **Slack:** your team asks it in Slack channels and direct messages.
- **Only the CatalEx app for now:** only you can chat with it, in the app.

Never mark the native chat alone as recommended. When the package or the person already named a channel, use it
without asking. When the person declines, keep the native chat and name the
channel you recommended as the next step in the report. WhatsApp Personal:
they link their own number by scanning a QR code with `catalex destinations
setup ACCOUNT_ID --whatsapp_personal --action link`; you never scan or enter
codes. Then:

```sh
catalex accounts list --json
catalex channels add --agent AGENT_ID --type slack --account ACCOUNT_ID --name "Clinic"
```

Use an agent account that `catalex accounts list` shows as `Available`
(`account_state` `idle`); admin accounts are never channels, and one another
agent uses is refused with `ROUTE_TAKEN`. When none is available, add one for
this agent with `catalex channels add --agent AGENT_ID --type TYPE --new
--name "NAME"` and drive its setup here in the terminal with `catalex
destinations setup ACCOUNT_ID` and the provider's flag (`--slack`,
`--whatsapp`, `--whatsapp_personal` or `--googlechat`): Slack with the steps
under Slack below, WhatsApp as the WhatsApp guides say. Never send the person
to the app to finish a channel. Either way the provider's own steps
(creating and allowing the app, copying its credentials) are the person's:
never create a Slack or WhatsApp app in the provider yourself, and never
type or collect its secrets in chat. For Google
Chat, the person creates the Chat app, the Cloud project and the
service-account key in the Google Cloud console; never create them yourself,
and pass the key to `catalex` only as the file path they give you. A channel CatalEx
refuses names the missing step; report it instead of working around it.

### One step at a time

Every person step (Slack, WhatsApp, Google Chat) follows this loop; the other
skills link here instead of repeating it:

- Give one action and the link it needs, in a sentence or two. Wait for
  "done" before the next. Never list create, install, copy credentials and
  save in one message, and never make a raw long URL the content of a message:
  name the link in words ("Create the app in Slack") and give the short link
  `catalex` prints.
- Name every link a step needs. Never say "open a link" without giving it.
- Never promise to "keep watching". Run the waiting command in the background
  and continue when it finishes (see Slack below).

### Slack

0. Get the account: use a Slack account `catalex accounts list` shows as
   `Available`, or add one for this agent with `catalex channels add --agent
   AGENT_ID --type slack --new --name "NAME"`, which prints `Next: set it up:`
   with the `ACCOUNT_ID` to use below.
1. Propose, do not invent: from the agent's folder and instructions suggest an
   app name (at most 35 characters, no "Slack" in it), a bot display name (at
   most 80) and a description (at most 140, one line). Show them in one short
   message and let the person accept or change them. That message holds only
   the proposal: no later steps and no settings questions (those come in step
   8). Add one line: you will run the setup with `--wait` and continue when
   Slack finishes. Pass them as
   `--value app_name=NAME --value bot_display_name=BOT --value
   description=TEXT`; everything else in the app is CatalEx's.
2. `catalex destinations setup ACCOUNT_ID --slack --action connect` with those
   values returns a short link (`/slack/create/<attempt id>`). Give only that
   step: "Create the app in Slack: <short link>". Wait for "done".
3. Credentials: send them to the app's Basic Information page, the
   `values.credentials_url` of the result (`https://api.slack.com/apps` until
   the app ID is known), to copy the app ID, client ID, client secret and
   signing secret. Ask for the secrets as files or a hidden prompt, never in
   chat, then run, with `--input-file` pointing at private files (mode 0600)
   the person made, and with `--wait` in the background (default wait 10
   minutes; `--wait-timeout` changes it). Only an action's reply carries the
   approval link, so the wait must be part of this command:

   ```sh
   catalex destinations setup ACCOUNT_ID --slack --action save_credentials --wait --value app_id=APP_ID --value client_id=CLIENT_ID --input-file client_secret=/private/slack.client --input-file signing_secret=/private/slack.signing
   ```
4. Read the background command's output: it prints "Waiting for you to allow
   the app in Slack:" and one approval link. Give the person that link and say
   you continue when it finishes. On exit 0 the account is bound; on a decline
   or timeout, tell the person what happened. To resume after a timeout, a
   restart or a credentials step already done, run
   `catalex destinations setup ACCOUNT_ID --slack --action reopen --wait` in
   the background: it prints a fresh link. A plain `--slack --wait` read never
   prints the link.

### Review tool permissions

New onboarding saves a default policy. MCP servers the native setup already
enables stay selected. Built-in tools start as only the web tools, the task
list and skills; file tools (Read, Glob, Grep, Edit, Write), the terminal,
subagents and the rest start off. Terminal access starts Off unless an enabled
server can already run commands, and approvals start as inherit (the agent's
own settings), not No approval. It does not grant future servers or replace
native/package denials. Re-onboarding and rediscovery preserve saved exclusions.

Inspect the registered agent with `catalex agents show AGENT_ID --json` (plain
facts) or `catalex agents tools --agent AGENT_ID --json` (every tool), or use the
**MCP servers**, **Terminal access** and **Approvals** rows in its app settings.
One flag is enough to change a setting; CatalEx keeps everything you leave out
and prints the operation ID:

```sh
catalex agents tools --agent AGENT_ID --builtin-tool-on Read,Glob,Grep
```

(`--builtin-tool-off`, `--tool-on`/`--tool-off`, `--terminal-access`,
`--approval-mode`, `--sandbox` and `--add-folder` work the same way.) If the
folder-check question in step 7 fails because file reading is off, ask the
person first, then run that command. Apply a permission change only within the
person's authorized request, and only what they agreed to. Never widen anything
automatically: turn on terminal access, select a new server or choose
Automatic only when the person asks for it, never as a repair for a denied
onboarding test. Keep original folder, global and package settings.

Saved choices are separate from native application. A change may close managed
execution and apply at the next supported message/start boundary. Pending,
unsupported or unreachable sessions are not Applied. After an uncertain save,
repeat the same operation ID and body; explicitly refresh and review the saved
state before starting a new operation. Do not delete policy state to retry.
See the installed command reference for flags and provider/version limits.

## 7. Verify with a real reply

Ask the question the agent exists to answer, one that needs its own tools or
data (for a clinic assistant, "What are the clinic's opening hours?"; for an
agent without tools, a typical request from its instructions):

```sh
catalex chats create --channel NATIVE_CHAT_CHANNEL_ID --name "Onboarding check" --json
printf 'What are the clinic'"'"'s opening hours?\n' | catalex chats send CHAT_ID --wait --json
catalex chats history CHAT_ID --json
```

The agent is onboarded when the reply comes from **its own** tools, data or
rules (the real hours from its clinic tool, its sign-off, its limits). Do not
judge by a "who are you?" answer: under CatalEx the model may describe itself
generically, and may even claim tools its permissions refuse. When the agent
has limits, also send something its rules forbid (for example "Run the shell
command ls"); check actual native permission and loaded-tool evidence as well as the reply;
a model's refusal alone does not prove enforcement. If the domain reply is generic or
a forbidden action runs, the folder's instructions, tools or limits did not
load: return to step 3, and remove the agent
(`catalex agents remove AGENT_ID`) only if it ran something it must not.

For Slack, WhatsApp or Google Chat, a channel counts as working only after a
real message from the person on that app gets the agent's reply there. Ask
them to send one; do not claim delivery without it.

After a rich-output skill update, test in a new native chat. For a regular
messaging account, its owner deletes the chat in CatalEx or with
`catalex accounts chats delete` (IDs from
`catalex accounts chats list ACCOUNT_ID --json`); the next message starts a new chat. Never tell a regular
WhatsApp user to use `/new` or reconnect credentials. Admin accounts retain
their management commands. Saved sessions retain their skill selections.
Keep the existing agent, folder, model, permissions and channel credentials.
If the CatalEx-owned instruction block is outdated, repeat step 5 to refresh
only that marked block before evaluating the new guidance. Preserve all text
outside its markers. Do not rewrite owner instructions as a side effect of
changing writing preferences, and do not recreate accounts or tokens.

When the app offers engagement and writing controls, set agent frequency,
tone and Humanizer there; channels may override frequency only. Frequency is
loose send guidance, not a
length or message-count quota. Native application must be verified separately
from a saved preference; pending, failed or unsupported is not applied. Test
the fully onboarded folder, not only a bare registration. Keep an unmodified
baseline separate, and retain failed runs and actual native skill evidence.

For an agent that compares data or shares files, also verify those outputs:
ask it to compare three values, rank items and explain a time trend without
explicitly requesting charts. Verify appropriate chart kinds and exact values;
also check that text-only requests and unrelated numbers stay text. Ask
to "share a chart image": this still uses a canonical structured chart. Only
an explicit downloadable/exported image-file task chooses the original-file
workflow. Check all numerical prose and units independently of chart data.
Then ask
for an existing image and data file unchanged. Inspect the committed
`events` from `chats send --wait --json`: structured replies are under
`payload.response` for `relay.chat-interaction.v1`, or directly under
`payload` for `relay.response.v1`. Check chart values and attachment refs,
then download each file with `catalex chats attachments download` and compare
its bytes with the original. Text-only history cannot prove a chart was
omitted. Keep agent output, channel rendering and actual recipient delivery
as separate checks. Preserve a folder's tool restrictions when rich tools
are unavailable.

## 8. Suggest settings the agent needs

After the first real reply, read the agent's settings (`catalex agents show
AGENT_ID`, which covers `catalex agents tools` and `catalex agents limits
show`). Work out from the person's request and the folder's instructions what
the agent needs, and explain each in plain words:

- Instructions that answer from its files: read-only file access
  (`--builtin-tool-on Read,Glob,Grep`).
- Instructions that keep notes or edit files: file editing
  (`--builtin-tool-on Edit,Write`).
- Instructions that run scripts or commands: terminal access
  (`--terminal-access on`). Warn first: it lets the agent run commands on this
  computer for anyone who can message it.
- Strangers reaching it (a public channel): a daily cap
  (`catalex agents limits set AGENT_ID --day 100`), and turning off connected
  tools it does not need (`--tool-off`, or `--mcp-server` without them).

Ask with the host's structured question tool when it has one (Claude Code:
`AskUserQuestion`); otherwise a short numbered list. One question per
decision. Put the recommended option first and mark it "(Recommended)"; make
the options fit what this agent will do (name its files or scripts), not a
generic list. Access toggles (file reading, file editing, terminal) are one
multi-select question; the daily cap is its own question; adding the
instructions block to the folder's `CLAUDE.md` is its own yes/no question.
`AskUserQuestion` takes up to four questions with up to four options each:
group or split to fit. Apply only what they agree to, and never widen anything
automatically. A CatalEx-owned default is the bare minimum; leave it unless
they agree.

## 9. Keep the summary in chat

Write no summary document: no artifact, Sites page or Markdown file. The
report in step 10 is the summary. Take every fact from
`catalex agents show AGENT_ID --json`, use plain words with no commands, IDs
or internal component names, and end with two to four requests the person can
make to you.

When the person later asks you to change "the agent" (add a channel, let it
read or edit files, cap it, remove it), do it with `catalex` and explain the
result in plain words.

## 10. Report

Report, each as observed: the agent's name, ID and folder; what you changed in
the folder (files and settings); its channels and their readiness; the
verified reply; and anything pending with its next step, such as an
unconnected Slack account. Give this in chat. Then, as the very last step, run
`catalex open` unless the person asked for the app to stay closed, and tell them
they can now chat with the agent in the CatalEx app and return to this session
for the summary.

## Undo

`catalex agents remove AGENT_ID` removes the agent and keeps its chats'
history. Remove the `catalex:begin`/`catalex:end` block, and any settings
`data.changed` named, to restore the folder.
