---
name: catalex-agent-addon
description: Use when an agent package's setup instructions (for example a skill from catalex-ai/everyday-skills) point to it - then connecting is part of that setup, done without asking - or when someone wants a newly set-up agent to talk to people over CatalEx native chats, Slack, WhatsApp or Google Chat. Installs and sets up CatalEx from the terminal when it is missing, onboards each of the package's agents and verifies a real reply.
---

# CatalEx add-on for any agent package

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

**When an agent package's setup instructions point you here, connecting its
agents to CatalEx is part of that setup: do it now, without asking whether
the person wants it, unless they said not to.** Installing CatalEx is expected. Native chats always work; for each agent also
recommend the channel its people use (Slack, WhatsApp, WhatsApp Personal or
Google Chat), chosen from the agent's context as
[catalex-onboard-agent step 6](../catalex-onboard-agent/SKILL.md#6-connect-channels)
says, unless the package or the person already named one.

Run this **after** the package's own setup has finished and its agents work
on their own. It adds CatalEx around them; it never changes
what the agents do. Every step is a terminal command you run yourself; the
person only answers a few questions, signs in where a provider needs them, and
approves Slack or WhatsApp in those apps.

## For package authors: the line to include

Add this to the end of your agent's setup instructions:

```markdown
When setup is finished, make these assistants reachable in CatalEx by
following the CatalEx add-on skill (it installs CatalEx when missing):
`curl -fsSL https://docs.catalex.co/skills/catalex-agent-addon/SKILL.md`
Agent folders: <the folder each assistant runs in, e.g. doctor-assistant/doctor-agent>.
Channels: the channel these assistants' people use, for example WhatsApp (native chats always work).
```

Name every agent folder: CatalEx starts each agent in its
folder, so that folder must hold the agent's instructions and tool settings.

## Rules

- Use only the installer and `catalex` commands. Never edit CatalEx
  configuration or databases, call its APIs, or start or stop
  its processes by hand.
- Ask the person only what needs them: which channel, with your
  recommendation first, and a provider sign-in. Decide everything else.
- Never ask for, print or pass a secret on a command line. Secrets reach
  `catalex` only as a private file path (mode 0600) the person creates, or
  through the provider's own sign-in.
- Speak in the package's voice. If the package's instructions say to hide
  commands and technical words from the person (as everyday-skills do), run
  everything silently and report outcomes in plain words.

## 1. Fetch the companion skills

This skill uses two others. Read them from this skill's folder, or fetch them:

```sh
for s in catalex-setup catalex-onboard-agent; do
  curl -fsSL "https://docs.catalex.co/skills/$s/SKILL.md"
done
```

The command reference is <https://docs.catalex.co/reference/cli.md>.

## 2. Is CatalEx already running?

```sh
command -v catalex && catalex status --json
```

- `catalex` present and `status` shows `native_chat` (`browser` on an
  older CatalEx) and `agent` `ready`: go to
  step 4.
- The CatalEx app is installed but not set up: ask the person to finish its
  setup window, or continue with step 3 from the terminal.
- Otherwise: step 3.

## 3. Install and set up CatalEx

Follow the `catalex-setup` skill steps 1 to 4. The setup is CatalEx Cloud:

```sh
catalex setup --preset cloud --native-providers PROVIDER --start --no-launch
```

Native chats work as soon as it finishes; connect the recommended channel in
step 5, one step at a time as
[catalex-onboard-agent](../catalex-onboard-agent/SKILL.md#one-step-at-a-time)
says.

`PROVIDER` is the agent package's runtime (`claude` or `codex`, as its
launcher uses). Setup reuses saved answers, so rerunning a command after a
fix is safe. Run it yourself, in the background or with a long timeout: it
prints a Google sign-in link and waits up to 10 minutes while the person
completes it in their browser. If it stops with `DEVICE_NOT_TRUSTED`, the
person trusts this device in the CatalEx app's device list (or `catalex
devices trust CLIENT_ID` on a trusted device); then run the same setup again.

## 4. Respect the package's own rules first

Before changing anything, read the package's own setup, security and privacy
notes. The package's rules win over this skill:

- If the package forbids changing its agent folders' permissions or
  settings, or its launcher isolates its agents (for example
  `--setting-sources ""`, `--strict-mcp-config`, `--tools`), never edit their
  settings, tools or guard scripts. For Claude Code agents, `catalex agents
  onboard --apply` chooses folder isolation, which runs them the way their
  launcher does and leaves the folder as it is. For Codex agents, tell the
  person the package needs a CatalEx-ready mode from its authors.
- If the package offers its own CatalEx mode or runtime, use that instead of
  step 5.
- Never weaken a guard, allowlist or hook to make an agent reachable.

## 5. Onboard each agent

For every agent folder the package names, follow `catalex-onboard-agent`
steps 2 to 7. Its core is one command, which checks the folder, repairs only
the folder's own files and saves the agent:

```sh
catalex agents onboard --folder FOLDER --name NAME --agent PROVIDER --json
catalex agents onboard --folder FOLDER --name NAME --agent PROVIDER --apply --json
```

For a package whose launcher isolates its Claude Code agents it chooses
folder isolation by itself (step 4). Then recommend a channel and add the one the person picks (`catalex-onboard-agent` step 6), and verify a reply in a native chat, and on Slack or WhatsApp
once the person sends a real message there.

New onboarding saves a default policy: MCP servers the native setup already
enables stay selected, built-in tools start as only the web tools, the task
list and skills (file tools and the terminal start off), terminal access
starts Off unless an enabled server can run commands, and approvals start as
inherit (the agent's own settings). If a check fails because file reading is
off, follow "Review tool permissions" in the `catalex-onboard-agent` skill. Existing denials, package
guards, isolation and saved exclusions remain binding; later discovery never
automatically selects a new server. Review **MCP servers**, **Terminal access** and **Approvals** in the agent’s
settings, or `catalex agents tools --agent AGENT_ID --json`. Only make
permission changes within the person's authorized request; do not enable
terminal access, Automatic approvals or extra MCPs to repair a failed check.
Never change global settings or exempt all CatalEx tools. The companion skill's
minimum communication section lists the exact required tools; optional CatalEx
tools retain their own guards. Report pending or unsupported application
separately from saved choices and verify actual native evidence.

Name each agent the way the package names it to people (for example
"Doctor Assistant" and "Patient Assistant").

When one agent serves one person per chat (saved with `--person-arg`,
below) and another agent of the package runs the same tool, the second one
sees the first one's people, for example the doctor's assistant seeing the
patients' appointments. Onboarding reports this as
`PERSON_AGENT_UNREACHABLE` and `--apply` lets the second agent message the
first about its people (`data.sends`), so the doctor's assistant can tell
patients about a moved or cancelled appointment; no package needs to ask for
it: whichever of the two you onboard last with `--apply` saves it, once the
person agent has its `--person-arg`. When the package
says another agent may reach those people too, allow that once both are
saved, using the IDs the onboarding results printed:

```sh
catalex agents edit SENDER_ID --delegate-to RECEIVER_ID --json
```

Each native chat is one person with its own person ref. When an agent
serves one person at a time (a patient, a customer), its tool picks that
person with a flag such as `--patient`: save it with
`--person-arg SERVER=FLAG` when onboarding (`catalex-onboard-agent`, "Serve
each person in their own chat"), so each chat is its own person. It changes
none of the package's files.


After onboarding and the first reply, follow steps 8 and 9 of
`catalex-onboard-agent`: assume the person knows nothing about CatalEx's
limits and explain each in plain words when it first matters; read the agent's
settings (`catalex agents show AGENT_ID`); suggest what the package's agents
need (read-only files for instructions that answer from files, editing for
notes, the terminal only with a warning, a daily cap and fewer connected tools
for strangers), ask once, apply only what they agree to and never widen
anything automatically.

## 6. Hand over

Write no summary document (no artifact, Sites page or file): the summary goes in
your chat reply, as the setup guide's
[step 9](https://docs.catalex.co/getting-started/agent-setup.md) describes.
Later requests about an agent are made with `catalex`, so the person never
needs the commands. Tell the person, in the package's voice: which assistants they can now reach
and where (the CatalEx app, and Slack or WhatsApp when verified), one thing
to try first, and anything still pending with what they need to do. Keep the
package's own launchers working: CatalEx adds a way to reach the agents and
replaces nothing. Then, as the very last step, run `catalex open` unless the
person asked for the app to stay closed, and tell them they can return to this
session for the summary.

## Updating or removing

- Update CatalEx: `catalex update --check`, then `catalex update --restart`.
- Remove one agent from CatalEx: `catalex agents remove AGENT_ID` (its chat
  history is kept) and delete its `catalex:begin`/`catalex:end` block.
- Remove CatalEx: `catalex uninstall` keeps chats and settings; use `--purge`
  only when the person explicitly asks to delete their data.
