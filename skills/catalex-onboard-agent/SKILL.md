---
name: catalex-onboard-agent
description: Use when an existing Claude Code or Codex agent should start working through CatalEx that is already installed and running - so people can reach it in CatalEx native chats, Slack, WhatsApp or Google Chat. The agent registers its own folder with catalex, adapts its instructions, files and tool settings so they still apply when CatalEx runs the agent, connects channels and proves it with a real reply.
---

# Onboard this agent onto CatalEx

CatalEx runs your agent for you: for every chat it starts Claude Code
(`claude -p`) or Codex **in your agent folder**, gives it CatalEx's chat tools
(`relay_emit`, `relay_ask`, `relay_attach`, `relay_context`, ...) and the
`relay-communication` skill, and delivers messages from native chats, Slack,
WhatsApp and Google Chat to it. Onboarding therefore means: make your folder work when
CatalEx starts it, register it, connect channels and verify a reply.

Do every step with `catalex` commands and edits inside your own folder.
Never edit CatalEx configuration or databases, never call its
APIs (`curl`), never start or stop its processes yourself, and never put a
secret in chat, on a command line or in a file you print. Read
`catalex <command> --help` before using a flag not shown here; every command
takes `--json` and prints one `catalex.result.v1` result.

## 1. Check CatalEx is ready

```sh
catalex version && catalex status && catalex providers
```

- `catalex` missing, or `status` reports no setup: stop and follow the
  `catalex-setup` skill (or the `catalex-agent-addon` skill, which installs
  and sets everything up), then come back.
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
`data.agent.native_chat_channel` its native chat channel;
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

For Slack, WhatsApp, WhatsApp Personal or Google Chat, ask the person which
they want for this agent (WhatsApp Personal: they link their own number by
scanning a QR code with `catalex destinations setup ACCOUNT_ID
--whatsapp_personal --action link`; you never scan or enter codes), then:

```sh
catalex accounts list --json
catalex channels add --agent AGENT_ID --type slack --account ACCOUNT_ID --name "Clinic"
```

Use an agent account that `catalex accounts list` shows as `Available`
(`account_state` `idle`); admin accounts are never channels, and one another
agent uses is refused with `ROUTE_TAKEN`. When none is available, the person
sets one up first (Slack, WhatsApp or Google Chat in the app's Settings ›
Channels); never
create a Slack or WhatsApp app or enter its credentials yourself. For Google
Chat, the person creates the Chat app, the Cloud project and the
service-account key in the Google Cloud console; never create them yourself,
and pass the key to `catalex` only as the file path they give you. A channel CatalEx
refuses names the missing step; report it instead of working around it.

### Review tool permissions

New onboarding records the tools already permitted by the effective native
setup as an explicit snapshot, with terminal access inherited. Approvals start
as No approval (the CLI's full-access mode: it never asks, and the agent can do
anything the computer account can) where the AI tool supports it, otherwise
as the agent's own settings. It does not grant future servers or replace
native/package denials. Re-onboarding and rediscovery preserve saved exclusions.

Inspect the registered agent with
`catalex agents tools --agent AGENT_ID --json`, or use the **MCP servers**, **Terminal access** and **Approvals** rows
in its app settings. The owner can choose an MCP subset, terminal access and
supported approval behavior there; the CLI uses the same owner operations.
Apply a permission change only within the person's authorized request. Never
turn on terminal access, select a new server or choose Automatic as a repair
for a denied onboarding test. Keep original folder, global and package settings.

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

## 8. Report

Report, each as observed: the agent's name, ID and folder; what you changed in
the folder (files and settings); its channels and their readiness; the
verified reply; and anything pending with its next step, such as an
unconnected Slack account. Tell the person they can now chat with the agent
in the CatalEx app (`catalex open`).

## Undo

`catalex agents remove AGENT_ID` removes the agent and keeps its chats'
history. Remove the `catalex:begin`/`catalex:end` block, and any settings
`data.changed` named, to restore the folder.
