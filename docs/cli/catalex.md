# `catalex` command reference

<!-- Generated from the command tree by TestCLIReferenceIsCurrent; run
`make -C catalex cli-reference` after changing a command. Do not edit. -->

CatalEx command-line client: the terminal equivalent of the CatalEx app.
It manages CatalEx on this computer or on other computers directly, and saved connections to messaging services. Select a computer
with --connection or catalex connections use; with one CatalEx running here,
it is used.

Every command accepts the global flags below. With `--json` it prints one
`catalex.result.v1` object: `ok`, `command`, `state`, `data` and, on failure,
`error.code` and `error.message`. Branch on `error.code`, never on message text.

```text
      --computer string     Run agents and chats commands on another computer of your account, by name or ID
      --confirm-signing     Confirm signing a sensitive change on another computer without asking
      --connection string   Select a saved connection name or ID for this invocation
      --json                Print a structured JSON result
```

## Index

| Command | Purpose |
| --- | --- |
| [`catalex account`](#catalex-account) | Show your CatalEx account sign-in, print an access token or move the account |
| [`catalex account delete`](#catalex-account-delete) | Delete your CatalEx account and its chat history |
| [`catalex account move`](#catalex-account-move) | Move your account to another messaging service |
| [`catalex account status`](#catalex-account-status) | Show the sign-in state and the features that require login |
| [`catalex account token`](#catalex-account-token) | Print a short-lived access token for your account |
| [`catalex accounts`](#catalex-accounts) | Manage named Slack, WhatsApp and Google Chat accounts |
| [`catalex accounts access`](#catalex-accounts-access) | Show or change who may message an account |
| [`catalex accounts access set`](#catalex-accounts-access-set) | Replace an account's allowlist or blocklist |
| [`catalex accounts access show`](#catalex-accounts-access-show) | Show an account's allowlist, blocklist and refusal counts |
| [`catalex accounts add`](#catalex-accounts-add) | Add a messaging app agent or admin account |
| [`catalex accounts admins`](#catalex-accounts-admins) | Show or change who may use an admin account |
| [`catalex accounts admins add`](#catalex-accounts-admins-add) | Add people to an admin account's list |
| [`catalex accounts admins list`](#catalex-accounts-admins-list) | List the people an admin account admits |
| [`catalex accounts admins remove`](#catalex-accounts-admins-remove) | Remove people from an admin account's list |
| [`catalex accounts agents`](#catalex-accounts-agents) | Remove an agent from a shared account or set its engagement depth there |
| [`catalex accounts agents engagement`](#catalex-accounts-agents-engagement) | Show or set an agent's engagement depth on a shared account |
| [`catalex accounts agents engagement set`](#catalex-accounts-agents-engagement-set) | Set how often an agent joins conversations on a shared account |
| [`catalex accounts agents engagement show`](#catalex-accounts-agents-engagement-show) | Show how often an agent joins conversations on a shared account |
| [`catalex accounts agents remove`](#catalex-accounts-agents-remove) | Remove an agent from a shared account |
| [`catalex accounts agents settings`](#catalex-accounts-agents-settings) | Show or set an agent's own settings on a shared account |
| [`catalex accounts agents settings set`](#catalex-accounts-agents-settings-set) | Change an agent's settings on a shared account |
| [`catalex accounts agents settings show`](#catalex-accounts-agents-settings-show) | Show an agent's settings on a shared account |
| [`catalex accounts agents switches`](#catalex-accounts-agents-switches) | Show or set an agent's chat commands and system messages on a channel |
| [`catalex accounts agents switches set`](#catalex-accounts-agents-switches-set) | Change an agent's switches on a channel |
| [`catalex accounts agents switches show`](#catalex-accounts-agents-switches-show) | Show an agent's switches on a channel |
| [`catalex accounts candidates`](#catalex-accounts-candidates) | List the people and groups that can reach an account |
| [`catalex accounts chats`](#catalex-accounts-chats) | List an account's chats and read a chat's messages |
| [`catalex accounts chats answer`](#catalex-accounts-chats-answer) | Answer a messaging chat's question |
| [`catalex accounts chats approve`](#catalex-accounts-chats-approve) | Approve or deny a messaging chat's permission request |
| [`catalex accounts chats delete`](#catalex-accounts-chats-delete) | Delete a messaging chat and stop its agent |
| [`catalex accounts chats list`](#catalex-accounts-chats-list) | List an account's chats, newest first, one page at a time |
| [`catalex accounts chats requests`](#catalex-accounts-chats-requests) | List the requests the account's agent is waiting on, across its chats |
| [`catalex accounts chats show`](#catalex-accounts-chats-show) | Read one page of a chat's messages, oldest first |
| [`catalex accounts clear-setups`](#catalex-accounts-clear-setups) | Remove every account whose setup was started and not finished |
| [`catalex accounts entries`](#catalex-accounts-entries) | Show or change the entries each agent answers on a shared account |
| [`catalex accounts entries add`](#catalex-accounts-entries-add) | Add entries to an agent, joining the account when it is not on it yet |
| [`catalex accounts entries move`](#catalex-accounts-entries-move) | Move entries from one agent to another |
| [`catalex accounts entries remove`](#catalex-accounts-entries-remove) | Remove entries from an agent |
| [`catalex accounts entries show`](#catalex-accounts-entries-show) | Show the agents of an account with their entries |
| [`catalex accounts health`](#catalex-accounts-health) | Show each account's health and how to fix it |
| [`catalex accounts limits`](#catalex-accounts-limits) | Show or change an account's rate limits and throttled messages |
| [`catalex accounts limits set`](#catalex-accounts-limits-set) | Change an account's rate limits |
| [`catalex accounts limits show`](#catalex-accounts-limits-show) | Show an account's limits with this window's use |
| [`catalex accounts limits throttled`](#catalex-accounts-limits-throttled) | List an account's most recent throttled messages |
| [`catalex accounts list`](#catalex-accounts-list) | List accounts with their kind, state, agent and rules |
| [`catalex accounts manager`](#catalex-accounts-manager) | Manage a number's CatalEx Manager group |
| [`catalex accounts manager recreate`](#catalex-accounts-manager-recreate) | Create the CatalEx Manager group of a number again |
| [`catalex accounts remove`](#catalex-accounts-remove) | Remove a saved account |
| [`catalex accounts remove-link`](#catalex-accounts-remove-link) | Remove a shared number that no agent uses |
| [`catalex accounts routes`](#catalex-accounts-routes) | List or remove the channels of agents whose computer is offline or removed |
| [`catalex accounts routes remove`](#catalex-accounts-routes-remove) | Remove a channel from an agent on an offline computer |
| [`catalex accounts routes show`](#catalex-accounts-routes-show) | List the channels of agents on offline computers |
| [`catalex accounts template`](#catalex-accounts-template) | Show or change the template an account uses to start conversations |
| [`catalex accounts template clear`](#catalex-accounts-template-clear) | Remove an account's proactive template |
| [`catalex accounts template set`](#catalex-accounts-template-set) | Register an account's proactive template |
| [`catalex accounts template show`](#catalex-accounts-template-show) | Show an account's proactive template |
| [`catalex agents`](#catalex-agents) | Manage the selected computer's saved agents |
| [`catalex agents activity`](#catalex-agents-activity) | List settings changes made to an agent |
| [`catalex agents add`](#catalex-agents-add) | Add an agent with its folder and AI settings |
| [`catalex agents behavior`](#catalex-agents-behavior) | Show or change saved engagement and writing preferences |
| [`catalex agents delete`](#catalex-agents-delete) | Delete a saved agent and everything CatalEx keeps for it |
| [`catalex agents discover`](#catalex-agents-discover) | List agent folders where Claude Code or Codex ran lately |
| [`catalex agents edit`](#catalex-agents-edit) | Rename an agent or change its AI, model and effort |
| [`catalex agents limits`](#catalex-agents-limits) | Show or change an agent's rate limits across all its accounts |
| [`catalex agents limits set`](#catalex-agents-limits-set) | Change an agent's rate limits |
| [`catalex agents limits show`](#catalex-agents-limits-show) | Show an agent's limits with this window's use |
| [`catalex agents list`](#catalex-agents-list) | List saved agents, then the account's agents on other computers |
| [`catalex agents onboard`](#catalex-agents-onboard) | Check an existing agent folder, repair it for CatalEx and register it |
| [`catalex agents picture`](#catalex-agents-picture) | Set, show or remove an agent's picture |
| [`catalex agents picture remove`](#catalex-agents-picture-remove) | Remove an agent's picture so its robot shows again |
| [`catalex agents picture set`](#catalex-agents-picture-set) | Set an agent's picture from an image file |
| [`catalex agents picture show`](#catalex-agents-picture-show) | Show an agent's picture, or save its image to a file |
| [`catalex agents sync`](#catalex-agents-sync) | Show whether earlier conversations are synced to the server |
| [`catalex agents tools`](#catalex-agents-tools) | Inspect, discover or save an agent's tools and permissions |
| [`catalex analytics`](#catalex-analytics) | Show every conversation and its distribution |
| [`catalex analytics summary`](#catalex-analytics-summary) | Show message activity and cost: totals, each day, and who and where |
| [`catalex app`](#catalex-app) | Act on the CatalEx app on this computer |
| [`catalex app login`](#catalex-app-login) | Turn opening the CatalEx app at login on or off |
| [`catalex app login off`](#catalex-app-login-off) | Stop opening the CatalEx app at login |
| [`catalex app login on`](#catalex-app-login-on) | Open the CatalEx app when you log in to this computer |
| [`catalex app open`](#catalex-app-open) | Launch or focus the CatalEx app |
| [`catalex app quit`](#catalex-app-quit) | Quit the CatalEx app; agents and chats keep running |
| [`catalex app status`](#catalex-app-status) | Show whether the CatalEx app runs, its version and login registration |
| [`catalex channel-settings`](#catalex-channel-settings) | Show or change who may act and what an account's conversations post |
| [`catalex channel-settings discard`](#catalex-channel-settings-discard) | Discard an account's settings draft |
| [`catalex channel-settings set`](#catalex-channel-settings-set) | Change an account's channel settings, or save them as a draft |
| [`catalex channel-settings show`](#catalex-channel-settings-show) | Show an account's channel settings, draft and next action |
| [`catalex channels`](#catalex-channels) | Manage agents' native chat, Slack, WhatsApp and Google Chat channels |
| [`catalex channels add`](#catalex-channels-add) | Add a native chat or messaging app channel to an agent |
| [`catalex channels behavior`](#catalex-channels-behavior) | Show or change a channel's saved engagement frequency |
| [`catalex channels list`](#catalex-channels-list) | List channels with their readiness |
| [`catalex channels remove`](#catalex-channels-remove) | Remove a saved channel. Its conversations are kept, except on a bound account |
| [`catalex chats`](#catalex-chats) | List, create and manage native chats |
| [`catalex chats activity`](#catalex-chats-activity) | Read a native chat's full activity: tool calls, thoughts and results |
| [`catalex chats answer`](#catalex-chats-answer) | Answer an agent's question or AI provider form |
| [`catalex chats approve`](#catalex-chats-approve) | Grant or deny an AI provider permission request |
| [`catalex chats archive`](#catalex-chats-archive) | List or restore archived native chats |
| [`catalex chats archive list`](#catalex-chats-archive-list) | List archived chats with whether they are restorable |
| [`catalex chats archive restore`](#catalex-chats-archive-restore) | Restore every archived chat missing on this computer |
| [`catalex chats attachments`](#catalex-chats-attachments) | Upload, download or revoke a native chat's files |
| [`catalex chats attachments download`](#catalex-chats-attachments-download) | Download a chat file's verified bytes to a file |
| [`catalex chats attachments revoke`](#catalex-chats-attachments-revoke) | Revoke a chat file so no new message can use it |
| [`catalex chats attachments show`](#catalex-chats-attachments-show) | Show a chat file and, for a voice message or video, its transcript |
| [`catalex chats attachments upload`](#catalex-chats-attachments-upload) | Upload a file to a chat for a later message |
| [`catalex chats cancel`](#catalex-chats-cancel) | Stop the chat's current turn |
| [`catalex chats create`](#catalex-chats-create) | Create a native chat in an agent's native chat channel |
| [`catalex chats history`](#catalex-chats-history) | Read bounded pages of a native chat's history |
| [`catalex chats import`](#catalex-chats-import) | Import a known Codex or Claude Code session as a native chat |
| [`catalex chats list`](#catalex-chats-list) | List native chats with their live activity |
| [`catalex chats react`](#catalex-chats-react) | Add, replace or remove your reaction to a message |
| [`catalex chats remove`](#catalex-chats-remove) | Remove a saved chat. Its saved history is kept |
| [`catalex chats replace`](#catalex-chats-replace) | Start a new AI session for a chat whose session failed |
| [`catalex chats resume`](#catalex-chats-resume) | Resume a chat's original AI session |
| [`catalex chats retry`](#catalex-chats-retry) | Retry creating a chat that failed to start |
| [`catalex chats send`](#catalex-chats-send) | Send a message to a native chat |
| [`catalex chats settings`](#catalex-chats-settings) | Show a native chat's model settings |
| [`catalex chats settings show`](#catalex-chats-settings-show) | Show the model settings a chat started with |
| [`catalex chats show`](#catalex-chats-show) | Show a native chat's state, settings and session |
| [`catalex chats usage`](#catalex-chats-usage) | Show a native chat's turns, tokens, cache use and cost |
| [`catalex chats watch`](#catalex-chats-watch) | Stream a native chat's events for a bounded time |
| [`catalex computers`](#catalex-computers) | List, add and manage the computers of this CatalEx account |
| [`catalex computers add`](#catalex-computers-add) | Create a one-time code that joins another computer to the account |
| [`catalex computers delete`](#catalex-computers-delete) | Delete a disconnected computer and erase its agents and data |
| [`catalex computers disconnect`](#catalex-computers-disconnect) | Disconnect a computer from the account; it stops its agents at once |
| [`catalex computers keep`](#catalex-computers-keep) | Keep a stale computer so it can connect again |
| [`catalex computers leave`](#catalex-computers-leave) | Stop serving agents from this computer; your sign-in stays |
| [`catalex computers list`](#catalex-computers-list) | List the account's computers with their activity and last connection |
| [`catalex computers rename`](#catalex-computers-rename) | Rename a computer of the account |
| [`catalex computers settings`](#catalex-computers-settings) | Show or change this computer's own settings |
| [`catalex computers this`](#catalex-computers-this) | Show this computer's key and the device keys it trusts |
| [`catalex connections`](#catalex-connections) | Manage saved connections to computers and messaging services |
| [`catalex connections add`](#catalex-connections-add) | Save an authenticated connection reference |
| [`catalex connections edit`](#catalex-connections-edit) | Update a reference while preserving its bound server identity |
| [`catalex connections hosting`](#catalex-connections-hosting) | Show or change the selected computer's cloud hosting |
| [`catalex connections hosting off`](#catalex-connections-hosting-off) | Disconnect the selected computer from its messaging service |
| [`catalex connections hosting on`](#catalex-connections-hosting-on) | Reconnect the selected computer to the cloud hosting it last used |
| [`catalex connections hosting set`](#catalex-connections-hosting-set) | Connect the selected computer to a messaging service |
| [`catalex connections hosting show`](#catalex-connections-hosting-show) | Show and verify the cloud hosting connection |
| [`catalex connections list`](#catalex-connections-list) | List saved references without credentials |
| [`catalex connections remove`](#catalex-connections-remove) | Remove a client reference while keeping server data |
| [`catalex connections rescan`](#catalex-connections-rescan) | Refresh the CatalEx installations found on this computer |
| [`catalex connections use`](#catalex-connections-use) | Select a saved connection without changing its server |
| [`catalex credentials`](#catalex-credentials) | Enter, replace, check or remove a messaging account's credentials |
| [`catalex credentials bind`](#catalex-credentials-bind) | Use a provider installation for an account |
| [`catalex credentials check`](#catalex-credentials-check) | Check an account's saved token with the provider without replacing it |
| [`catalex credentials installations`](#catalex-credentials-installations) | List the provider installations an account can use |
| [`catalex credentials operation`](#catalex-credentials-operation) | Show the outcome of an earlier set or check without sending it again |
| [`catalex credentials set`](#catalex-credentials-set) | Replace an account's token, key or OAuth client after checking it with the provider |
| [`catalex credentials status`](#catalex-credentials-status) | Show an account's credential state and next action |
| [`catalex credentials unbind`](#catalex-credentials-unbind) | Stop an account using its installation; provider credentials are kept |
| [`catalex debug`](#catalex-debug) | Read what CatalEx holds, to troubleshoot it |
| [`catalex debug agents`](#catalex-debug-agents) | Print one page of CatalEx's agents |
| [`catalex debug operations`](#catalex-debug-operations) | Read operations |
| [`catalex debug operations inspect`](#catalex-debug-operations-inspect) | Print one operation |
| [`catalex debug projects`](#catalex-debug-projects) | Print one page of CatalEx's projects |
| [`catalex debug sessions`](#catalex-debug-sessions) | Print one page of sessions; inspect one or read its events |
| [`catalex debug sessions events`](#catalex-debug-sessions-events) | Print one page of a session's retained events |
| [`catalex debug sessions inspect`](#catalex-debug-sessions-inspect) | Print one session |
| [`catalex debug sessions list`](#catalex-debug-sessions-list) | Print one page of sessions |
| [`catalex defaults`](#catalex-defaults) | Show or set the AI settings for new agents |
| [`catalex defaults set`](#catalex-defaults-set) | Set the defaults for new agents (and agents with nothing saved) |
| [`catalex defaults show`](#catalex-defaults-show) | Show the defaults and every verified model and effort |
| [`catalex delegations`](#catalex-delegations) | Send a message to another agent on an agent's behalf; read what it sent |
| [`catalex delegations list`](#catalex-delegations-list) | List one page of the messages the agent sent to other agents, newest first |
| [`catalex delegations send`](#catalex-delegations-send) | Send a message to the agent a person's ID belongs to |
| [`catalex delegations status`](#catalex-delegations-status) | Show one message the agent sent to another agent, with its counts |
| [`catalex destinations`](#catalex-destinations) | Set up a messaging app's first installation for an account |
| [`catalex destinations setup`](#catalex-destinations-setup) | Inspect or resume the account's provider setup checkpoints |
| [`catalex devices`](#catalex-devices) | List the devices signed in to your CatalEx account, sign one out or trust it |
| [`catalex devices list`](#catalex-devices-list) | List the devices signed in to the account |
| [`catalex devices remove`](#catalex-devices-remove) | Sign another device out of the account |
| [`catalex devices trust`](#catalex-devices-trust) | Trust another device for changes on your computers |
| [`catalex devices trust-new`](#catalex-devices-trust-new) | Add devices signed in with your sign-in codes to your computers' trust lists |
| [`catalex devices trust-this`](#catalex-devices-trust-this) | Trust this device for changes through CatalEx on this computer |
| [`catalex doctor`](#catalex-doctor) | Check that CatalEx is ready; exits 1 when a part is not ready |
| [`catalex hosting`](#catalex-hosting) | Read the messaging service's agents and conversations |
| [`catalex hosting agents`](#catalex-hosting-agents) | List the agents your messaging service holds with channel and session counts |
| [`catalex hosting sessions`](#catalex-hosting-sessions) | List one messaging service agent's Slack and WhatsApp conversations |
| [`catalex install`](#catalex-install) | Install CatalEx on this computer from a verified release |
| [`catalex install status`](#catalex-install-status) | Show the installed components, their release and integrity |
| [`catalex join`](#catalex-join) | Join CatalEx on this computer to an account with a one-time code |
| [`catalex local-setup`](#catalex-local-setup) | Turn the complete setup on this computer on or off |
| [`catalex local-setup off`](#catalex-local-setup-off) | Turn the complete local setup off |
| [`catalex local-setup on`](#catalex-local-setup-on) | Turn the complete local setup on |
| [`catalex login`](#catalex-login) | Sign in to your CatalEx account from this terminal |
| [`catalex login-codes`](#catalex-login-codes) | Create one-time codes that sign in another device |
| [`catalex login-codes create`](#catalex-login-codes-create) | Create a one-time code that signs in another device as you |
| [`catalex logout`](#catalex-logout) | Sign out of your CatalEx account on this computer |
| [`catalex messages`](#catalex-messages) | Send a message for an agent without waiting for the person to write |
| [`catalex messages send`](#catalex-messages-send) | Send a message to one of an agent's people now |
| [`catalex messages status`](#catalex-messages-status) | Show the outcome of a message an agent sent |
| [`catalex open`](#catalex-open) | Launch or focus the CatalEx app at a view |
| [`catalex path`](#catalex-path) | Put the commands' folder on your login shell's PATH, or take it off |
| [`catalex path add`](#catalex-path-add) | Add the commands' folder to your login shell's profile once |
| [`catalex path remove`](#catalex-path-remove) | Remove the marked block from every login profile; other lines are kept |
| [`catalex path status`](#catalex-path-status) | Show whether new terminals find the commands |
| [`catalex prepare`](#catalex-prepare) | Make sure CatalEx's management service is ready on this computer |
| [`catalex projects`](#catalex-projects) | Manage the folders native chats work in |
| [`catalex projects add`](#catalex-projects-add) | Register a folder on the selected computer |
| [`catalex projects edit`](#catalex-projects-edit) | Change a folder's label, topic or rich-card choice |
| [`catalex projects list`](#catalex-projects-list) | List registered folders with their labels and rich-card choice |
| [`catalex providers`](#catalex-providers) | Show every AI provider, its version, state and whether it is connected |
| [`catalex providers connect`](#catalex-providers-connect) | Use an installed, signed-in provider (codex or claude) in this setup |
| [`catalex providers disconnect`](#catalex-providers-disconnect) | Stop using a provider (codex or claude) in this setup |
| [`catalex providers discover`](#catalex-providers-discover) | Detect every AI provider again and list it |
| [`catalex providers login`](#catalex-providers-login) | Sign in to Codex or Claude Code with its own sign-in on this computer |
| [`catalex refresh`](#catalex-refresh) | Re-verify installed agents and their model inventory |
| [`catalex restart`](#catalex-restart) | Restart CatalEx on the selected computer |
| [`catalex settings`](#catalex-settings) | Show the Developer settings catalog with defaults and ranges |
| [`catalex settings advanced`](#catalex-settings-advanced) | Show the Advanced settings in people's units |
| [`catalex settings advanced set`](#catalex-settings-advanced-set) | Change Advanced settings; unnamed values are kept |
| [`catalex settings endpoints`](#catalex-settings-endpoints) | Inspect or safely move this computer's control listener |
| [`catalex settings endpoints deployments`](#catalex-settings-endpoints-deployments) | Inspect or migrate positively owned deployment listeners |
| [`catalex settings endpoints deployments operation`](#catalex-settings-endpoints-deployments-operation) | Inspect an original deployment operation without another mutation |
| [`catalex settings endpoints deployments recover`](#catalex-settings-endpoints-deployments-recover) | Explicitly reconcile the original fenced deployment operation |
| [`catalex settings endpoints deployments set`](#catalex-settings-endpoints-deployments-set) | Move one advertised active listener without changing its owner |
| [`catalex settings endpoints deployments show`](#catalex-settings-endpoints-deployments-show) | Read active fields, supported handoffs and their original operation |
| [`catalex settings endpoints operation`](#catalex-settings-endpoints-operation) | Inspect the original endpoint transition without resending it |
| [`catalex settings endpoints recover`](#catalex-settings-endpoints-recover) | Reconcile the original fenced endpoint operation |
| [`catalex settings endpoints set`](#catalex-settings-endpoints-set) | Reserve and hand off a positively owned control endpoint |
| [`catalex settings endpoints show`](#catalex-settings-endpoints-show) | Read the owned control endpoint and its nonsecret revision |
| [`catalex settings set`](#catalex-settings-set) | Change settings; null restores a default |
| [`catalex setup`](#catalex-setup) | Set up CatalEx: CatalEx Cloud, everything on this computer or a CatalEx service URL |
| [`catalex start`](#catalex-start) | Start CatalEx on the selected computer |
| [`catalex status`](#catalex-status) | Show CatalEx's setup, operation and component states on the selected computer |
| [`catalex status metrics`](#catalex-status-metrics) | Show how many calls CatalEx makes and receives |
| [`catalex stop`](#catalex-stop) | Stop CatalEx on the selected computer |
| [`catalex transcript`](#catalex-transcript) | Show a Slack or WhatsApp conversation's read-only snapshot |
| [`catalex uninstall`](#catalex-uninstall) | Remove installed components; saved data is kept |
| [`catalex update`](#catalex-update) | Update the installed components to the newest release |
| [`catalex usage`](#catalex-usage) | Show CPU, memory, disk and token usage per chat and service |
| [`catalex version`](#catalex-version) | Show the installed client version |

## catalex account

Show your CatalEx account sign-in, print an access token or move the account.

```text
catalex account
```

Examples:

```sh
  catalex account status
  catalex account token --json
  catalex account move --to https://catalex.example.com
```

## catalex account delete

Delete your CatalEx account and its chat history.

Delete your CatalEx account for good: its computers, signed-in devices,
messaging accounts, routes and the chat history of every conversation are
erased from the account service, and nothing can bring them back. Other
computers are only signed out and keep their local data. This computer
then removes everything CatalEx keeps here (its agents list, native
chats, history, logs, settings, the sign-in and the app's setup) but never your
agent folders. Slack, WhatsApp and Google Chat apps stay at their
providers; the result lists what to remove there. It shows the impact
and asks you to type the account email, or pass --yes with --confirm-email
without a terminal. Needs a device trusted for changes. A deletion whose
answer was lost finishes when you run the same command again.

With --uninstall, once the deletion is accepted and this computer's data
is gone, CatalEx itself is removed from this computer too, as
catalex uninstall --purge does. If the deletion is refused or its answer
is unknown, nothing is removed or uninstalled. A running CatalEx app is
left for you to quit; then run catalex uninstall --purge.

```text
catalex account delete [flags]
```

Examples:

```sh
  catalex account delete
  catalex account delete --uninstall
  catalex account delete --yes --confirm-email me@example.com --json
```

Flags:

```text
      --confirm-email string   The account email, typed in advance: confirms the deletion without a terminal
      --impact                 Only show what deleting the account would erase; nothing is deleted
      --uninstall              Also remove CatalEx from this computer after the deletion, as catalex uninstall --purge does
      --yes                    Delete without asking; needs --confirm-email
```

## catalex account move

Move your account to another messaging service.

Move your CatalEx account to another messaging service (CatalEx Cloud or
another CatalEx service), in either direction. It shows what the move
changes, asks you to type the account email, signs you in on the new
service and verifies that sign-in before anything changes on the old one,
then asks before signing the move with this device's key. Every computer
leaves the account and rejoins with a join code from the new service;
chat history stays on the old service and Slack and WhatsApp connect
again there. Needs a recent sign-in that a device you use trusts. A move
whose answer was lost finishes when you run the same command again.

```text
catalex account move [flags]
```

Examples:

```sh
  catalex account move --to https://catalex.example.com
  catalex account move --to https://catalex.example.com --google
```

Flags:

```text
      --confirm-email string   The account email, typed in advance: confirms the move without a terminal
      --google                 Sign in on the new service with Google in the system browser (the only way; implied)
      --to string              The new messaging service origin: HTTPS, or HTTP on a loopback address
```

## catalex account status

Show the sign-in state and the features that require login.

Show whether you are signed in to a CatalEx account and, while you are
not, the features that require login. The sign-in from catalex login is
shown; without one, you are signed out. Signing in is
optional: agents, native chats and your own server work without it.
Read-only.

```text
catalex account status
```

Examples:

```sh
  catalex account status
  catalex account status --json
```

## catalex account token

Print a short-lived access token for your account.

Print a short-lived access token for the signed-in account on stdout, for
the CatalEx app. --json adds its lifetime. A sign-in
removed from the account is signed out here too.

```text
catalex account token
```

Examples:

```sh
  catalex account token
  catalex account token --json
```

## catalex accounts

Manage named Slack, WhatsApp and Google Chat accounts.

```text
catalex accounts
```

Examples:

```sh
  catalex accounts list
  catalex accounts add --platform slack --name Work
```

## catalex accounts access

Show or change who may message an account.

Show or change an account's allowlist and blocklist, which the messaging
service applies to every message before any work starts. Slack entries are
email addresses; WhatsApp entries are phone numbers with their country code. A phone entry may end in * to cover every number that starts with it, such as +44*.
The blocklist wins over the allowlist. A refused person gets no reply.
Where an account can allow groups (WhatsApp Personal), --groups takes the group:<id> entries from catalex accounts candidates; --allow and --block take people only, and a group can't be blocked.

```text
catalex accounts access
```

Examples:

```sh
  catalex accounts access show ACCOUNT_ID
  catalex accounts access set ACCOUNT_ID --allow owner@example.com
```

## catalex accounts access set

Replace an account's allowlist or blocklist.

Replace the lists named by flags and keep the other. Each flag takes the
entries, comma-separated or repeated, or none to empty the list. An
allowlist admits only the people on it; an empty one admits everyone. The
rules revision is read first unless --revision names it.

```text
catalex accounts access set ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts access set ACCOUNT_ID --allow owner@example.com,colleague@example.com
  catalex accounts access set ACCOUNT_ID --groups group:120363001
  catalex accounts access set ACCOUNT_ID --block +15551234567
  catalex accounts access set ACCOUNT_ID --allow none
```

Flags:

```text
      --allow strings    Emails (Slack) or phone numbers (WhatsApp) to admit only, or none
      --block strings    Emails (Slack) or phone numbers (WhatsApp) to refuse, or none
      --groups strings   Groups to admit, as group:<id> entries from accounts candidates, or none
      --revision int     Rules revision from catalex accounts access show; omitted reads it first
```

## catalex accounts access show

Show an account's allowlist, blocklist and refusal counts.

```text
catalex accounts access show ACCOUNT_ID
```

Examples:

```sh
  catalex accounts access show ACCOUNT_ID
```

## catalex accounts add

Add a messaging app agent or admin account.

Add a messaging app account. An agent account, the
default, is available to agents once its setup finishes; an admin account
(--admin) reaches every agent and is never a channel; admin Slack bots aren't
available yet. The kind cannot change later: remove the account and add it
again. This saves only a reference: provider credentials stay with the
messaging service and are never sent here.

```text
catalex accounts add [flags]
```

Examples:

```sh
  catalex accounts add --platform slack --name Work
  catalex accounts add --platform whatsapp --name "Admin WhatsApp" --admin
```

Flags:

```text
      --admin             Add an admin account, which reaches every agent and is never a channel
      --name string       Display name of the account
      --platform string   Messaging platform: slack, whatsapp, googlechat or whatsapp_personal (experimental)
```

## catalex accounts admins

Show or change who may use an admin account.

An admin account admits only the people on its admin list: email addresses
for a Slack account and phone numbers with their country code for a
WhatsApp account. An empty list admits no one. Being on an agent account's
allowlist never puts a person on an admin list.

```text
catalex accounts admins
```

Examples:

```sh
  catalex accounts admins list ACCOUNT_ID
  catalex accounts admins add ACCOUNT_ID --email owner@example.com
```

## catalex accounts admins add

Add people to an admin account's list.

Add email addresses (Slack) or phone numbers with their country code
(WhatsApp) to an admin account's list; repeat a flag for each. People
already on the list stay. The change applies to their next message.

```text
catalex accounts admins add ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts admins add ACCOUNT_ID --email owner@example.com
  catalex accounts admins add ACCOUNT_ID --phone +447700900123
```

Flags:

```text
      --email strings   A Slack person's email address; repeat for each
      --phone strings   A WhatsApp phone number with its country code, such as +447700900123; repeat for each
```

## catalex accounts admins list

List the people an admin account admits.

```text
catalex accounts admins list ACCOUNT_ID
```

Examples:

```sh
  catalex accounts admins list ACCOUNT_ID
  catalex accounts admins list ACCOUNT_ID --json
```

## catalex accounts admins remove

Remove people from an admin account's list.

Remove email addresses or phone numbers from an admin account's list;
repeat a flag for each. A removed person is refused at their next message.

```text
catalex accounts admins remove ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts admins remove ACCOUNT_ID --email colleague@example.com
```

Flags:

```text
      --email strings   A Slack person's email address; repeat for each
      --phone strings   A WhatsApp phone number with its country code, such as +447700900123; repeat for each
```

## catalex accounts agents

Remove an agent from a shared account or set its engagement depth there.

```text
catalex accounts agents
```

Examples:

```sh
  catalex accounts agents remove ACCOUNT_ID --agent AGENT_ID
  catalex accounts agents engagement show ACCOUNT_ID --agent AGENT_ID
```

## catalex accounts agents engagement

Show or set an agent's engagement depth on a shared account.

```text
catalex accounts agents engagement
```

Examples:

```sh
  catalex accounts agents engagement show ACCOUNT_ID --agent AGENT_ID
  catalex accounts agents engagement set ACCOUNT_ID --agent AGENT_ID low
```

## catalex accounts agents engagement set

Set how often an agent joins conversations on a shared account.

Set the agent's engagement depth on this account to low, medium or high,
or default to use the agent's own setting. It applies to the agent's next
message on the account and changes nothing on its other channels.

```text
catalex accounts agents engagement set ACCOUNT_ID --agent AGENT_ID VALUE [flags]
```

Examples:

```sh
  catalex accounts agents engagement set ACCOUNT_ID --agent AGENT_ID high
  catalex accounts agents engagement set ACCOUNT_ID --agent AGENT_ID default
```

Flags:

```text
      --agent string   Agent ID
```

## catalex accounts agents engagement show

Show how often an agent joins conversations on a shared account.

Show the agent's engagement depth on the account: low, medium or high, or
its own default (set on the agent) when the account has no override.

```text
catalex accounts agents engagement show ACCOUNT_ID --agent AGENT_ID [flags]
```

Examples:

```sh
  catalex accounts agents engagement show ACCOUNT_ID --agent AGENT_ID
```

Flags:

```text
      --agent string   Agent ID
```

## catalex accounts agents remove

Remove an agent from a shared account.

Remove one agent from an account several agents share. The account stays
linked while other agents use it; removing the last agent disconnects it.
The command asks first (default No), or --yes confirms. Without a terminal
it refuses unless --yes is given.

```text
catalex accounts agents remove ACCOUNT_ID --agent AGENT_ID [flags]
```

Examples:

```sh
  catalex accounts agents remove ACCOUNT_ID --agent AGENT_ID
  catalex accounts agents remove ACCOUNT_ID --agent AGENT_ID --yes
```

Flags:

```text
      --agent string   Agent ID to remove
      --yes            Confirm without asking
```

## catalex accounts agents settings

Show or set an agent's own settings on a shared account.

Show or set what is the agent's own on a shared account: how long it stays
quiet in a chat after you reply there yourself. Another agent on the same
number keeps its own.

```text
catalex accounts agents settings
```

Examples:

```sh
  catalex accounts agents settings show ACCOUNT_ID --agent AGENT_ID
  catalex accounts agents settings set ACCOUNT_ID --agent AGENT_ID owner_pause_minutes=30
```

## catalex accounts agents settings set

Change an agent's settings on a shared account.

Change the named settings of the agent and keep the others. A minutes
setting takes a whole number in its range, or off. It applies from the agent's next message and changes nothing for the number's
other agents.

```text
catalex accounts agents settings set ACCOUNT_ID --agent AGENT_ID NAME=VALUE... [flags]
```

Examples:

```sh
  catalex accounts agents settings set ACCOUNT_ID --agent AGENT_ID owner_pause_minutes=30
  catalex accounts agents settings set ACCOUNT_ID --agent AGENT_ID owner_pause_minutes=off
```

Flags:

```text
      --agent string   Agent ID
```

## catalex accounts agents settings show

Show an agent's settings on a shared account.

```text
catalex accounts agents settings show ACCOUNT_ID --agent AGENT_ID [flags]
```

Examples:

```sh
  catalex accounts agents settings show ACCOUNT_ID --agent AGENT_ID
```

Flags:

```text
      --agent string   Agent ID
```

## catalex accounts agents switches

Show or set an agent's chat commands and system messages on a channel.

Show or set two switches of an agent on one channel. Chat commands decides
whether messages such as /help, /status and /new work in the channel's chats;
off, a message starting with / reaches the agent as ordinary text. System
messages decides whether CatalEx's own notices reach the people in the channel;
off, the notices still show in the app. Another channel of the agent, and
another agent on the channel, keep their own.

```text
catalex accounts agents switches
```

Examples:

```sh
  catalex accounts agents switches show ACCOUNT_ID --agent AGENT_ID
  catalex accounts agents switches set ACCOUNT_ID --agent AGENT_ID --chat-commands off
```

## catalex accounts agents switches set

Change an agent's switches on a channel.

Change the switches you name and keep the other. It applies from the agent's next message.

```text
catalex accounts agents switches set ACCOUNT_ID --agent AGENT_ID [--chat-commands on|off] [--system-messages on|off] [flags]
```

Examples:

```sh
  catalex accounts agents switches set ACCOUNT_ID --agent AGENT_ID --chat-commands off
  catalex accounts agents switches set ACCOUNT_ID --agent AGENT_ID --chat-commands on --system-messages on
```

Flags:

```text
      --agent string             Agent ID
      --chat-commands string     Whether chat commands work in this channel: on or off
      --system-messages string   Whether CatalEx's own notices reach the people in this channel: on or off
```

## catalex accounts agents switches show

Show an agent's switches on a channel.

```text
catalex accounts agents switches show ACCOUNT_ID --agent AGENT_ID [flags]
```

Examples:

```sh
  catalex accounts agents switches show ACCOUNT_ID --agent AGENT_ID
```

Flags:

```text
      --agent string   Agent ID
```

## catalex accounts candidates

List the people and groups that can reach an account.

List the people and groups an account's owner can let reach the agent, each with
the entry to give catalex accounts access set: person entries to --allow,
group entries to --groups. With no flags it lists the top 100: the most recent
chats first, then saved contacts by name. --search looks for the people and
groups whose name or number matches. On a number shared by agents, a HELD BY
column names every agent that holds a row.
--groups lists the groups the account is in instead, the 100 most recent unless
--limit asks for more, with the agents that hold each; a cut list ends with a
note to narrow it with --search.

```text
catalex accounts candidates ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts candidates ACCOUNT_ID
  catalex accounts candidates ACCOUNT_ID --search family --limit 10
  catalex accounts candidates ACCOUNT_ID --agent AGENT_ID
  catalex accounts candidates ACCOUNT_ID --groups --search family
```

Flags:

```text
      --agent string    Agent ID whose entries on a shared account mark who is already added
      --groups          List the groups the account is in, with who holds each (the newest 100 unless --limit)
      --limit int       Show at most this many; the service bounds the list (default 100)
      --search string   Search the people and groups by name or number
```

## catalex accounts chats

List an account's chats and read a chat's messages.

List an account's chats, newest first, each titled by its person, and read
a chat's messages. By default the list is this computer's chats; with
controller.show_other_computers_chats set (catalex settings set
controller.show_other_computers_chats=true) it also lists the chats the
messaging service holds for the account on your other computers and those
whose messages were all over a rate limit.

```text
catalex accounts chats
```

Examples:

```sh
  catalex accounts chats list ACCOUNT_ID
  catalex accounts chats show ACCOUNT_ID CHAT
```

## catalex accounts chats answer

Answer a messaging chat's question.

Answer a question the agent asked in a Slack, WhatsApp or Google Chat
conversation, with a choice ID from accounts chats show (--option) or a
typed answer (standard input or --text-file).

```text
catalex accounts chats answer ACCOUNT_ID CHAT [flags]
```

Examples:

```sh
  catalex accounts chats answer ACCOUNT_ID CHAT --operation OPERATION_ID --option yes
  echo "Use staging" | catalex accounts chats answer ACCOUNT_ID CHAT --operation OPERATION_ID
```

Flags:

```text
      --operation string   Operation ID of the open request, from accounts chats show
      --option string      Option ID the request lists, such as allow or deny
      --text-file string   Read a typed answer from this file instead of standard input
```

## catalex accounts chats approve

Approve or deny a messaging chat's permission request.

Decide a permission request the agent raised in a Slack, WhatsApp or Google
Chat conversation, with one of its option IDs from accounts chats show,
denial included. The person at this computer is recorded as the decider,
the agent continues, and the provider's card shows who decided.

```text
catalex accounts chats approve ACCOUNT_ID CHAT [flags]
```

Examples:

```sh
  catalex accounts chats approve ACCOUNT_ID CHAT --operation OPERATION_ID --option allow
  catalex accounts chats approve ACCOUNT_ID CHAT --operation OPERATION_ID --option deny
```

Flags:

```text
      --operation string   Operation ID of the open request, from accounts chats show
      --option string      Option ID the request lists, such as allow or deny
```

## catalex accounts chats delete

Delete a messaging chat and stop its agent.

Delete one chat of a messaging account from CatalEx and from this computer,
and stop its running agent, even in the middle of a turn. Messages in the
messaging app stay. The person's next message starts a new chat.
Name the chat by its reference (CHAT, with --expected-session set to its
service_session_id from accounts chats list --json), or a throttled-only
conversation with --conversation. Without --yes a terminal is asked first.
After an uncertain result repeat the command with the same --operation-id.

```text
catalex accounts chats delete ACCOUNT_ID [CHAT] [flags]
```

Examples:

```sh
  catalex accounts chats delete ACCOUNT_ID CHAT --expected-session SESSION_ID
  catalex accounts chats delete ACCOUNT_ID --conversation KEY --yes
  catalex accounts chats delete ACCOUNT_ID CHAT --expected-session SESSION_ID --operation-id ORIGINAL_ID --yes --json
```

Flags:

```text
      --conversation string       Delete the throttled-only messages of this provider conversation instead of a chat
      --expected-session string   The chat's service_session_id from accounts chats list --json
      --operation-id string       Repeat a delete using its original operation ID
      --yes                       Delete without asking; the chat, its messages and its agent session are removed
```

## catalex accounts chats list

List an account's chats, newest first, one page at a time.

```text
catalex accounts chats list ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts chats list ACCOUNT_ID
  catalex accounts chats list ACCOUNT_ID --limit 10 --cursor CURSOR --json
```

Flags:

```text
      --cursor string   Continue from the cursor a previous page printed
      --limit int       Read at most this many chats; CatalEx bounds a page
```

## catalex accounts chats requests

List the requests the account's agent is waiting on, across its chats.

List every open permission request and question the agent raised in any
chat of a Slack, WhatsApp or Google Chat account, with the chat it came
from. Decide one with accounts chats approve or accounts chats answer;
the CatalEx app shows the same requests.

```text
catalex accounts chats requests ACCOUNT_ID
```

Examples:

```sh
  catalex accounts chats requests ACCOUNT_ID
  catalex accounts chats requests ACCOUNT_ID --json
```

## catalex accounts chats show

Read one page of a chat's messages, oldest first.

Read one page of a chat's messages, oldest first, by the chat that
catalex accounts chats list names. CatalEx reads them from the
messaging service and keeps a copy; when the service does not answer, it
shows its copy.

```text
catalex accounts chats show ACCOUNT_ID CHAT [flags]
```

Examples:

```sh
  catalex accounts chats show ACCOUNT_ID CHAT
  catalex accounts chats show ACCOUNT_ID CHAT --cursor CURSOR --json
```

Flags:

```text
      --cursor string   Continue from the cursor a previous page printed
      --limit int       Read at most this many messages; CatalEx bounds a page
```

## catalex accounts clear-setups

Remove every account whose setup was started and not finished.

Remove each agent account added for an agent whose setup was started and
not finished, so no agent has a channel on it yet. A channel setup is either
finished or cleared; CatalEx keeps nothing to finish later. An app whose
setup CatalEx holds also ends that setup at the service. Accounts with a
channel, available accounts and admin accounts are never touched. Run it
again after a failure; it asks nothing.

```text
catalex accounts clear-setups [flags]
```

Examples:

```sh
  catalex accounts clear-setups
  catalex accounts clear-setups --agent AGENT_ID
```

Flags:

```text
      --agent string   Clear only the setups started for this agent ID
```

## catalex accounts entries

Show or change the entries each agent answers on a shared account.

Several agents can share one linked number. Each answers the entries it
holds: a phone number, a prefix ending in * such as +44*, or a group:<id>
from catalex accounts candidates. Two agents can't hold overlapping entries;
an entry another agent holds is not added, is listed with that agent, and the
command exits with status 5.

```text
catalex accounts entries
```

Examples:

```sh
  catalex accounts entries show ACCOUNT_ID
  catalex accounts entries add ACCOUNT_ID --agent AGENT_ID +44*
```

## catalex accounts entries add

Add entries to an agent, joining the account when it is not on it yet.

```text
catalex accounts entries add ACCOUNT_ID --agent AGENT_ID [ENTRY...] [--group NAME_OR_ID]... [flags]
```

Examples:

```sh
  catalex accounts entries add ACCOUNT_ID --agent AGENT_ID +44* +919820041712
  catalex accounts entries add ACCOUNT_ID --agent AGENT_ID --group Family
```

Flags:

```text
      --agent string        Agent ID
      --group stringArray   A group: group:<id>, its id or its exact name; repeat for more
```

## catalex accounts entries move

Move entries from one agent to another.

```text
catalex accounts entries move ACCOUNT_ID --from AGENT_ID --to AGENT_ID ENTRY... [flags]
```

Examples:

```sh
  catalex accounts entries move ACCOUNT_ID --from AGENT_ID --to AGENT_ID +44*
```

Flags:

```text
      --from string   Agent ID that holds the entries now
      --to string     Agent ID that takes the entries
```

## catalex accounts entries remove

Remove entries from an agent.

```text
catalex accounts entries remove ACCOUNT_ID --agent AGENT_ID [ENTRY...] [--group NAME_OR_ID]... [flags]
```

Examples:

```sh
  catalex accounts entries remove ACCOUNT_ID --agent AGENT_ID +44* +919820041712
  catalex accounts entries remove ACCOUNT_ID --agent AGENT_ID --group Family
```

Flags:

```text
      --agent string        Agent ID
      --group stringArray   A group: group:<id>, its id or its exact name; repeat for more
```

## catalex accounts entries show

Show the agents of an account with their entries.

```text
catalex accounts entries show ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts entries show ACCOUNT_ID
  catalex accounts entries show ACCOUNT_ID --agent AGENT_ID
```

Flags:

```text
      --agent string   Show only this agent ID
```

## catalex accounts health

Show each account's health and how to fix it.

Show each Slack, WhatsApp and Google Chat account's own health from the
messaging service you are signed in to: Healthy, Needs attention, Check
incomplete, or Not checked when the service has not checked it yet. It needs
you to be signed in. Fixes
for an account that needs attention are printed after the list. --json
carries each account's codes, remedy actions and counts.

```text
catalex accounts health [ACCOUNT_ID]
```

Examples:

```sh
  catalex accounts health
  catalex accounts health ACCOUNT_ID --json
```

## catalex accounts limits

Show or change an account's rate limits and throttled messages.

Show or change an account's rate limits, with this window's use. Messages
over a limit start no work and get no reply, reaction or read receipt; the
messaging service keeps them for you to review with throttled. CatalEx
commands and answers to questions never count. Every limit is off until set.

```text
catalex accounts limits
```

Examples:

```sh
  catalex accounts limits show ACCOUNT_ID
  catalex accounts limits set ACCOUNT_ID --per-person-hour 20
```

## catalex accounts limits set

Change an account's rate limits.

Change the limits named by flags and keep the others. Each takes a whole
number of at least 1, or none to remove the limit. An hour is the last 60
minutes and a day the last 24 hours. A value above the messaging
service's ceiling is refused with RATE_LIMIT_ABOVE_CEILING.

```text
catalex accounts limits set ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts limits set ACCOUNT_ID --per-person-hour 20 --total-day 500
  catalex accounts limits set ACCOUNT_ID --new-people-day 5
  catalex accounts limits set ACCOUNT_ID --turns none
```

Flags:

```text
      --agent string             Agent ID whose limits on a shared account to use; a shared account needs it
      --new-people-day string    New people, per day: a whole number, or none
      --people-day string        People, per day: a whole number, or none
      --people-hour string       People, per hour: a whole number, or none
      --per-person-day string    Messages per person, per day: a whole number, or none
      --per-person-hour string   Messages per person, per hour: a whole number, or none
      --revision int             Rules revision from catalex accounts limits show; omitted reads it first
      --total-day string         Messages in total, per day: a whole number, or none
      --total-hour string        Messages in total, per hour: a whole number, or none
      --turns string             Turns at once: a whole number, or none
```

## catalex accounts limits show

Show an account's limits with this window's use.

```text
catalex accounts limits show ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts limits show ACCOUNT_ID
```

Flags:

```text
      --agent string   Agent ID whose limits on a shared account to use; a shared account needs it
```

## catalex accounts limits throttled

List an account's most recent throttled messages.

```text
catalex accounts limits throttled ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts limits throttled ACCOUNT_ID
  catalex accounts limits throttled ACCOUNT_ID --limit 10 --json
```

Flags:

```text
      --limit int   Show at most this many, newest first; the service bounds the list
```

## catalex accounts list

List accounts with their kind, state, agent and rules.

List the Slack, WhatsApp and Google Chat accounts with their kind (agent or
admin), state (Setup not finished, Available, Used by an agent, or Ready for
an admin account) and rules: how many people are allowed and blocked and how
many limits are set. An account the messaging service reports as degraded adds
· Needs attention to its state, and its fixes are printed after the list.
--json carries the same fields, the rules as "rules" and the account's
health as "health" (as accounts health shows it) when you are signed in.

```text
catalex accounts list
```

Examples:

```sh
  catalex accounts list
  catalex accounts list --json
```

## catalex accounts manager

Manage a number's CatalEx Manager group.

```text
catalex accounts manager
```

Examples:

```sh
  catalex accounts manager recreate ACCOUNT_ID
```

## catalex accounts manager recreate

Create the CatalEx Manager group of a number again.

Create the CatalEx Manager group of a connected number again. The group is the
chat where you list and manage your agents; the old one, if any, stops being
the manager channel. A number that is not connected is refused.

```text
catalex accounts manager recreate ACCOUNT_ID
```

Examples:

```sh
  catalex accounts manager recreate ACCOUNT_ID
```

## catalex accounts remove

Remove a saved account.

Remove a saved account after confirmation (default No). Provider
credentials are not touched, except that an app whose setup CatalEx holds
stops answering and its conversations are kept (removed for a linked
number); the app and its key stay in
the provider's console until you delete them there. Without a terminal, use
--yes to confirm.

```text
catalex accounts remove ID [flags]
```

Examples:

```sh
  catalex accounts remove ACCOUNT_ID
  catalex accounts remove ACCOUNT_ID --yes
```

Flags:

```text
      --yes   Confirm removing the saved account without asking
```

## catalex accounts remove-link

Remove a shared number that no agent uses.

Remove a shared number that has no agents left and disconnect its device.
The command asks first (default No), or --yes confirms. Without a terminal
it refuses unless --yes is given. A number that still has agents is refused
(exit 5): remove its agents first.

```text
catalex accounts remove-link ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts remove-link ACCOUNT_ID
  catalex accounts remove-link ACCOUNT_ID --yes
```

Flags:

```text
      --yes   Confirm without asking
```

## catalex accounts routes

List or remove the channels of agents whose computer is offline or removed.

A Slack bot, WhatsApp Business number or Google Chat app routes to one agent. When that
agent's computer is offline or was removed, the channel stays routed to it. show lists
them; remove leaves the channel without an agent so it can connect to another one. A
channel whose computer is connected is refused (exit 5): remove it from that computer.

```text
catalex accounts routes
```

Examples:

```sh
  catalex accounts routes show
  catalex accounts routes remove ACCOUNT_ID --yes
```

## catalex accounts routes remove

Remove a channel from an agent on an offline computer.

```text
catalex accounts routes remove ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts routes remove ACCOUNT_ID
  catalex accounts routes remove ACCOUNT_ID --yes
```

Flags:

```text
      --provider string   Only look among this provider's channels
      --yes               Confirm without asking
```

## catalex accounts routes show

List the channels of agents on offline computers.

```text
catalex accounts routes show [flags]
```

Examples:

```sh
  catalex accounts routes show
  catalex accounts routes show --provider slack
```

Flags:

```text
      --provider string   Only this provider's channels
```

## catalex accounts template

Show or change the template an account uses to start conversations.

Show or change the approved template an account sends when an agent starts a
conversation outside the app's delivery window. The template needs exactly one
body parameter, which carries the agent's text. Only an account whose app sends
templates has one. Without a template, such a message is held until the person
next writes.

```text
catalex accounts template
```

Examples:

```sh
  catalex accounts template show ACCOUNT_ID
  catalex accounts template set ACCOUNT_ID --name agent_message --language en
```

## catalex accounts template clear

Remove an account's proactive template.

Remove the account's proactive template. A message an agent starts outside the
app's delivery window is then held until the person next writes.

```text
catalex accounts template clear ACCOUNT_ID
```

Examples:

```sh
  catalex accounts template clear ACCOUNT_ID
```

## catalex accounts template set

Register an account's proactive template.

Register the template an account sends to start a conversation, by the name
and language your app approved. It replaces the account's earlier template.
The app must approve a template with exactly one body parameter; a template of
another shape is refused with TEMPLATE_PARAMETERS_INVALID when the app lets
CatalEx read it, and otherwise fails at its first send.

```text
catalex accounts template set ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex accounts template set ACCOUNT_ID --name agent_message --language en
```

Flags:

```text
      --language string   Language code of the approved template, such as en
      --name string       Name of the template your app approved
```

## catalex accounts template show

Show an account's proactive template.

```text
catalex accounts template show ACCOUNT_ID
```

Examples:

```sh
  catalex accounts template show ACCOUNT_ID
```

## catalex agents

Manage the selected computer's saved agents.

```text
catalex agents
```

Examples:

```sh
  catalex agents list
  catalex agents add --name Helper --folder /path/on/computer
```

## catalex agents activity

List settings changes made to an agent.

List the settings changes made to an agent, newest first, with the time and
where each was made: an admin Slack app or WhatsApp number, with the
account and the person, or catalex or the CatalEx app on its computer.

```text
catalex agents activity AGENT_ID
```

Examples:

```sh
  catalex agents activity AGENT_ID
  catalex agents activity AGENT_ID --json
```

## catalex agents add

Add an agent with its folder and AI settings.

Add an agent that works in a folder on the selected computer.
The folder is resolved there, never against this terminal's directory.
Without --agent, --model or --effort the defaults for new agents apply.

```text
catalex agents add [flags]
```

Examples:

```sh
  catalex agents add --name Helper --folder /Users/me/project
  catalex agents add --name Helper --folder /Users/me/project --agent claude --model haiku
  catalex agents add --name Doctor --folder /Users/me/doctor-agent --agent claude --isolation folder
```

Flags:

```text
      --agent string        AI provider the agent runs on: codex or claude (from catalex providers)
      --effort string       Reasoning effort the model supports, such as low, medium or high
      --folder string       Absolute existing folder on the selected computer
      --isolation string    folder: start the Claude Code agent with only its folder's settings and MCP servers; none: the default
      --model string        Verified model ID from catalex defaults show; empty uses the provider's own default
      --name string         Display name of the agent
      --person-arg string   SERVER=FLAG[,DETAILS_FLAG]: the folder's MCP server and the flag that picks its person; CatalEx starts that server with the flag set to each chat's person ID, and with DETAILS_FLAG, when given, set to the person's details as JSON, such as their name and phone number, left out when CatalEx has none (Claude Code only; the folder's files stay as they are)
      --use-defaults        Use the defaults for new agents instead of --agent, --model and --effort
```

## catalex agents behavior

Show or change saved engagement and writing preferences.

Show saved preferences and the server's application state. Supply only the
preferences to change; omitted flags keep their saved values. The revision
is read first unless --revision names it. A save does not prove native
application. Frequency is loose send guidance; complete long replies remain
valid.
Removing managed Humanizer guidance keeps existing chat history.
Rich formats are the formats CatalEx shows in replies besides text: charts and
graphs, and interactive cards. Each is allowed unless set to not_allowed;
with both not_allowed, replies are text only. While charts are allowed,
CatalEx also suggests a chart where one helps. Media sharing decides whether the
agent shares files, images and audio through CatalEx; when not_allowed, it
answers in text instead.

```text
catalex agents behavior [flags]
```

Examples:

```sh
  catalex agents behavior --agent ID
  catalex agents behavior --agent ID --engagement-frequency low
  catalex agents behavior --agent ID --tone professional --humanize-outputs=false
  catalex agents behavior --agent ID --charts not_allowed --interactive-cards allowed
  catalex agents behavior --agent ID --share-media not_allowed
```

Flags:

```text
      --agent string                  Saved agent ID
      --charts string                 Show charts and graphs in replies: allowed or not_allowed
      --engagement-frequency string   Loose send cadence: low, medium or high
      --humanize-outputs              Use managed Humanizer writing guidance; =false removes future managed selection, keeping history
      --interactive-cards string      Show interactive cards in replies: allowed or not_allowed
      --revision int                  Expected behavior revision; a stale revision is refused without retrying
      --share-media string            Share files, images and audio through CatalEx: allowed or not_allowed
      --tone string                   Writing tone: default, professional or friendly
```

## catalex agents delete

Delete a saved agent and everything CatalEx keeps for it.

Delete a saved agent and everything CatalEx keeps for it: its conversations,
files and the connected accounts only it uses, on this computer and in
CatalEx Cloud. This can't be undone. Its folder and your files stay.
The command names the accounts it removes and asks first (default No), or
--yes confirms. Without a terminal it refuses unless --yes is given.
If the cloud cannot be reached, the data there is erased when this computer
reconnects. After an uncertain result repeat the command with the same
--operation-id.

```text
catalex agents delete AGENT_ID [flags]
```

Examples:

```sh
  catalex agents delete AGENT_ID
  catalex agents delete AGENT_ID --yes
  catalex agents delete AGENT_ID --operation-id ORIGINAL_ID --yes --json
```

Flags:

```text
      --operation-id string   Repeat a delete using its original operation ID
      --yes                   Confirm without asking; the agent, its conversations, files and the accounts only it uses are deleted, and a WhatsApp Personal number is disconnected
```

## catalex agents discover

List agent folders where Claude Code or Codex ran lately.

List up to 12 folders on this computer where Claude Code or Codex ran
lately and that are set up as an agent, newest first, one per folder,
as candidates to connect with agents onboard. A folder is set up as an
agent when it holds SOUL.md or IDENTITY.md, or a Claude Code output
style that replaces the coding prompt, or when it holds CLAUDE.md
or AGENTS.md and no build manifest (package.json, go.mod and the
like). Code projects, git worktrees and temporary folders are not
listed, nor are your home folder, CatalEx's own folders and hidden
tool folders (such as ~/.claude-mem). The check reads a few small
files each time and changes nothing; whatever it cannot read counts
as absent, so an empty list is a valid answer.

```text
catalex agents discover
```

Examples:

```sh
  catalex agents discover
  catalex agents discover --json
```

## catalex agents edit

Rename an agent or change its AI, model and effort.

Change a saved agent. Unspecified values are kept. A model or effort
must be one the AI offers; otherwise the command fails with the valid options
(valid_options with --json) and saves nothing. An empty --model or --effort
saves nothing for that setting, so the next launch uses the default order
that catalex defaults show reports. A new chat
takes the agent's latest model and effort; an existing chat keeps the ones it started with.

Changing the AI, model or effort only saves them: CatalEx starts no session and
runs no AI. An AI that cannot start in the folder is reported when you send the
agent its next message. Moving the agent to another AI with --agent also repairs
its folder for that AI, as catalex agents onboard --apply does. A move whose
tool choices cannot be kept without widening them fails at once with
AGENT_TOOLS_NOT_CARRIED and saves nothing. Otherwise CatalEx carries the tool
choices to the new AI when its tools are first read, which --json data.tools
does right away: it holds the tool permissions after the carry. A finding that
needs you leaves the agent saved and the command failing, with the findings.
--no-onboard only saves the agent.

```text
catalex agents edit ID [flags]
```

Examples:

```sh
  catalex agents edit AGENT_ID --name Reviewer
  catalex agents edit AGENT_ID --model gpt-5 --effort high
  catalex agents edit AGENT_ID --model '' --effort ''
  catalex agents edit AGENT_ID --agent codex
  catalex agents edit AGENT_ID --agent codex --no-onboard
  catalex agents edit AGENT_ID --isolation folder
  catalex agents edit DOCTOR_ID --delegate-to PATIENT_ID
  catalex agents edit PATIENT_ID --person-arg clinic=--patient
  catalex agents edit AGENT_ID --proactive-send on
```

Flags:

```text
      --agent string                AI provider the agent runs on: codex or claude (from catalex providers)
      --delegate-to strings         Agent IDs this agent may send messages to about one of its people, replacing the list; none clears it
      --effort string               Reasoning effort the model supports, such as low, medium or high
      --folder string               New absolute folder on the selected computer
      --isolation string            folder: start the Claude Code agent with only its folder's settings and MCP servers; none: clear it
      --message-new-people string   on or off: let the agent also message people it has not talked to; needs --proactive-send on. Consent under the messaging app's policy is your responsibility: CatalEx does not check it
      --model string                Verified model ID from catalex defaults show; empty uses the provider's own default
      --name string                 New display name
      --no-onboard                  With --agent, only save the agent: leave its folder and tool choices as they are
      --person-arg string           SERVER=FLAG[,DETAILS_FLAG]: the folder's MCP server and the flag that picks its person; CatalEx starts that server with the flag set to each chat's person ID, and with DETAILS_FLAG, when given, set to the person's details as JSON, such as their name and phone number, left out when CatalEx has none (Claude Code only; the folder's files stay as they are); none clears it
      --proactive-send string       on or off: let the agent send messages to its people without being asked; off by default, and off stops its queued and held sends
      --use-defaults                Use the defaults for new agents instead of --agent, --model and --effort
```

## catalex agents limits

Show or change an agent's rate limits across all its accounts.

Show or change one agent's own rate limits, counted across every Slack app
and WhatsApp number that reaches it, with this window's use. Token limits
count the tokens the agent's turns reported; once a window's tokens reach
the limit, new messages are not sent to the agent until the window ends,
and a turn already running finishes. Every limit but Turns at once is off
until set; a limit without one shows no limit and no throttled messages.
Turns at once is 10 until set: messages over it wait their turn on this
computer, and none restores 10. Saving keeps the use in the rolling windows.

The proactive limits cap the messages the agent sends without being asked
(catalex messages send): per hour and per day, and the new people it messages
per day. Unlike the others they are on by default; none restores the default.

```text
catalex agents limits
```

Examples:

```sh
  catalex agents limits show AGENT_ID
  catalex agents limits set AGENT_ID --day 100
```

## catalex agents limits set

Change an agent's rate limits.

Change the limits named by flags and keep the others. Each takes a whole
number of at least 1, or none to remove the limit. An hour is the last 60
minutes and a day the last 24 hours. A save keeps the use in those windows, so a throttled
agent stays throttled.

```text
catalex agents limits set AGENT_ID [flags]
```

Examples:

```sh
  catalex agents limits set AGENT_ID --day 100 --turns 2
  catalex agents limits set AGENT_ID --tokens-hour 50000 --tokens-day 400000
  catalex agents limits set AGENT_ID --hour none
  catalex agents limits set AGENT_ID --proactive-hour 10 --proactive-day 50
```

Flags:

```text
      --day string                        Messages to this agent, per day: a whole number, or none
      --hour string                       Messages to this agent, per hour: a whole number, or none
      --proactive-day string              Messages sent without being asked, per day: a whole number, or none
      --proactive-hour string             Messages sent without being asked, per hour: a whole number, or none
      --proactive-new-people-day string   New people messaged without being asked, per day: a whole number, or none
      --revision int                      Rules revision from catalex agents limits show; omitted reads it first
      --tokens-day string                 Tokens, per day: a whole number, or none
      --tokens-hour string                Tokens, per hour: a whole number, or none
      --turns string                      Turns at once: a whole number, or none
```

## catalex agents limits show

Show an agent's limits with this window's use.

```text
catalex agents limits show AGENT_ID
```

Examples:

```sh
  catalex agents limits show AGENT_ID
```

## catalex agents list

List saved agents, then the account's agents on other computers.

List the selected computer's saved agents with their folder and AI
settings, then the agents of the account's other computers they can send
messages to. An agent with no model or effort saved shows Default and the
value its next launch sends; a note names each value skipped on the way, and
why. With --json, each agent's resolved member holds the model, effort,
their sources and the skipped values, and messaging_live and messaging_running
say whether it has a WhatsApp or Slack session open or working a turn. An agent another computer no longer lists while a saved agent still
sends to it is shown unavailable; it receives nothing.

```text
catalex agents list
```

Examples:

```sh
  catalex agents list
  catalex agents list --json
```

## catalex agents onboard

Check an existing agent folder, repair it for CatalEx and register it.

Check whether an existing agent folder works when CatalEx starts its AI
there: its instructions, MCP servers, tool permissions, trust and launcher.
Without --apply nothing changes. With --apply, only the folder's own
instructions and settings files are repaired, then the folder is saved as
an agent unless a finding needs you first. Trust, hooks and launchers are
never changed. Without --folder, the agent gets a new folder named after
it in CatalEx's agents folder, created with --apply. Works with a Local
CatalEx on this computer.

```text
catalex agents onboard [flags]
```

Examples:

```sh
  catalex agents onboard --name "Recipe Buddy" --apply
  catalex agents onboard --folder /Users/me/doctor-agent --agent claude
  catalex agents onboard --folder /Users/me/doctor-agent --name "Doctor Assistant" --agent claude --apply
  catalex agents onboard --folder /Users/me/patient-agent --person-arg clinic=--patient --apply
```

Flags:

```text
      --agent string        AI provider the agent runs on: codex or claude; default: the saved agent's, then claude for a Claude Code folder, then the defaults for new agents
      --allow-sends         With --apply, let an agent message the agent whose people its tools show; false only reports it, as the app does to ask first (default true)
      --apply               Repair the folder's own files and save it as an agent
      --folder string       Absolute agent folder on this computer, the one its AI starts in; default: a new folder named after the agent in CatalEx's agents folder
      --isolation string    folder or none; default: the saved agent's, and with --apply folder when its launcher isolates a Claude Code agent
      --name string         Display name for a new agent; default: the saved name, else the folder name; without --folder, Assistant (Assistant 2, ... when taken)
      --person-arg string   SERVER=FLAG[,DETAILS_FLAG]: the folder's MCP server and the flag that picks its person; CatalEx starts that server with the flag set to each chat's person ID, and with DETAILS_FLAG, when given, set to the person's details as JSON, such as their name and phone number, left out when CatalEx has none (Claude Code only; the folder's files stay as they are); default: the saved agent's, none clears it
```

## catalex agents picture

Set, show or remove an agent's picture.

An agent's picture is the image the CatalEx app shows for it, cropped to a
circle, in place of its robot. It is a PNG, JPEG or WebP file within the
size CatalEx allows (1 MiB by default), kept with the agent's
settings on CatalEx.

```text
catalex agents picture
```

Examples:

```sh
  catalex agents picture set AGENT_ID doctor.png
  catalex agents picture show AGENT_ID
  catalex agents picture remove AGENT_ID
```

## catalex agents picture remove

Remove an agent's picture so its robot shows again.

```text
catalex agents picture remove AGENT_ID
```

Examples:

```sh
  catalex agents picture remove AGENT_ID
```

## catalex agents picture set

Set an agent's picture from an image file.

Set the picture of an agent from a PNG, JPEG or WebP file. CatalEx
checks the image itself, not its name, and refuses anything else or larger
than its limit.

```text
catalex agents picture set AGENT_ID FILE
```

Examples:

```sh
  catalex agents picture set AGENT_ID doctor.png
  catalex agents picture set AGENT_ID doctor.jpg --json
```

## catalex agents picture show

Show an agent's picture, or save its image to a file.

Say whether an agent has a picture, and its type. With --output, save the
image to a new file instead; bytes never mix with --json output.

```text
catalex agents picture show AGENT_ID [flags]
```

Examples:

```sh
  catalex agents picture show AGENT_ID
  catalex agents picture show AGENT_ID --output doctor.png
```

Flags:

```text
      --output string   File to create with the image (must not exist)
```

## catalex agents sync

Show whether earlier conversations are synced to the server.

Show where syncing your AI providers' earlier conversations to the server
stands, as Settings › Cloud in the CatalEx app says it: waiting for the
connection, syncing, synced, not synced yet (CatalEx tries again by itself),
unsupported by this server, or waiting for the server connection. Read-only.

```text
catalex agents sync
```

Examples:

```sh
  catalex agents sync
  catalex agents sync --json
```

## catalex agents tools

Inspect, discover or save an agent's tools and permissions.

Inspect native tool discovery and saved permissions on the selected
computer. Reading starts nothing. --discover may start the agent briefly,
without a prompt, to list every tool source its chats load, which starts its
tool servers; it never signs in or grants trust.
Built-in tools a provider lists (group builtin) are chosen with
--builtin-tool; leaving it out keeps the saved choice, which starts as every
built-in tool. Terminal tools (group terminal) follow --terminal-access.
--sandbox runs the agent's commands in its CLI's own sandbox and
--command-internet lets those commands reach the internet. --add-folder and
--remove-folder change the folders, besides the agent's own, that its files
and commands may use. --tool-off and --tool-on turn one tool of a selected
server off or on, as SERVER_ID:TOOL with the tool names in each server's
tools list. Leaving any of these out keeps the saved choice.
Saving requires the complete selection and a stable operation ID. Retry with
the same operation ID and identical flags after a lost reply. Applied status
requires runtime evidence; a saved choice may remain pending.

```text
catalex agents tools [flags]
```

Examples:

```sh
  catalex agents tools --agent ID
  catalex agents tools --agent ID --discover
  catalex agents tools --agent ID --operation-id CHANGE_ID --revision 0 --inventory-revision INVENTORY_ID --mcp-server SERVER_ID --terminal-access off --approval-mode inherit
  catalex agents tools --agent ID --operation-id CHANGE_ID --revision 0 --inventory-revision INVENTORY_ID --mcp-server '' --terminal-access off --approval-mode inherit --apply
  catalex agents tools --agent ID --operation-id CHANGE_ID --revision 1 --inventory-revision INVENTORY_ID --mcp-server SERVER_ID --builtin-tool READ_ID,EDIT_ID --terminal-access on --approval-mode inherit
  catalex agents tools --agent ID --operation-id CHANGE_ID --revision 2 --inventory-revision INVENTORY_ID --mcp-server SERVER_ID --terminal-access off --approval-mode inherit --sandbox on --command-internet off --add-folder /Users/me/shared --tool-off SERVER_ID:delete_file
```

Flags:

```text
      --add-folder strings          Absolute path of an existing folder, besides the agent's own, its files and commands may use; repeated or comma-separated
      --agent string                Saved agent ID
      --apply                       Apply or replay the complete saved operation with the same stable operation ID
      --approval-mode string        inherit, manual, automatic, none or deny (none never asks: the agent runs in its CLI's full-access mode and can do anything this computer account can; deny never asks anyone: tools you allowed run, anything else is refused); unsupported native mappings are refused
      --builtin-tool strings        Built-in tool IDs to keep, repeated or comma-separated; empty keeps none; omit to keep the saved choice
      --command-internet string     on or off: let sandboxed commands reach the internet; omit to keep the saved choice
      --discover                    Refresh discovery; may start the agent briefly, without a prompt, to list every tool source; never signs in or grants trust
      --inventory-revision string   Exact discovery revision reviewed for this change
      --mcp-server strings          Optional discovered server IDs, repeated or comma-separated; empty disables optional servers; Required communication is retained
      --operation-id string         Stable ID for this owner change; reuse only for an identical retry
      --remove-folder strings       Path of a folder to stop offering, as listed in extra_folders; repeated or comma-separated
      --revision int                Expected saved policy revision; required for a change
      --sandbox string              on or off: run the agent's commands in its CLI's own sandbox; omit to keep the saved choice
      --terminal-access string      inherit, off or on; existing native guards always remain binding
      --tool-off strings            SERVER_ID:TOOL to turn off, repeated or comma-separated
      --tool-on strings             SERVER_ID:TOOL to turn back on, repeated or comma-separated
```

## catalex analytics

Show every conversation and its distribution.

Show every conversation of every source (native chats, Slack, WhatsApp) and their
distribution, read from this computer's deployments or, with --hosted,
from its connected messaging service.

```text
catalex analytics [flags]
```

Examples:

```sh
  catalex analytics
  catalex analytics --hosted --json
```

Flags:

```text
      --hosted   Read from the connected messaging service instead of this computer
```

## catalex analytics summary

Show message activity and cost: totals, each day, and who and where.

Show the activity the Analytics page shows for one range: messages, conversations,
people, tokens, cost and reply times, a total per local day, the split by platform,
agent and person, the cost by model, chat, platform, agent, token kind and computer, and message
lengths. Filters narrow every number (the cost by computer is left out when one is set). --cost-by prints the cost total and one
cost breakdown as a table instead; --json always prints everything. Turns stored
before CatalEx recorded costs have none.

```text
catalex analytics summary [flags]
```

Examples:

```sh
  catalex analytics summary
  catalex analytics summary --range 7d --platform slack --json
  catalex analytics summary --cost-by model
```

Flags:

```text
      --agent string      Only this agent's conversations (a key from the summary's options)
      --cost-by string    Print the cost total and its breakdown by model, chat, platform, agent, token-kind or computer as a table
      --person string     Only this person's conversation (a key from the summary's options)
      --platform string   Only one platform: native_chat, slack, whatsapp, googlechat or messaging
      --range string      Days to cover: 7d, 30d, 90d or all (default "30d")
```

## catalex app

Act on the CatalEx app on this computer.

```text
catalex app
```

Examples:

```sh
  catalex app open
  catalex app status
  catalex app quit
```

## catalex app login

Turn opening the CatalEx app at login on or off.

```text
catalex app login
```

Examples:

```sh
  catalex app login on
  catalex app login off
```

## catalex app login off

Stop opening the CatalEx app at login.

Stop opening the CatalEx app at login.
The running app registers itself with the operating system; open it first
with catalex app open. When macOS needs your approval, the change waits for
it and the command exits 6; approve CatalEx in System Settings > General >
Login Items, then check with catalex app status.

```text
catalex app login off
```

Examples:

```sh
  catalex app login off
  catalex app login off --json
```

## catalex app login on

Open the CatalEx app when you log in to this computer.

Open the CatalEx app when you log in to this computer.
The running app registers itself with the operating system; open it first
with catalex app open. When macOS needs your approval, the change waits for
it and the command exits 6; approve CatalEx in System Settings > General >
Login Items, then check with catalex app status.

```text
catalex app login on
```

Examples:

```sh
  catalex app login on
  catalex app login on --json
```

## catalex app open

Launch or focus the CatalEx app.

```text
catalex app open [flags]
```

Examples:

```sh
  catalex app open
  catalex app open --section agents
  catalex app open --conversation REF
```

Flags:

```text
      --app-path string       Absolute installed CatalEx.app path; never falls back to another app
      --conversation string   Open the conversation with this reference
      --print-link            With --conversation, print the app link instead of launching the app
      --section string        View to show: agents, settings, settings/providers, settings/channels
```

## catalex app quit

Quit the CatalEx app; agents and chats keep running.

Quit the CatalEx app on this computer and wait until its process has
exited. Agents and chats keep running, and a server the
app did not start keeps running too. Stop them with catalex stop.

```text
catalex app quit
```

Examples:

```sh
  catalex app quit
  catalex app quit --json
```

## catalex app status

Show whether the CatalEx app runs, its version and login registration.

Show whether the CatalEx app is running on this computer for this CatalEx home,
its version and whether it opens at login, as the operating system reports it.
Read-only: it never launches the app.

```text
catalex app status
```

Examples:

```sh
  catalex app status
  catalex app status --json
```

## catalex channel-settings

Show or change who may act and what an account's conversations post.

Read and change the settings the messaging service keeps for an account's
app or number: who may answer, approve and cancel in Slack or Google Chat threads,
and which routine output the agent posts. Before the account uses an
installation, set saves an unusable draft instead; it applies when you run
set again after the account uses one.

```text
catalex channel-settings
```

Examples:

```sh
  catalex channel-settings show ACCOUNT_ID
  catalex channel-settings set ACCOUNT_ID --approval approvers_only --approver U012AB3CD
```

## catalex channel-settings discard

Discard an account's settings draft.

```text
catalex channel-settings discard ACCOUNT_ID
```

Examples:

```sh
  catalex channel-settings discard ACCOUNT_ID
```

## catalex channel-settings set

Change an account's channel settings, or save them as a draft.

Change the settings named by flags and keep the others: the applied values
when the account uses an installation, otherwise its draft. --post is
message, or message,progress to also send progress updates. --approval and
--approver apply to Slack or Google Chat only; a mode other than anyone needs at least
one person's ID: Slack member IDs such as U012AB3CD; Google Chat user names such as users/123.
The settings revision is read first unless --revision names it.

```text
catalex channel-settings set ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex channel-settings set ACCOUNT_ID --post message
  catalex channel-settings set ACCOUNT_ID --approval approvers_only --approver U012AB3CD --approver U045EF6GH
  catalex channel-settings set ACCOUNT_ID --approval approvers_only --approver users/123
```

Flags:

```text
      --approval string    Slack or Google Chat only: anyone, anyone_answers or approvers_only
      --approver strings   Slack or Google Chat only: a person's ID allowed to act; repeat for each, replacing the list
      --post strings       Routine output: message, or message,progress
      --revision string    Settings revision from catalex channel-settings show; omitted reads it first
```

## catalex channel-settings show

Show an account's channel settings, draft and next action.

```text
catalex channel-settings show ACCOUNT_ID
```

Examples:

```sh
  catalex channel-settings show ACCOUNT_ID
```

## catalex channels

Manage agents' native chat, Slack, WhatsApp and Google Chat channels.

```text
catalex channels
```

Examples:

```sh
  catalex channels list
  catalex channels add --agent AGENT_ID --type slack --account ACCOUNT_ID
```

## catalex channels add

Add a native chat or messaging app channel to an agent.

Add a channel to an agent. A messaging app channel connects an available
agent account from catalex accounts list (--account), or with --new adds an
account of that app for this agent and starts its setup; --account of a
linked number several agents share joins the agent to it (--entries then
sets the numbers it answers); the account is
connected when its setup finishes. An account another agent uses is moved
only when confirmed: the command asks, or --move confirms. Admin accounts are never channels. These
channels need cloud hosting; without it CatalEx refuses with the reason.

```text
catalex channels add [flags]
```

Examples:

```sh
  catalex channels add --agent AGENT_ID --type native_chat --name Tests
  catalex channels add --agent AGENT_ID --type slack --account ACCOUNT_ID
  catalex channels add --agent AGENT_ID --type whatsapp --new --name "Sales line"
  catalex channels add --agent AGENT_ID --type slack --account ACCOUNT_ID --move
```

Flags:

```text
      --account string    Available agent account ID for a messaging app channel
      --agent string      Agent ID that owns the channel
      --entries strings   Numbers, prefixes such as +44* or group:<id> this agent answers on a linked number several agents share; joins the agent to it
      --move              Move the account from the agent using it, removing that agent's channel on it
      --name string       Display name of the channel; a messaging app channel defaults to its account's name, and with --new it names the new account
      --new               Add a new account of that app for this agent and start its setup
      --type string       Channel type: native_chat, slack, whatsapp, googlechat or whatsapp_personal (experimental)
```

## catalex channels behavior

Show or change a channel's saved engagement frequency.

Show saved preferences and the server's application state. Supply only the
preferences to change; omitted flags keep their saved values. The revision
is read first unless --revision names it. A save does not prove native
application. Frequency is loose send guidance; complete long replies remain
valid.
Use inherit to reset to the agent default; channels change frequency only.

```text
catalex channels behavior [flags]
```

Examples:

```sh
  catalex channels behavior --channel ID
  catalex channels behavior --channel ID --engagement-frequency low
  catalex channels behavior --channel ID --engagement-frequency inherit
```

Flags:

```text
      --channel string                Saved channel ID
      --engagement-frequency string   low, medium or high; inherit resets to the agent's default
      --revision int                  Expected behavior revision; a stale revision is refused without retrying
```

## catalex channels list

List channels with their readiness.

List channels with their readiness: those saved on this computer and, when you
are signed in, each agent's channel on a shared phone number, as the app shows
it. --json marks the shared ones "shared": true. Signed out, or without a
reachable CatalEx Cloud, only this computer's channels are listed.

```text
catalex channels list [flags]
```

Examples:

```sh
  catalex channels list
  catalex channels list --agent AGENT_ID
```

Flags:

```text
      --agent string   Only this agent's channels
```

## catalex channels remove

Remove a saved channel. Its conversations are kept, except on a bound account.

Remove a saved channel; its conversations are kept, except on a bound account
(a linked phone number), where they are removed. A Slack, WhatsApp or
Google Chat channel's account becomes available to other agents: the
command names it and asks first (default No), or --yes confirms. Without a
terminal it refuses unless --yes is given.

```text
catalex channels remove ID [flags]
```

Examples:

```sh
  catalex channels remove CHANNEL_ID
  catalex channels remove CHANNEL_ID --yes
```

Flags:

```text
      --yes   Confirm without asking; its Slack, WhatsApp and Google Chat accounts become available to other agents
```

## catalex chats

List, create and manage native chats.

```text
catalex chats
```

Examples:

```sh
  catalex chats list
  catalex chats create --channel CHANNEL_ID
```

## catalex chats activity

Read a native chat's full activity: tool calls, thoughts and results.

Read what the agent did during a native chat, oldest first, as the CatalEx
app's Full conversation view shows it: your input, thoughts, each tool call
with its input and result, the agent's text and where each turn started and
ended. Continue from the cursor a read prints with --after; --wait holds the
read until a new item arrives or the time passes. --session reads any
session by its ID instead of a chat. The activity is kept on the
computer that ran the chat, so --computer is refused.

```text
catalex chats activity [ID] [flags]
```

Examples:

```sh
  catalex chats activity CHAT_ID
  catalex chats activity --session SESSION_ID
  catalex chats activity CHAT_ID --after 12 --wait 5s --json
```

Flags:

```text
      --after int           Read the items after this cursor (default 0: from the start)
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --session string      Read this session ID instead of a chat, for example a Slack conversation
      --wait duration       Hold the read up to this long for a new item, such as 5s
```

## catalex chats answer

Answer an agent's question or AI provider form.

Answer an open question by its operation ID: catalex chats watch, and
chats send --wait, print it after "operation" on the question's event. It is
not the message ID that catalex chats history shows in brackets; a message ID
is refused with MESSAGE_ID_NOT_OPERATION. Answer with a choice, a text
answer (--text-file or standard input) or form values (--values-file, a JSON
object). An AI provider form takes --native accept with --values-file, or
--native decline or cancel. An answered, expired, closed or foreign question
is refused with QUESTION_NOT_OPEN. On a chat of another computer (--computer),
an answer another device delivered first is refused with ALREADY_DECIDED
(exit 5). A delivered answer exits 0.

```text
catalex chats answer ID [flags]
```

Examples:

```sh
  catalex chats answer CHAT_ID --operation OPERATION_ID --choice yes
  echo "Use the staging database" | catalex chats answer CHAT_ID --operation OPERATION_ID
  catalex chats answer CHAT_ID --operation OPERATION_ID --native accept --values-file form.json
```

Flags:

```text
      --account string       Answer a Slack, WhatsApp or Google Chat conversation of this messaging account (see accounts chats answer)
      --choice string        Choice ID the question offered
      --deployment string    Deployment that holds the chat: native_chat or agent (default "native_chat")
      --native string        Answer an AI provider form: accept, decline or cancel
      --operation string     Operation ID of the question, as chats watch prints it (not its message ID)
      --retry string         Resend the recorded original command with this command ID instead of a new one
      --text-file string     Read a text answer from this file instead of standard input
      --values-file string   Read form values (one JSON object) from this file
      --wait                 Wait for the answer's final receipt
```

## catalex chats approve

Grant or deny an AI provider permission request.

Decide a permission request with one of the options it offered (from
catalex chats watch), denial included. Only the original, still-valid
request of the chat's current AI session can be decided.

```text
catalex chats approve ID [flags]
```

Examples:

```sh
  catalex chats approve CHAT_ID --operation OPERATION_ID --option allow
  catalex chats approve CHAT_ID --operation OPERATION_ID --option deny
  catalex chats approve CONVERSATION --account ACCOUNT_ID --operation OPERATION_ID --option allow
```

Flags:

```text
      --account string      Decide a Slack, WhatsApp or Google Chat conversation of this messaging account (see accounts chats approve)
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --operation string    Original operation ID of the permission request
      --option string       Option ID the request offered, from catalex chats watch (for example allow or deny)
      --retry string        Resend the recorded original command with this command ID instead of a new one
      --wait                Wait for the decision's final receipt
```

## catalex chats archive

List or restore archived native chats.

```text
catalex chats archive
```

Examples:

```sh
  catalex chats archive list
  catalex chats archive restore
```

## catalex chats archive list

List archived chats with whether they are restorable.

```text
catalex chats archive list [flags]
```

Examples:

```sh
  catalex chats archive list --json
```

Flags:

```text
      --deployment string   Deployment whose archive to read: native_chat or agent (default "native_chat")
```

## catalex chats archive restore

Restore every archived chat missing on this computer.

Re-import every archived chat that is missing locally, each linked to its
earlier messages. Chats that cannot be restored are listed with a reason.

```text
catalex chats archive restore [flags]
```

Examples:

```sh
  catalex chats archive restore
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
```

## catalex chats attachments

Upload, download or revoke a native chat's files.

```text
catalex chats attachments
```

Examples:

```sh
  catalex chats attachments upload CHAT_ID report.pdf
  catalex chats attachments download CHAT_ID ARTIFACT_ID --output report.pdf
```

## catalex chats attachments download

Download a chat file's verified bytes to a file.

Download a chat file's bytes, verified against its recorded digest, to an
explicit output file. Bytes never mix with --json output.

```text
catalex chats attachments download ID ARTIFACT_ID [flags]
```

Examples:

```sh
  catalex chats attachments download CHAT_ID ARTIFACT_ID --output report.pdf
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --output string       File to create with the bytes (must not exist)
```

## catalex chats attachments revoke

Revoke a chat file so no new message can use it.

```text
catalex chats attachments revoke ID ARTIFACT_ID [flags]
```

Examples:

```sh
  catalex chats attachments revoke CHAT_ID ARTIFACT_ID
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
```

## catalex chats attachments show

Show a chat file and, for a voice message or video, its transcript.

Show a chat file's name, type and size. For audio and for video/mp4
(its audio track), CatalEx transcribes it on this computer before the
agent's turn; the transcript, its method
(local_asr) and processor, or the transcription error code, is shown here
and under data.attachment with --json. Before the message that carries the
file is sent, no transcript exists yet.

```text
catalex chats attachments show ID ARTIFACT_ID [flags]
```

Examples:

```sh
  catalex chats attachments show CHAT_ID ARTIFACT_ID
  catalex chats attachments show CHAT_ID ARTIFACT_ID --json
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
```

## catalex chats attachments upload

Upload a file to a chat for a later message.

Upload a file to the chat's attachment spool. The result names its artifact
ID; send it with catalex chats send --attach ARTIFACT_ID. CatalEx checks
the size and digest, and the contents of images, audio, documents and video.

```text
catalex chats attachments upload ID FILE [flags]
```

Examples:

```sh
  catalex chats attachments upload CHAT_ID notes.md
  catalex chats attachments upload CHAT_ID chart.png --type image/png
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
      --name string              Display name (default: the file's name)
      --type string              Media type (default: from the file extension; CatalEx picks it for audio)
```

## catalex chats cancel

Stop the chat's current turn.

Stop the native chat's running turn, identified by its current turn and
AI session. A chat with no running turn is refused.

```text
catalex chats cancel ID [flags]
```

Examples:

```sh
  catalex chats cancel CHAT_ID
  catalex chats cancel CHAT_ID --wait
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --retry string        Resend the recorded original command with this command ID instead of a new one
      --wait                Wait for the stop's final receipt
```

## catalex chats create

Create a native chat in an agent's native chat channel.

Create a native chat with its agent's folder and AI settings. Each native
chat is one person: CatalEx gives it its own person ID (contact_ref), which the
agent's session starts with. CatalEx must be running; a stopped CatalEx refuses
with RELAY_STOPPED, and a server setup, which only runs the messaging
service, with NATIVE_CHAT_NOT_SET_UP.

```text
catalex chats create [flags]
```

Examples:

```sh
  catalex chats create --channel CHANNEL_ID --name "Release notes"
```

Flags:

```text
      --channel string   Native chat channel ID
      --name string      Display name of the chat
```

## catalex chats history

Read bounded pages of a native chat's history.

Read a native chat's history, newest first, through the chat's service
link. Each page reports its availability; a partial result names the cursor
to continue from. With --computer, an offline computer's text history comes
from the account archive, read-only; the result says source account_archive.

```text
catalex chats history ID [flags]
```

Examples:

```sh
  catalex chats history CHAT_ID
  catalex chats history CHAT_ID --cursor CURSOR --pages 1 --json
```

Flags:

```text
      --cursor string       Continue from an opaque server-issued history cursor
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --limit int           Messages per page, 1–100 (default from CATALEX_CLIENT_CHAT_HISTORY_LIMIT)
      --pages int           Pages to read, 1–100 (default from CATALEX_CLIENT_CHAT_HISTORY_PAGES)
```

## catalex chats import

Import a known Codex or Claude Code session as a native chat.

Import an existing AI session (a Codex or Claude Code session ID on the
selected computer) into a folder as a native chat, keeping its
original identity.

```text
catalex chats import [flags]
```

Examples:

```sh
  catalex chats import --project PROJECT_ID --native-session SESSION_ID --title "Earlier work"
```

Flags:

```text
      --agent string             Base agent of the folder (default: the deployment's harness)
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --effort string            Reasoning effort; empty inherits the AI provider's one
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
      --model string             Verified model ID; empty inherits the AI provider's one
      --native-session string    Codex or Claude Code session ID to import
      --project string           Folder (project) ID from catalex projects list
      --title string             Title of the imported chat
```

## catalex chats list

List native chats with their live activity.

List native chats with their live activity. With --computer, an offline
computer's chats come from the account archive, read-only, each with the
activity offline; the result says source account_archive.

```text
catalex chats list [flags]
```

Examples:

```sh
  catalex chats list
  catalex chats list --channel CHANNEL_ID --json
```

Flags:

```text
      --channel string   Only this native chat channel's chats
```

## catalex chats react

Add, replace or remove your reaction to a message.

Set your reaction to one message of the chat (a message ID from catalex
chats history). A reaction reaches the agent as input.

```text
catalex chats react ID [flags]
```

Examples:

```sh
  catalex chats react CHAT_ID --message MESSAGE_ID --emoji 👍
  catalex chats react CHAT_ID --message MESSAGE_ID --remove
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --emoji string        Emoji to set as your reaction
      --message string      Message ID to react to
      --remove              Remove your reaction instead
      --retry string        Resend the recorded original command with this command ID instead of a new one
      --wait                Wait for the reaction's final receipt
```

## catalex chats remove

Remove a saved chat. Its saved history is kept.

```text
catalex chats remove ID
```

Examples:

```sh
  catalex chats remove CHAT_ID
```

## catalex chats replace

Start a new AI session for a chat whose session failed.

Start a new AI session for a native chat whose AI session failed. The chat keeps its history;
the next message runs in the new session. A chat whose session is healthy is refused.

```text
catalex chats replace ID [flags]
```

Examples:

```sh
  catalex chats replace CHAT_ID
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
```

## catalex chats resume

Resume a chat's original AI session.

Resume the native chat's original AI session after it stopped or
failed. The original identity is kept; nothing new is created.

```text
catalex chats resume ID [flags]
```

Examples:

```sh
  catalex chats resume CHAT_ID
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
```

## catalex chats retry

Retry creating a chat that failed to start.

```text
catalex chats retry ID
```

Examples:

```sh
  catalex chats retry CHAT_ID
```

## catalex chats send

Send a message to a native chat.

Send a message to a native chat through its service link. The message is
read from --file or piped standard input. Without --wait the result is the
command's admission; with --wait it is the turn's outcome and the events it
committed, including any question or permission the agent then asks.
Until a receipt arrives the command is sent again each second, unchanged,
as the app does, so a new chat that is still starting admits it. The
command ID is printed: after a lost receipt, resend that same command
with --retry ID rather than sending a new one. If the AI refuses the turn, the command fails with the code AGENT_TURN_REFUSED,
the AI's own text, what CatalEx sent (sent with --json: model and effort, each
with where it came from) and the command that chooses other settings for the
agent. Nothing is retried and the saved settings stay. Slack and WhatsApp
conversations are read-only here.

```text
catalex chats send ID [flags]
```

Examples:

```sh
  echo "Summarize the README" | catalex chats send CHAT_ID --wait
  catalex chats send CHAT_ID --file message.txt --reply-to MESSAGE_ID
  catalex chats send CHAT_ID --retry COMMAND_ID --wait
```

Flags:

```text
      --attach stringArray   Attach an uploaded file by its artifact ID (repeatable)
      --deployment string    Deployment that holds the chat: native_chat or agent (default "native_chat")
      --file string          Read the message from this file instead of standard input
      --reply-to string      Quote this message ID from catalex chats history
      --retry string         Resend the recorded original command with this command ID instead of a new one
      --wait                 Wait for the turn's outcome instead of the command's admission
```

## catalex chats settings

Show a native chat's model settings.

```text
catalex chats settings
```

Examples:

```sh
  catalex chats settings show CHAT_ID
```

## catalex chats settings show

Show the model settings a chat started with.

```text
catalex chats settings show ID [flags]
```

Examples:

```sh
  catalex chats settings show CHAT_ID --json
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
```

## catalex chats show

Show a native chat's state, settings and session.

Show a native chat's state, settings and session. When its failed session has
no automatic recovery attempt left, the line says so and --json carries
recovery_exhausted: true.

```text
catalex chats show ID [flags]
```

Examples:

```sh
  catalex chats show CHAT_ID
  catalex chats show CHAT_ID --json
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
```

## catalex chats usage

Show a native chat's turns, tokens, cache use and cost.

Show what a native chat used, as the CatalEx app's chat information shows it:
turns, input, cached and cache-written input and output tokens, the cost of the
turns that report one, and each model's share. Turns stored before CatalEx
recorded costs, and turns whose model has no known price, have no cost. The
usage is kept on the computer that ran the chat, so --computer is refused.

```text
catalex chats usage ID [flags]
```

Examples:

```sh
  catalex chats usage CHAT_ID
  catalex chats usage CHAT_ID --json
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
```

## catalex chats watch

Stream a native chat's events for a bounded time.

Stream a native chat's events as they are committed, for a bounded number
of events or time. With --json each event is one catalex.event.v1 line,
followed by one result. Watching takes no custody of the events.

```text
catalex chats watch ID [flags]
```

Examples:

```sh
  catalex chats watch CHAT_ID --events 10
  catalex chats watch CHAT_ID --duration-ms 60000 --json
```

Flags:

```text
      --deployment string   Deployment that holds the chat: native_chat or agent (default "native_chat")
      --duration-ms int     Stop after this many milliseconds, 1–600000 (default from CATALEX_CLIENT_CHAT_WATCH_MS)
      --events int          Stop after this many events (default: the configured frame budget)
```

## catalex computers

List, add and manage the computers of this CatalEx account.

```text
catalex computers
```

Examples:

```sh
  catalex computers list
  catalex computers add
  catalex computers rename COMPUTER_ID NAME
  catalex computers disconnect COMPUTER_ID
  catalex computers delete COMPUTER_ID
```

## catalex computers add

Create a one-time code that joins another computer to the account.

Create a one-time join code for a new computer (F1): it joins one computer,
once, and expires (by default after the service's configured lifetime).
Run the printed command on the new computer and paste the code there; the
command pins this device's key fingerprint with --trust, so the computer
accepts only this account's sign-in. The code is shown once and never put
in a URL. Where catalex is already installed there, catalex join does the same
without the installer. The new computer joins as a computer only; to use
catalex there as yourself too, create a sign-in code with catalex login-codes
create and run the command it prints there. Needs a CatalEx account signed in
on this device.

```text
catalex computers add [flags]
```

Examples:

```sh
  catalex computers add
  catalex computers add --lifetime 10m
  catalex computers add --json
```

Flags:

```text
      --lifetime duration   How long the code stays valid, such as 5m (default: the service's join code lifetime)
```

## catalex computers delete

Delete a disconnected computer and erase its agents and data.

Delete a computer that is already disconnected, after confirmation (default
No): it erases the computer's agents and their chats and data from CatalEx,
on CatalEx Cloud and on that computer. This cannot be undone. A connected
computer is refused: disconnect it first with catalex computers disconnect.
The computer you are on cannot be deleted. Without a terminal, use --yes to
confirm. Needs a CatalEx sign-in on this device and a CatalEx Cloud that
supports deleting computers.

```text
catalex computers delete ID [flags]
```

Examples:

```sh
  catalex computers delete COMPUTER_ID
  catalex computers delete COMPUTER_ID --yes
```

Flags:

```text
      --yes   Confirm deleting the computer without asking
```

## catalex computers disconnect

Disconnect a computer from the account; it stops its agents at once.

Disconnect a computer from this CatalEx account after confirmation (default
No). This will remove this computer and disconnect all its associated agents
from CatalEx. It stops its agents at once and can no longer connect; the
channels of its agents stay bound and connecting it again with a new code
restores them. An offline computer can be disconnected. The computer you are
on cannot be disconnected; make it leave with catalex computers leave. Without
a terminal, use --yes to confirm. Delete a disconnected computer with catalex
computers delete. Needs a CatalEx sign-in on this device.

```text
catalex computers disconnect ID [flags]
```

Examples:

```sh
  catalex computers disconnect COMPUTER_ID
  catalex computers disconnect COMPUTER_ID --yes
```

Flags:

```text
      --yes   Confirm disconnecting the computer without asking
```

## catalex computers keep

Keep a stale computer so it can connect again.

Keep a computer that was offline so long it became Stale: it may connect
again and serve its agents (F8). Remove it instead if it is gone. Needs a
CatalEx sign-in on this device.

```text
catalex computers keep ID
```

Examples:

```sh
  catalex computers keep COMPUTER_ID
```

## catalex computers leave

Stop serving agents from this computer; your sign-in stays.

Make the selected computer leave your CatalEx account after confirmation
(default No): it leaves on the messaging service with its own credential,
then forgets its membership and disconnects (F27). Its agents, settings and chats stay, your
sign-in stays, and it can join again with a new code. Signing out instead
keeps a joined computer serving. Without a terminal, use --yes.

```text
catalex computers leave [flags]
```

Examples:

```sh
  catalex computers leave
  catalex computers leave --yes
```

Flags:

```text
      --no-wait   Report the accepted leave without waiting for this computer to disconnect
      --yes       Confirm leaving the account without asking
```

## catalex computers list

List the account's computers with their activity and last connection.

List every computer of this CatalEx account: its ID, name, operating
system, whether it is connected, idle, offline, stale or disconnected, when it
last connected, when an agent last ran on it and how many agents it serves.
A computer offline too long is Stale: keep it or disconnect it. While this computer is connecting or offline, its row says
so instead of the service's state, and --json adds this_computer (computer_id,
connection, connection_problem). Needs a CatalEx sign-in on this device and computers on its
messaging service. Read-only.

```text
catalex computers list
```

Examples:

```sh
  catalex computers list
  catalex computers list --json
```

## catalex computers rename

Rename a computer of the account.

Give a computer of this CatalEx account a new name, the one every device
shows. Needs a CatalEx sign-in on this device.

```text
catalex computers rename ID NAME
```

Examples:

```sh
  catalex computers rename COMPUTER_ID 'Office VM'
```

## catalex computers settings

Show or change this computer's own settings.

Show this computer's settings, or change one. remote-chat-links decides
whether other devices of your account can open this computer's native chats
and create chats on it; off refuses them with REMOTE_LINKS_OFF. It changes
only on the computer itself, so it works on the selected computer and
never with --computer.

```text
catalex computers settings [remote-chat-links on|off]
```

Examples:

```sh
  catalex computers settings
  catalex computers settings remote-chat-links off
```

## catalex computers this

Show this computer's key and the device keys it trusts.

Show the selected computer's state (F20): its computer key's
fingerprint, the account it joined and the device keys it trusts for
sensitive changes, with why each is trusted. --trust-this-device makes a
computer that trusts no device key yet (one from before joining existed)
trust this device's key first; later keys arrive only as signed records.

```text
catalex computers this [flags]
```

Examples:

```sh
  catalex computers this
  catalex computers this --trust-this-device
```

Flags:

```text
      --trust-this-device   Make a computer that trusts no device key yet trust this device's key
```

## catalex connections

Manage saved connections to computers and messaging services.

```text
catalex connections
```

Examples:

```sh
  catalex connections list
  catalex connections rescan
```

## catalex connections add

Save an authenticated connection reference.

```text
catalex connections add NAME [flags]
```

Examples:

```sh
  catalex connections add office --url https://catalex.example --token-file /private/control.token
```

Flags:

```text
      --dashboard           Add it to the CatalEx app's list on this computer instead of this client's
      --token-file string   Read authorization from an owned private file; never pass a token as an argument
      --token-stdin         Read a bounded token from a pipe or redirected standard input; never echo it
      --url string          Use this HTTPS service origin or literal loopback HTTP origin
```

## catalex connections edit

Update a reference while preserving its bound server identity.

```text
catalex connections edit NAME [flags]
```

Examples:

```sh
  catalex connections edit office --name work
  catalex connections edit office --token-file /private/control.token
```

Flags:

```text
      --dashboard           Edit the CatalEx app's entry on this computer instead of this client's
      --name string         Set a bounded display name without changing client identity
      --token-file string   Replace authorization from an owned private file
      --token-stdin         Replace authorization from noninteractive standard input
      --url string          Set a verified origin for the same server identity
```

## catalex connections hosting

Show or change the selected computer's cloud hosting.

Show or change which messaging service the selected computer
connects to. This changes that computer's configuration, unlike the
other connections commands, which change only this client's references.

```text
catalex connections hosting
```

Examples:

```sh
  catalex connections hosting show
  catalex connections hosting set --url https://catalex.example.com --token-file /private/service.token
  catalex connections hosting off
  catalex connections hosting on
```

## catalex connections hosting off

Disconnect the selected computer from its messaging service.

Disconnect the selected computer from its messaging service without stopping
the service. The agent deployment finishes its work for the messaging service and
stops; if that work cannot finish, nothing changes. Native chats keep
running, and the agent's identity, credential and conversations are kept,
so connections hosting on resumes them. A computer that
runs the complete setup here turns it off with catalex local-setup off.

```text
catalex connections hosting off
```

Examples:

```sh
  catalex connections hosting off
```

## catalex connections hosting on

Reconnect the selected computer to the cloud hosting it last used.

Connect the selected computer again to the messaging service it was last
disconnected from, with the address and credential it kept: no URL or token
is needed. CatalEx restarts to reconnect, so native chats pause briefly;
Slack and WhatsApp conversations continue. To connect to another service,
use connections hosting set.

```text
catalex connections hosting on
```

Examples:

```sh
  catalex connections hosting on
```

## catalex connections hosting set

Connect the selected computer to a messaging service.

Connect the selected computer to a messaging service with a service
credential, verified against the service's assigned identity.
Give the service with --url and a private --token-file or --token-stdin. A running CatalEx
restarts to reconnect, so native chats pause briefly; a computer that runs its own messaging service changes with catalex local-setup.

```text
catalex connections hosting set [flags]
```

Examples:

```sh
  catalex connections hosting set --url https://catalex.example.com --token-file /private/service.token
```

Flags:

```text
      --token-file string   Read the service credential from an owned private file
      --token-stdin         Read the service credential from piped standard input
      --url string          Messaging service origin (HTTPS, or HTTP on literal loopback)
```

## catalex connections hosting show

Show and verify the cloud hosting connection.

```text
catalex connections hosting show
```

Examples:

```sh
  catalex connections hosting show --json
```

## catalex connections list

List saved references without credentials.

```text
catalex connections list [flags]
```

Examples:

```sh
  catalex connections list
  catalex connections list --dashboard --json
```

Flags:

```text
      --dashboard   List the CatalEx app's list on this computer instead of this client's
```

## catalex connections remove

Remove a client reference while keeping server data.

```text
catalex connections remove NAME [flags]
```

Examples:

```sh
  catalex connections remove office
  catalex connections remove CONNECTION_ID --dashboard
```

Flags:

```text
      --dashboard   Act on the CatalEx app's list on this computer instead of this client's; never stops a server
```

## catalex connections rescan

Refresh the CatalEx installations found on this computer.

```text
catalex connections rescan [flags]
```

Examples:

```sh
  catalex connections rescan --json
  catalex connections rescan --dashboard
```

Flags:

```text
      --dashboard   Make the CatalEx app on this computer rescan its list instead of this client
```

## catalex connections use

Select a saved connection without changing its server.

```text
catalex connections use NAME [flags]
```

Examples:

```sh
  catalex connections use office
  catalex connections use CONNECTION_ID --dashboard
```

Flags:

```text
      --dashboard   Act on the CatalEx app's list on this computer instead of this client's; never stops a server
```

## catalex credentials

Enter, replace, check or remove a messaging account's credentials.

Manage the credentials of a named messaging account on
the messaging service this computer runs. An account first uses one of the
service's provider installations (bind); set then replaces that
installation's token or Google Chat key after checking it with the provider,
keeping its identity and routing. The saved secret is never shown. A computer connected to another team's service
reports the administrator's next action instead.

```text
catalex credentials
```

Examples:

```sh
  catalex credentials status ACCOUNT_ID
  catalex credentials set ACCOUNT_ID --token-file /private/slack.token
  catalex credentials set ACCOUNT_ID --key-file /private/chat-key.json
```

## catalex credentials bind

Use a provider installation for an account.

Use one of the messaging service's provider installations, listed by
catalex credentials installations, for a named account. An installation
serves one account; nothing is sent to the provider.

```text
catalex credentials bind ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex credentials bind ACCOUNT_ID --installation-id INSTALLATION_ID
```

Flags:

```text
      --installation-id string   Installation from catalex credentials installations
      --service-id string        Service identity from catalex credentials installations; omitted uses the one discovered
```

## catalex credentials check

Check an account's saved token with the provider without replacing it.

```text
catalex credentials check ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex credentials check ACCOUNT_ID
```

Flags:

```text
      --operation-id string   Operation ID to use; omitted creates one
      --revision int          Expected credential revision; omitted reads it first
```

## catalex credentials installations

List the provider installations an account can use.

```text
catalex credentials installations ACCOUNT_ID
```

Examples:

```sh
  catalex credentials installations ACCOUNT_ID
```

## catalex credentials operation

Show the outcome of an earlier set or check without sending it again.

```text
catalex credentials operation ACCOUNT_ID OPERATION_ID
```

Examples:

```sh
  catalex credentials operation ACCOUNT_ID OPERATION_ID
```

## catalex credentials set

Replace an account's token, key or OAuth client after checking it with the provider.

Check a new Slack bot token, WhatsApp access token or Google Chat
service-account key or OAuth client with the provider and replace the bound installation's
secret, keeping its identity and routing. Read a token from an owned private
--token-file or piped --token-stdin, and a Google Chat service-account key or OAuth client (the
downloaded JSON file) from --key-file or --key-stdin; never pass either as an argument.
A rejected token or key leaves the saved one in place. The operation ID is printed first; after an interrupted reply,
inspect it with catalex credentials operation instead of sending again.

```text
catalex credentials set ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex credentials set ACCOUNT_ID --token-file /private/slack.token
  catalex credentials set ACCOUNT_ID --token-stdin < /private/whatsapp.token
  catalex credentials set ACCOUNT_ID --key-file /private/chat-key.json
  catalex credentials set ACCOUNT_ID --key-file /private/chat-client.json
```

Flags:

```text
      --key-file string       Read a Google Chat service-account key or OAuth client from an owned private file
      --key-stdin             Read a Google Chat service-account key or OAuth client from piped standard input
      --operation-id string   Operation ID to use; omitted creates one
      --revision int          Expected credential revision from catalex credentials status; omitted reads it first
      --token-file string     Read the token from an owned private file
      --token-stdin           Read the token from piped standard input
```

## catalex credentials status

Show an account's credential state and next action.

```text
catalex credentials status ACCOUNT_ID
```

Examples:

```sh
  catalex credentials status ACCOUNT_ID
```

## catalex credentials unbind

Stop an account using its installation; provider credentials are kept.

```text
catalex credentials unbind ACCOUNT_ID
```

Examples:

```sh
  catalex credentials unbind ACCOUNT_ID
```

## catalex debug

Read what CatalEx holds, to troubleshoot it.

```text
catalex debug
```

Examples:

```sh
  catalex debug sessions
  catalex debug sessions inspect SESSION_ID
  catalex debug agents --json
```

## catalex debug agents

Print one page of CatalEx's agents.

```text
catalex debug agents [flags]
```

Examples:

```sh
  catalex debug agents
  catalex debug agents --cursor NEXT_CURSOR
```

Flags:

```text
      --cursor string       Read one page after this opaque cursor
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug operations

Read operations.

```text
catalex debug operations
```

Examples:

```sh
  catalex debug operations inspect OPERATION_ID
```

## catalex debug operations inspect

Print one operation.

```text
catalex debug operations inspect ID [flags]
```

Examples:

```sh
  catalex debug operations inspect OPERATION_ID
```

Flags:

```text
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug projects

Print one page of CatalEx's projects.

```text
catalex debug projects [flags]
```

Examples:

```sh
  catalex debug projects
  catalex debug projects --cursor NEXT_CURSOR
```

Flags:

```text
      --cursor string       Read one page after this opaque cursor
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug sessions

Print one page of sessions; inspect one or read its events.

```text
catalex debug sessions [flags]
```

Examples:

```sh
  catalex debug sessions
  catalex debug sessions --cursor NEXT_CURSOR
  catalex debug sessions inspect SESSION_ID
  catalex debug sessions events SESSION_ID
```

Flags:

```text
      --cursor string       Read one page after this opaque cursor
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug sessions events

Print one page of a session's retained events.

```text
catalex debug sessions events ID [flags]
```

Examples:

```sh
  catalex debug sessions events SESSION_ID
  catalex debug sessions events SESSION_ID --cursor NEXT_CURSOR
```

Flags:

```text
      --cursor string       Read one page after this opaque cursor
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug sessions inspect

Print one session.

```text
catalex debug sessions inspect ID [flags]
```

Examples:

```sh
  catalex debug sessions inspect SESSION_ID
```

Flags:

```text
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex debug sessions list

Print one page of sessions.

```text
catalex debug sessions list [flags]
```

Examples:

```sh
  catalex debug sessions list
  catalex debug sessions list --cursor NEXT_CURSOR
```

Flags:

```text
      --cursor string       Read one page after this opaque cursor
      --deployment string   Deployment to read: native_chat or agent (default "native_chat")
```

## catalex defaults

Show or set the AI settings for new agents.

```text
catalex defaults
```

Examples:

```sh
  catalex defaults show
  catalex defaults set --agent claude --model haiku
```

## catalex defaults set

Set the defaults for new agents (and agents with nothing saved).

Set the AI, model and effort new agents use. Existing agents and chats keep
their settings, except an agent with nothing saved, which follows the new
default from its next launch.

```text
catalex defaults set [flags]
```

Examples:

```sh
  catalex defaults set --agent codex --model gpt-5 --effort medium
```

Flags:

```text
      --agent string    AI provider for new agents: codex or claude
      --effort string   Reasoning effort the model supports
      --model string    Verified model ID; empty uses the provider's own default
```

## catalex defaults show

Show the defaults and every verified model and effort.

Show the defaults for new agents and every verified model and effort. For each
AI it also shows the model an agent with nothing saved gets and where that
value comes from, then the values skipped on the way and why. The order is
the agent's saved value, CatalEx's defaults, the agent folder's own AI
configuration, your AI configuration, the AI's default and the first value
it offers.

```text
catalex defaults show
```

Examples:

```sh
  catalex defaults show
  catalex defaults show --json
```

## catalex delegations

Send a message to another agent on an agent's behalf; read what it sent.

Send a message to another agent on behalf of a sending agent, as the agent
itself can, for example from a background job; the receiving
agent may run on another computer of the account. The sending agent must
list the receiver among the agents it sends to, and the selected computer
must run. A refusal keeps its code (DELEGATE_NOT_ALLOWED,
DELEGATE_TARGET_UNKNOWN, DELEGATE_ROUTE_UNAVAILABLE, ...).

```text
catalex delegations
```

Examples:

```sh
  catalex delegations send AGENT_ID --to CONTACT_REF --text TEXT --idempotency-key KEY
  catalex delegations list AGENT_ID
```

## catalex delegations list

List one page of the messages the agent sent to other agents, newest first.

```text
catalex delegations list AGENT_ID [flags]
```

Examples:

```sh
  catalex delegations list AGENT_ID
  catalex delegations list AGENT_ID --status turn_done --since 2026-10-17T00:00:00Z
  catalex delegations list AGENT_ID --cursor NEXT_CURSOR --json
```

Flags:

```text
      --cursor string   Read the page after this next_cursor, with the same filters
      --since string    Only messages sent at or after this RFC 3339 time
      --status string   Only messages in this state: queued, delivered_to_agent, turn_done, held or failed
```

## catalex delegations send

Send a message to the agent a person's ID belongs to.

Send a message to the agent whose person ID --to names, on behalf of
AGENT_ID. --to-chat names the person by the receiving agent's native chat
instead: each native chat is one person, and its ID is read from the chat.
Reuse --idempotency-key for every retry of the same message: a retry returns
the original message and sends nothing twice, including after DELEGATE_ROUTE_UNAVAILABLE or a lost answer (exit 6).

```text
catalex delegations send AGENT_ID [flags]
```

Examples:

```sh
  catalex delegations send AGENT_ID --to CONTACT_REF --text "The appointment moved to 3 pm." --idempotency-key appointment-42-moved
  catalex delegations send AGENT_ID --to-chat CHAT_ID --text "The appointment moved to 3 pm." --idempotency-key appointment-42-moved
```

Flags:

```text
      --idempotency-key string   A key for this message; reuse it for every retry so nothing is sent twice
      --text string              The message for the receiving agent
      --to string                The receiving agent's ID for the person (ct_...), from that agent's chat
      --to-chat string           The receiving agent's native chat whose person to message, instead of --to
```

## catalex delegations status

Show one message the agent sent to another agent, with its counts.

```text
catalex delegations status AGENT_ID MESSAGE_ID
```

Examples:

```sh
  catalex delegations status AGENT_ID MESSAGE_ID
  catalex delegations status AGENT_ID MESSAGE_ID --json
```

## catalex destinations

Set up a messaging app's first installation for an account.

```text
catalex destinations
```

Examples:

```sh
  catalex destinations setup ACCOUNT_ID
  catalex destinations setup ACCOUNT_ID --action prepare --value project_id=PROJECT --value agent_id=AGENT
```

## catalex destinations setup

Inspect or resume the account's provider setup checkpoints.

Use the selected computer's typed destination setup workflow. With no
action, show the current requirements. Choose only a published --action;
inputs come from private --input-file NAME=FILE or piped --input-stdin NAME;
on a terminal, a secret not supplied is asked for in a hidden prompt.
Nonsecret fields use --value NAME=VALUE. An existing attempt is inspected
before mutation; unavailable or uncertain evidence never creates a new app.

```text
catalex destinations setup ACCOUNT_ID [flags]
```

Examples:

```sh
  catalex destinations setup ACCOUNT_ID
  catalex destinations setup ACCOUNT_ID --whatsapp
  catalex destinations setup ACCOUNT_ID --slack --action connect
  catalex destinations setup ACCOUNT_ID --slack --action save_credentials --value app_id=APP_ID --value client_id=CLIENT_ID --input-file client_secret=/private/slack.client --input-file signing_secret=/private/slack.signing
  catalex destinations setup ACCOUNT_ID --action authorize --input-stdin bot_token < /private/slack.token
  catalex destinations setup ACCOUNT_ID --googlechat --action authorize --value project_number=PROJECT_NUMBER --input-file service_account_key=/private/chat-key.json --input-file oauth_client=/private/chat-client.json
```

Flags:

```text
      --action string            Published setup action; omitted inspects the current checkpoint
      --googlechat               Connect the account's Google Chat app on the selected server
      --input-file stringArray   Requested field NAME=owned-private-file; never a secret value
      --input-stdin string       Requested field name to read from piped standard input
      --operation-id string      Original setup operation to inspect or resume; omitted uses the service's active attempt
      --slack                    Create and connect the account's Slack app with one approval on the selected server
      --value stringArray        Nonsecret requested field NAME=VALUE
      --whatsapp                 Use WhatsApp discovery, Meta sign-in and phone setup on the selected server
      --whatsapp_personal        Link your own WhatsApp number on the selected server (experimental)
```

## catalex devices

List the devices signed in to your CatalEx account, sign one out or trust it.

```text
catalex devices
```

Examples:

```sh
  catalex devices list
  catalex devices trust CLIENT_ID
  catalex devices remove CLIENT_ID
```

## catalex devices list

List the devices signed in to the account.

List every device signed in to your CatalEx account: its ID, name, the
program it signed in from (App for the CatalEx app, Terminal for the catalex
command), whether it is trusted for changes on your computers, how it signed
in and its key fingerprint. A device signed in with a password or Google is not trusted
for changes until a trusted device trusts it. Read-only.

```text
catalex devices list
```

Examples:

```sh
  catalex devices list
  catalex devices list --json
```

## catalex devices remove

Sign another device out of the account.

Sign another device out of your CatalEx account after confirmation
(default No): it can no longer reach the account, and its key leaves every
computer's trust list (F27). Use it for a lost device or a sign-in you do
not recognize. Without a terminal, use --yes to confirm.

```text
catalex devices remove ID [flags]
```

Examples:

```sh
  catalex devices remove CLIENT_ID
  catalex devices remove CLIENT_ID --yes
```

Flags:

```text
      --yes   Confirm signing the device out without asking
```

## catalex devices trust

Trust another device for changes on your computers.

Trust another signed-in device for changes on your computers (F25): this
device signs a trust record adding that device's key to every computer's
trust list. Only a device trusted for changes can trust another. Signing
asks for confirmation on the terminal (default No); --yes confirms it.
Trust only a sign-in you recognize; sign out one you do not.

```text
catalex devices trust ID [flags]
```

Examples:

```sh
  catalex devices trust CLIENT_ID
  catalex devices trust CLIENT_ID --yes
```

Flags:

```text
      --yes   Confirm signing the trust record without asking
```

## catalex devices trust-new

Add devices signed in with your sign-in codes to your computers' trust lists.

Sign the trust records that put every device signed in with one of this
device's sign-in codes on your computers' trust lists (F6), so it can make
sensitive changes on them. catalex login-codes create does this on its own
while it waits for the other device; run this after it stopped waiting or
when the code was created from the app. Nothing changes when there is no such
device.

```text
catalex devices trust-new
```

Examples:

```sh
  catalex devices trust-new
```

## catalex devices trust-this

Trust this device for changes through CatalEx on this computer.

Trust this device for changes on your computers by proving that it runs on a
computer that joined your account (F20, F25): CatalEx here signs a
short-lived attestation of this device's key, the CatalEx service checks it
and trusts exactly this device, and CatalEx trusts the key too.
catalex login does this on its own on such a machine, and first joins CatalEx
here to your account when it has joined nothing, and connects it again when it
joined this account but reads offline. It waits up to
CATALEX_CLIENT_CONNECT_TIMEOUT_MS for a connection that is coming up, and
fails with THIS_COMPUTER_OFFLINE, naming the reason CatalEx reports, when the
computer still does not connect;
a computer left joined to another account or service by an earlier sign-in is
reset silently first and joins this account. Use this command after signing in
elsewhere first, or to try again. Once the computer is connected it also starts the agents on it that are off
(a stopped deployment, for example) and leaves running agents untouched; a
failure there is a warning and never fails the command. Nothing changes on a
device that is trusted already and a computer that is online. The result says joined_this_computer
when it joined this computer just now. With --no-wait it only joins: it
returns as soon as CatalEx here accepted the join, while the computer
connects in the background, and trusts nothing; run the command again
without the flag to wait for the connection and trust this device.

```text
catalex devices trust-this [flags]
```

Examples:

```sh
  catalex devices trust-this
  catalex devices trust-this --no-wait
```

Flags:

```text
      --no-wait   Join this computer and return once the join is accepted, without waiting for it to connect or trusting this device
```

## catalex doctor

Check that CatalEx is ready; exits 1 when a part is not ready.

Check the selected computer's readiness: CatalEx itself, its storage, the
connection to your agents and the link to the messaging service. Exits 1 when
any of them is not ready or CatalEx cannot be reached. Read-only unless --fix
is given: --fix checks this computer, restarts CatalEx when it stopped or does
not answer, moves an oversized or unsafe activity log aside and reports each
finding as repaired or open, with a code and a remedy action in --json, and,
for an open one, the exact command that fixes it (command in --json). Damaged
saved data is never touched by --fix alone; --fresh-start moves it aside (it
stays on disk, unread) after a confirmation, or --yes. Deleting data never
uninstalls catalex, its components or the app.

```text
catalex doctor [flags]
```

Examples:

```sh
  catalex doctor
  catalex doctor --deployment agent --json
  catalex doctor --fix --json
```

Flags:

```text
      --deployment string   Deployment to check: native_chat or agent (default "native_chat")
      --fix                 Repair this computer: restart what stopped and move an oversized or unsafe log aside
      --fresh-start         With --fix: move damaged saved data aside and start clean; agents and settings on this computer are no longer available
      --yes                 With --fresh-start: confirm without asking
```

## catalex hosting

Read the messaging service's agents and conversations.

```text
catalex hosting
```

Examples:

```sh
  catalex hosting agents
  catalex hosting sessions SERVICE_ID PROJECT_ID AGENT_ID
```

## catalex hosting agents

List the agents your messaging service holds with channel and session counts.

```text
catalex hosting agents
```

Examples:

```sh
  catalex hosting agents --json
```

## catalex hosting sessions

List one messaging service agent's Slack and WhatsApp conversations.

```text
catalex hosting sessions SERVICE_ID PROJECT_ID AGENT_ID
```

Examples:

```sh
  catalex hosting sessions SERVICE_ID PROJECT_ID AGENT_ID
```

## catalex install

Install CatalEx on this computer from a verified release.

Install everything CatalEx needs on this computer from one published release:
its agent runtime, the app's server and, on macOS with Apple Silicon, the app.
Name components to install only those: catalex, service, web, app; service is CatalEx's agent runtime and web its app server.
Each archive is checked against the release's checksums before it is placed.
Commands share one folder (~/.local/bin unless already installed elsewhere)
and are recorded so update and uninstall know they are yours; the CatalEx
app's server stays off PATH in the installation folder, where catalex open
finds it. Nothing is set up, started or signed in; run catalex setup afterwards. The app is for macOS
on Apple Silicon and is not opened unless --open is given. With --self, the
running client installs and records itself instead, as the CatalEx app does
with the client it carries; a recorded client that is not older is kept.

```text
catalex install [COMPONENT...] [flags]
```

Examples:

```sh
  catalex install
  catalex install service
  catalex install service --version VERSION
  catalex install app --apps-dir ~/Applications --open
  catalex install catalex --self
  catalex install status
```

Flags:

```text
      --apps-dir string   Applications folder for the app (default: /Applications, else ~/Applications)
      --bin-dir string    Folder for the commands (default: the installed commands' folder, else ~/.local/bin)
      --from-dir string   Install from a local release build folder (assets/ and tree/)
      --no-path           Do not add the commands' folder to your login shell's PATH
      --open              Open the app after installing it
      --self              Install this running catalex instead of downloading one (component catalex only)
      --version string    Release to install (default: the newest)
      --yes               Quit a running CatalEx app that must be replaced
```

## catalex install status

Show the installed components, their release and integrity.

Show each installed command's recorded path, release and SHA-256 and whether
the file still matches it (intact, changed, missing, unrecorded or absent),
and the CatalEx app in the applications folder. The app's server is kept off
PATH, in the installation folder; the CatalEx app and catalex open run it.
Read-only.

```text
catalex install status [flags]
```

Examples:

```sh
  catalex install status
  catalex install status --json
```

Flags:

```text
      --apps-dir string   Applications folder holding the app (default: /Applications, else ~/Applications)
      --bin-dir string    Folder to look for unrecorded commands in (default: the installed commands' folder)
```

## catalex join

Join CatalEx on this computer to an account with a one-time code.

Join the selected computer to a CatalEx account (F2), with
a one-time join code from a signed-in device (catalex computers add there).
The code is read hidden from the terminal, as one piped line, or from a
private --join-file; it never goes in the command line. --trust pins the
fingerprint of the key that created the code: a code from any other key is
refused and nothing is saved. Running it again on a joined computer
changes nothing. Joining never signs anyone in on this computer.

```text
catalex join [flags]
```

Examples:

```sh
  catalex join --trust 16VD-FXD6-44CV-84CW-NGF3-1V19-3M --service https://catalex.example.com
  catalex join --trust FINGERPRINT --service https://catalex.example.com --join-file /root/join-code
```

Flags:

```text
      --join-file string   Read the code from this private file instead of the terminal
      --name string        The name your devices show for this computer (default: its computer name)
      --no-wait            Report the accepted join without waiting for this computer to connect
      --service string     The messaging service address the code is from (default: CatalEx Cloud)
      --trust string       Fingerprint of the key that created the code, from the join command
```

## catalex local-setup

Turn the complete setup on this computer on or off.

Turn the complete development setup on this computer (agents, native
chats and a messaging service here) on or off. On stops a running setup
first. When agents are connected to a remote service, on is refused unless
--replace-identity confirms replacing that connection: it is set aside with
its conversations, and connecting to it again resumes it. Off stops it and removes the local messaging service's containers, keeping
agents, conversations, media and saved data.

```text
catalex local-setup
```

Examples:

```sh
  catalex local-setup on
  catalex local-setup off
```

## catalex local-setup off

Turn the complete local setup off.

```text
catalex local-setup off [flags]
```

Examples:

```sh
  catalex local-setup off
```

Flags:

```text
      --no-wait   Return once the change is accepted instead of waiting for it
```

## catalex local-setup on

Turn the complete local setup on.

```text
catalex local-setup on [flags]
```

Examples:

```sh
  catalex local-setup on
```

Flags:

```text
      --no-wait            Return once the change is accepted instead of waiting for it
      --replace-identity   Confirm replacing the service connection the agents use; the earlier one is set aside with its conversations
```

## catalex login

Sign in to your CatalEx account from this terminal.

Sign in to your CatalEx account. It signs in with Google in the
system browser. The account service is --service, else the one the selected computer
uses, else CatalEx Cloud. The sign-in is kept for your user on this
computer; signing in again to the same service changes nothing unless
--force is given. Signing in and joining this computer to the account are one step:
when CatalEx on this computer has joined no account it joins this one, asking
nothing, and the computer then vouches for this device so it is trusted for
changes. A computer that joined another account never runs agents for it
while you are signed in to this one: it leaves that account (the account
keeps the computer, offline), sets its agents aside and joins a new
computer for this account with no agents, and the sign-in tells you so once
(switched_computer_account in --json); signing back in to the other
account returns them. When the join cannot complete, signing in fails, nothing is left signed in
and this computer is put back as it was, on the account it had left. It also starts the agents on this computer that
are off and leaves running agents untouched; a failure there is a warning.
Undo it with catalex computers leave. The same holds after login --code.

The Google sign-in follows Google's flow for desktop apps: it opens Google's
account chooser in your system browser, receives the answer on a local
port and waits for you, up to 10 minutes (CATALEX_CLIENT_SIGNIN_TIMEOUT_MS).
It prints the link too, for a browser that did not open. Ctrl-C stops it.

```text
catalex login [flags]
```

Examples:

```sh
  catalex login
  catalex login --service https://catalex.example.com
  catalex login --code --service https://catalex.example.com
```

Flags:

```text
      --code             Sign in with a one-time sign-in code from a signed-in device, read hidden from the terminal
      --force            Sign in again, replacing a saved sign-in
      --google           Sign in with Google in the system browser (the default)
      --name string      With --code, the name other devices see for this one (default: this computer's name)
      --service string   Account service origin: HTTPS, or HTTP on a loopback address
```

## catalex login-codes

Create one-time codes that sign in another device.

```text
catalex login-codes
```

Examples:

```sh
  catalex login-codes create
```

## catalex login-codes create

Create a one-time code that signs in another device as you.

Create a one-time sign-in code (F6). On the other device, run the printed
command and paste the code: that device signs in to this account and is
trusted for changes at once, because this trusted device vouches for it.
Only a trusted device can create one; trust a new sign-in first with
catalex devices trust.
The code works once and expires. It is shown once and never put in a URL.

```text
catalex login-codes create [flags]
```

Examples:

```sh
  catalex login-codes create
  catalex login-codes create --lifetime 10m
```

Flags:

```text
      --lifetime duration   How long the code stays valid, such as 5m (default: the service's sign-in code lifetime)
      --no-wait             Print the code and stop, without waiting for the other device to sign in
```

## catalex logout

Sign out of your CatalEx account on this computer.

Sign out of your CatalEx account: the account service removes this
sign-in and this computer forgets it. When the service cannot be reached,
the sign-in is still removed here. An account move whose outcome is not
known is forgotten too. Signing out only removes the sign-in: this computer
stays joined and connected to its account and its agents keep running, and the
next sign-in checks it again. Signing out never stops CatalEx: it keeps running
here, native chats included. With --stop-agents this computer also leaves the
account and drops its connection to CatalEx Cloud, so CatalEx runs on this
computer only (computer_left in --json; left_on_service is false when the
service could not be told and the computer was forgotten here only), and the
running agents' turns end and their runtimes close, so they stop answering
until their next message. The command waits until the computer has
disconnected; nothing is deleted or recorded as a stop. When disconnecting or
stopping the agents fails, you stay signed in; run it again.

```text
catalex logout [flags]
```

Examples:

```sh
  catalex logout
  catalex logout --stop-agents
```

Flags:

```text
      --stop-agents   Also leave the account and disconnect this computer from CatalEx Cloud, and end the running agents' turns and close their runtimes; CatalEx keeps running and nothing is deleted
```

## catalex messages

Send a message for an agent without waiting for the person to write.

```text
catalex messages
```

Examples:

```sh
  catalex messages send --agent AGENT_ID --text 'Your report is ready' --idempotency-key report-1
  catalex messages status --agent AGENT_ID SEND_ID
```

## catalex messages send

Send a message to one of an agent's people now.

Send a message for an agent to one of its people now, without the person
writing first. It is the same send the agent's own tool makes: CatalEx only
delivers what you give it. The agent must be allowed to send without being
asked (catalex agents edit AGENT_ID --proactive-send on). Name the person with
--to; omit it only when the agent has exactly one person. To message someone
the agent has not messaged yet, give their address with --new-recipient
instead (a phone number in international format); the agent must be allowed
to message new people (catalex agents edit AGENT_ID --message-new-people on),
and you are responsible for having the person's consent. The result names the
person's reference: use --to with it from then on. Use a new
--idempotency-key for each message and reuse it only to retry the same one.

The result is queued (recorded, no outcome yet), delivered, held (outside the
app's delivery window: not sent now and not to be sent again, it goes out when
the person next writes), refused or failed. The exit is 0 for queued, delivered
and held, and 1 for refused and failed, with the code and the command that
fixes it. Read a later outcome with catalex messages status.

```text
catalex messages send [flags]
```

Examples:

```sh
  catalex messages send --agent AGENT_ID --to CONTACT_REF --text 'Your report is ready' --idempotency-key report-1
  catalex messages send --agent AGENT_ID --new-recipient +15551234567 --text 'Your report is ready' --idempotency-key report-2
  catalex messages send --agent AGENT_ID --text 'Good morning' --idempotency-key morning-1 --json
```

Flags:

```text
      --account string           The account ID to use, when the person is on more than one account of the app
      --agent string             ID of the agent that sends the message (from catalex agents list)
      --app string               The messaging app to use, when more than one reaches the person
      --idempotency-key string   A new key for each message; reuse it only to retry the same message
      --new-recipient string     Instead of --to: the address of someone the agent has not messaged yet, such as a phone number in international format; only when the agent may message new people
      --text string              The exact message text
      --to string                The person to message, by contact reference; omit it only when the agent has exactly one person
```

## catalex messages status

Show the outcome of a message an agent sent.

Show the current outcome of a send the agent made, by the send ID that
catalex messages send printed. A queued or held send changes later: a held one
is delivered when the person next writes. Another agent's send ID is
SEND_UNKNOWN. The exit follows the status as it does for send.

```text
catalex messages status SEND_ID [flags]
```

Examples:

```sh
  catalex messages status --agent AGENT_ID SEND_ID
  catalex messages status --agent AGENT_ID SEND_ID --json
```

Flags:

```text
      --agent string   ID of the agent that sent the message (from catalex agents list)
```

## catalex open

Launch or focus the CatalEx app at a view.

Launch or focus the installed CatalEx app on this computer, optionally at a
view. It never opens a browser; an absent app fails with its install action.

```text
catalex open [flags]
```

Examples:

```sh
  catalex open
  catalex open --section settings/providers
  catalex open --conversation REF
  catalex open --conversation REF --print-link
```

Flags:

```text
      --app-path string       Absolute installed CatalEx.app path; never falls back to another app
      --conversation string   Open the conversation with this reference
      --print-link            With --conversation, print the app link instead of launching the app
      --section string        View to show: agents, settings, settings/providers, settings/channels
```

## catalex path

Put the commands' folder on your login shell's PATH, or take it off.

```text
catalex path
```

Examples:

```sh
  catalex path status
  catalex path add
```

## catalex path add

Add the commands' folder to your login shell's profile once.

Add one marked block to the profile your login shell reads (~/.zprofile for
zsh, the first existing bash login file, or fish's conf.d), the same block
the installers and the CatalEx app add. Nothing changes when the profile
already adds the folder. Open a new terminal afterwards.

```text
catalex path add [flags]
```

Examples:

```sh
  catalex path add
  catalex path add --bin-dir ~/bin
```

Flags:

```text
      --bin-dir string   Folder holding the commands (default: the installed commands' folder, else ~/.local/bin)
```

## catalex path remove

Remove the marked block from every login profile; other lines are kept.

```text
catalex path remove [flags]
```

Examples:

```sh
  catalex path remove
```

Flags:

```text
      --bin-dir string   Folder holding the commands (default: the installed commands' folder, else ~/.local/bin)
```

## catalex path status

Show whether new terminals find the commands.

```text
catalex path status [flags]
```

Examples:

```sh
  catalex path status
  catalex path status --json
```

Flags:

```text
      --bin-dir string   Folder holding the commands (default: the installed commands' folder, else ~/.local/bin)
```

## catalex prepare

Make sure CatalEx's management service is ready on this computer.

Start or attach to this computer's management service without starting
configured agent or messaging workloads. It requires no account, AI provider
or completed setup and preserves saved identities and connection settings.
It is safe to run again at any time. A --connection never selects another
computer for this operation.

```text
catalex prepare
```

Examples:

```sh
  catalex prepare
  catalex prepare --json
```

## catalex projects

Manage the folders native chats work in.

```text
catalex projects
```

Examples:

```sh
  catalex projects list
  catalex projects add --root /path/on/computer --name Website
```

## catalex projects add

Register a folder on the selected computer.

Register an existing absolute folder on the selected computer for
native chats. The folder is resolved there, never against this terminal.

```text
catalex projects add [flags]
```

Examples:

```sh
  catalex projects add --root /Users/me/site --name Website --topic "Marketing site"
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
      --name string              Folder label
      --rich-cards string        Rich cards for chats created afterwards: on or off
      --root string              Absolute existing folder on the selected computer
      --topic string             Short topic shown with the folder
```

## catalex projects edit

Change a folder's label, topic or rich-card choice.

Change a folder's label, topic or rich cards. A folder's root cannot change.
Rich cards apply to chats created afterwards; existing chats keep theirs.

```text
catalex projects edit ID [flags]
```

Examples:

```sh
  catalex projects edit PROJECT_ID --name Docs
  catalex projects edit PROJECT_ID --rich-cards off
```

Flags:

```text
      --deployment string        Deployment whose console holds the chat or folder: native_chat or agent (default "native_chat")
      --idempotency-key string   Replay an earlier request with its original key instead of a new one
      --name string              New folder label
      --rich-cards string        Rich cards for chats created afterwards: on or off
      --topic string             New topic
```

## catalex projects list

List registered folders with their labels and rich-card choice.

```text
catalex projects list [flags]
```

Examples:

```sh
  catalex projects list
  catalex projects list --json
```

Flags:

```text
      --cursor string       Continue from an opaque server-issued page cursor
      --deployment string   Deployment whose folders to list: native_chat or agent (default "native_chat")
```

## catalex providers

Show every AI provider, its version, state and whether it is connected.

Show the AI providers (Codex, Claude Code) the selected computer found, whether
this setup uses each one (connected), its version and state. Detect them
again with catalex providers discover; connect or disconnect one with
catalex providers connect or disconnect. Sign in with catalex providers login.

```text
catalex providers
```

Examples:

```sh
  catalex providers
  catalex providers --json
```

## catalex providers connect

Use an installed, signed-in provider (codex or claude) in this setup.

Connect Codex or Claude Code to this setup. It must be installed and signed in.
Everything else is kept, and nothing stops or restarts: new agents can use
it at once.

```text
catalex providers connect PROVIDER
```

Examples:

```sh
  catalex providers connect codex
```

## catalex providers disconnect

Stop using a provider (codex or claude) in this setup.

Disconnect Codex or Claude Code from this setup, keeping everything else.
It is refused while an agent or chat uses it, and for the only provider.

```text
catalex providers disconnect PROVIDER
```

Examples:

```sh
  catalex providers disconnect codex
```

## catalex providers discover

Detect every AI provider again and list it.

Run the read-only checks of Codex and Claude Code again (installed, version,
sign-in) and list every one, connected or not. It never signs in.

```text
catalex providers discover
```

Examples:

```sh
  catalex providers discover
  catalex providers discover --json
```

## catalex providers login

Sign in to Codex or Claude Code with its own sign-in on this computer.

Run the provider's own sign-in on this computer: codex login, or claude auth
login. CatalEx never sees or records the credentials or the sign-in output.
A provider on a remote computer must sign in there.

```text
catalex providers login PROVIDER
```

Examples:

```sh
  catalex providers login claude
  catalex providers login codex
```

## catalex refresh

Re-verify installed agents and their model inventory.

Re-verify the installed AI agents in their current release and replace
their verified model inventory. Codex and Claude Code themselves are never replaced.

```text
catalex refresh
```

Examples:

```sh
  catalex refresh
  catalex refresh --json
```

## catalex restart

Restart CatalEx on the selected computer.

Stop, then start the selected computer's services, waiting for each.

```text
catalex restart [flags]
```

Examples:

```sh
  catalex restart
  catalex restart --json
```

Flags:

```text
      --force     First end this computer's management service if it does not answer (SIGTERM, then SIGKILL after a grace period), so a hung CatalEx can be restarted; a service that answers is left alone
      --no-wait   Return once the request is accepted instead of waiting for its outcome
```

## catalex settings

Show the Developer settings catalog with defaults and ranges.

Show every configurable value of the selected computer with its
effective value, default, allowed range, unit, whether it can be edited and
what restarts when it changes. Secrets are never listed.

```text
catalex settings
```

Examples:

```sh
  catalex settings
  catalex settings --json
```

## catalex settings advanced

Show the Advanced settings in people's units.

```text
catalex settings advanced
```

Examples:

```sh
  catalex settings advanced
  catalex settings advanced --json
```

## catalex settings advanced set

Change Advanced settings; unnamed values are kept.

Change Advanced settings, each an integer in the unit catalex settings
advanced shows (for example minutes or MiB). Unnamed values keep their
current value.

```text
catalex settings advanced set KEY=VALUE... [flags]
```

Examples:

```sh
  catalex settings advanced set max_warm_runtimes=60 attachment_retention_days=7
```

Flags:

```text
      --no-wait   Return once the change is accepted instead of waiting for it to apply
```

## catalex settings endpoints

Inspect or safely move this computer's control listener.

```text
catalex settings endpoints
```

Examples:

```sh
  catalex settings endpoints show
  catalex settings endpoints set --port 7478
```

## catalex settings endpoints deployments

Inspect or migrate positively owned deployment listeners.

```text
catalex settings endpoints deployments
```

Examples:

```sh
  catalex settings endpoints deployments show native_chat
  catalex settings endpoints deployments set native_chat console_port 17855
```

## catalex settings endpoints deployments operation

Inspect an original deployment operation without another mutation.

```text
catalex settings endpoints deployments operation TARGET OPERATION_ID
```

Examples:

```sh
  catalex settings endpoints deployments operation native_chat 11111111111111111111111111111111
```

## catalex settings endpoints deployments recover

Explicitly reconcile the original fenced deployment operation.

```text
catalex settings endpoints deployments recover TARGET OPERATION_ID
```

Examples:

```sh
  catalex settings endpoints deployments recover native_chat 11111111111111111111111111111111
```

## catalex settings endpoints deployments set

Move one advertised active listener without changing its owner.

Use the selected computer's deployment endpoint operation. Only advertised
active fields may move; a receipt's child address never receives control
authority. The original ID is printed before submission. Lost replies inspect
the same original; --operation-id inspects a known request without resending.

```text
catalex settings endpoints deployments set TARGET FIELD PORT [flags]
```

Examples:

```sh
  catalex settings endpoints deployments set native_chat console_port 17855
  catalex settings endpoints deployments set service service_port 17853 --no-wait
```

Flags:

```text
      --no-wait               Return observed acceptance without following completion
      --operation-id string   Inspect this original operation without resubmission
      --revision string       Expected public generation; omitted reads it first
```

## catalex settings endpoints deployments show

Read active fields, supported handoffs and their original operation.

```text
catalex settings endpoints deployments show TARGET
```

Examples:

```sh
  catalex settings endpoints deployments show service --json
```

## catalex settings endpoints operation

Inspect the original endpoint transition without resending it.

```text
catalex settings endpoints operation OPERATION_ID
```

Examples:

```sh
  catalex settings endpoints operation 11111111111111111111111111111111
```

## catalex settings endpoints recover

Reconcile the original fenced endpoint operation.

```text
catalex settings endpoints recover OPERATION_ID
```

Examples:

```sh
  catalex settings endpoints recover 11111111111111111111111111111111
```

## catalex settings endpoints set

Reserve and hand off a positively owned control endpoint.

Change a supported control port or numeric loopback bind without restarting
unaffected agents. CatalEx owns reservation, readiness and recovery. Its
original operation is printed before sending. Lost replies inspect the same
ID after fresh private discovery; manual connections need explicit updates.

```text
catalex settings endpoints set [flags]
```

Examples:

```sh
  catalex settings endpoints set --port 7478
  catalex settings endpoints set --bind ::1 --operation-id 11111111111111111111111111111111
```

Flags:

```text
      --bind string           Numeric loopback bind address
      --no-wait               Return the observed receipt without following client reconnect
      --operation-id string   Inspect this original operation without resubmitting; omitted generates a new request
      --port int              Replacement control port
      --revision string       Expected nonsecret generation; omitted reads it first
```

## catalex settings endpoints show

Read the owned control endpoint and its nonsecret revision.

```text
catalex settings endpoints show
```

Examples:

```sh
  catalex settings endpoints show --json
```

## catalex settings set

Change settings; null restores a default.

Change Developer settings. VALUE is a JSON number, list, true or false, or
null (restore the default). CatalEx validates the change as loading
configuration does; a refused change names its field and writes nothing.
Running services restart when a changed limit needs it.

```text
catalex settings set KEY=VALUE... [flags]
```

Examples:

```sh
  catalex settings set limits.max_warm_runtimes=60
  catalex settings set limits.max_warm_runtimes=null
  catalex settings set controller.show_other_computers_chats=true
```

Flags:

```text
      --no-wait   Return once the change is accepted instead of waiting for it to apply
```

## catalex setup

Set up CatalEx: CatalEx Cloud, everything on this computer or a CatalEx service URL.

Set up CatalEx with the app's choices: --preset cloud (CatalEx Cloud: without a
--token-file and a saved sign-in, it first signs in with Google as catalex
login does, joins and trusts this computer, then connects), everything
(agents, native chats and a messaging service on this computer) or
self-hosted (connect to the CatalEx service at --service-url), or an explicit --mode.
Every setup that runs agents on this computer includes native chats.
Saved choices are reused; only missing answers are needed. Without --start
setup only configures; with --start it also starts and waits for readiness.

On this computer setup runs the installed CatalEx runtime. A remote
computer selected with --connection is set up through its control API; saving
without --start needs a computer whose API offers that choice.

```text
catalex setup [flags]
```

Examples:

```sh
  catalex setup --preset cloud --native-providers claude --start
  catalex setup --preset everything --native-providers claude --start
  catalex setup --preset self-hosted --service-url https://catalex.example.com --token-file /private/service.token
  catalex setup --mode native_chat --start
```

Flags:

```text
      --agents-console-port int    Port on this computer for the agents' page; the saved choice or default is kept when omitted
      --agents-port int            Port on this computer for agents; the saved choice or default is kept when omitted
      --chat-console-port int      Port on this computer for the native chats' page; the saved choice or default is kept when omitted
      --chat-port int              Port on this computer for native chats; the saved choice or default is kept when omitted
      --claude-binary string       Claude Code executable to add on this computer (path or command name)
      --codex-binary string        Codex executable to use on this computer when it is not on the PATH (path or command name)
      --control-port int           Port on this computer for CatalEx's management service; the saved choice or default is kept when omitted
      --database-port int          Port on this computer for the messaging service's database; the saved choice or default is kept when omitted
      --destinations strings       Messaging destinations: slack, whatsapp, googlechat or several
      --mode string                Explicit mode: native_chat, connect, development or server
      --native-providers strings   AI providers: codex, claude or both; empty initializes only the core; omission reuses saved choices
      --no-launch                  With --start, do not open the CatalEx app
      --preset string              The app's choice: everything, cloud or self-hosted
      --replace-identity           Confirm replacing the service connection the agents use; the earlier one is set aside with its conversations
      --service-port int           Port on this computer for the messaging service; the saved choice or default is kept when omitted
      --service-url string         CatalEx service URL for connect, self-hosted or cloud
      --start                      Also start, wait for readiness and open the CatalEx app when this installation installed it
      --token-file string          Read the service credential from an owned private file
      --token-stdin                Read the service credential from piped standard input
      --tunnel string              Managed tunnel for the messaging service here: ngrok, cloudflared or none
      --tunnel-public-url string   Public HTTPS URL of the tunnel (cloudflared, or a reserved ngrok domain)
      --tunnel-token-file string   Absolute owner-only cloudflared tunnel token file
```

## catalex start

Start CatalEx on the selected computer.

Start the selected computer's services and wait for the outcome. With no
published CatalEx on this computer, start first starts the management
service of the installed CatalEx runtime, then uses that same installation.

```text
catalex start [flags]
```

Examples:

```sh
  catalex start
  catalex start --json
```

Flags:

```text
      --no-wait   Return once the request is accepted instead of waiting for its outcome
```

## catalex status

Show CatalEx's setup, operation and component states on the selected computer.

Show the selected computer's configuration, current operation, its
end-to-end health (CatalEx, the messaging service and the agents' link
to it, checked on reads at most once a minute) and each component's state. When this
computer has joined your account, it also prints This computer: Connected,
Connecting… or Offline (CODE) with why in words and the step that fixes it;
--json adds this_computer with computer_id, connection, connection_problem,
connection_problem_detail and connection_remedy. Read-only:
it never starts anything. With nothing selected and no management service running
on this computer, it reads the saved state of the installed CatalEx runtime.

```text
catalex status
```

Examples:

```sh
  catalex status
  catalex status --json
  catalex status --connection office
```

## catalex status metrics

Show how many calls CatalEx makes and receives.

Show call counts for each part of CatalEx, since it started and in its last
summary window: requests to the messaging service and other hosts (by
method, route and status class, with latency), connector frames, the
app's status requests to CatalEx, agent turns by AI provider with the
tokens they report, messages per channel type and transcripts. Use it to
see where call volume is too high. The same counts are logged every minute
as "call summary" lines. Read-only; CatalEx must be running.

```text
catalex status metrics
```

Examples:

```sh
  catalex status metrics
  catalex status metrics --json
```

## catalex stop

Stop CatalEx on the selected computer.

Stop the selected computer's services; its management service stays available
unless --all closes it too. With nothing selected and no management service
running on this computer, the installed CatalEx runtime stops any retained
deployment.

```text
catalex stop [flags]
```

Examples:

```sh
  catalex stop
  catalex stop --json
```

Flags:

```text
      --all       Also close the management service, so nothing of CatalEx keeps running on the selected computer
      --force     First end this computer's management service if it does not answer (SIGTERM, then SIGKILL after a grace period), so a hung CatalEx can be stopped; a service that answers is left alone
      --no-wait   Return once the request is accepted instead of waiting for its outcome
```

## catalex transcript

Show a Slack or WhatsApp conversation's read-only snapshot.

Show a messaging conversation's read-only snapshot: from a deployment of the
selected computer (--deployment native_chat or agent) or a connected messaging
service conversation that its agent deployment holds (--hosted). Session IDs
are listed by catalex analytics and catalex hosting sessions. There is no
send action for Slack or WhatsApp.

```text
catalex transcript SESSION_ID [flags]
```

Examples:

```sh
  catalex transcript SESSION_ID --deployment agent
  catalex transcript SESSION_ID --hosted
```

Flags:

```text
      --deployment string   Deployment that holds the conversation: native_chat or agent
      --hosted              Read a messaging service conversation this computer's agent deployment holds
```

## catalex uninstall

Remove installed components; saved data is kept.

Remove the named components (catalex, service, web, app; service is CatalEx's agent runtime and web its app server), or every
component CatalEx's installers own when none is named. CatalEx is stopped
first. Saved chats and settings are kept unless --purge deletes CatalEx's
saved data too, with the CatalEx app's own state when it goes
(its computer list, the setup wizard's progress and the app's data
folder), so a later install starts afresh. Unnamed components keep their
files and PATH entry; the PATH block goes with the last command. A command
changed since it was installed is kept, and a running app must be quit
first (--wait-for-app waits for it to quit). Removing the app also removes the earlier app's leftover speech folder
when it holds only the app's own files; install and update remove it too.

```text
catalex uninstall [COMPONENT...] [flags]
```

Examples:

```sh
  catalex uninstall
  catalex uninstall service
  catalex uninstall app
  catalex uninstall --purge
```

Flags:

```text
      --apps-dir string   Applications folder holding the app (default: /Applications, else ~/Applications)
      --purge             Also delete CatalEx's saved chats, credentials and owned data, the removed CatalEx app's own state, and the release files
      --wait-for-app      Wait for a running CatalEx app to quit before removing it, up to the operation timeout
```

## catalex update

Update the installed components to the newest release.

Update the named components (catalex, service, web, app; service is CatalEx's agent runtime and web its app server), or every component
installed by CatalEx's installers when none is named, to the newest
release; nothing is ever downgraded. A command changed since it was installed
is kept and reported. While CatalEx runs, update refuses unless --restart lets
it stop CatalEx, update and upgrade its saved deployments, then start it again.
A running app is quit only with --yes. --check only reports.

```text
catalex update [COMPONENT...] [flags]
```

Examples:

```sh
  catalex update --check
  catalex update --restart
  catalex update service web --restart
  catalex update --yes --open
```

Flags:

```text
      --apps-dir string   Applications folder holding the app (default: /Applications, else ~/Applications)
      --check             Only report the newest release and what would change
      --from-dir string   Update from a local release build folder (assets/ and tree/)
      --open              Open the app after updating it
      --restart           Stop a running CatalEx, update it and start it again
      --yes               Quit a running CatalEx app that must be replaced
```

## catalex usage

Show CPU, memory, disk and token usage per chat and service.

```text
catalex usage
```

Examples:

```sh
  catalex usage
  catalex usage --json
```

## catalex version

Show the installed client version.

```text
catalex version
```

Examples:

```sh
  catalex version
  catalex version --json
```
