#!/bin/sh
# Install CatalEx from a published release, then run the default setup.
# catalex-installer-contract: 3
#
#   sh install.sh [--version V] [--only catalex,service,web]
#                 [--setup local|connect|skip] [--service-url URL] [--token-file FILE]
#                 [--agent-folder DIR] [--agent-provider claude|codex]
#                 [--agent-model M] [--agent-effort E] [--no-agent]
#                 [--channels slack,whatsapp|none]
#                 [--no-setup] [--no-open] [--yes] [--bin-dir DIR] [--no-path]
#                 [--from-dir DIR]
#
# In a terminal the installer is a wizard: it asks which parts to install,
# how to set CatalEx up, whether to create a first agent and whether to open
# the CatalEx app, with the default in brackets and a way to skip each step.
# Every answer has a flag. Without a terminal, or with --yes, nothing is
# asked: flags and defaults decide. The installer never signs in to Claude
# Code or Codex; it only reads their sign-in state. Anything skipped can be
# configured later in the CatalEx app's Settings.
#
# The installer puts the commands' folder on the login shell's PATH itself:
# it adds one marked block to the profile file that zsh, bash or fish reads
# at login (the same block the CatalEx desktop app adds, so neither adds a
# second), unless the folder is already on PATH. --no-path leaves PATH alone.
#
# RELAY_INSTALL_FORCE_TTY=1 makes the installer ask even when stdin or stdout
# is not a terminal. It exists only for the installer's own tests.
#
# Downloads this computer's archives from the GitHub Release v<V> of the
# distribution repository, verifies each against the release's SHA256SUMS
# (and latest.json), installs the catalex command and the service command into
# ~/.local/bin and records the installation. The web app's command stays
# private in the installation prefix's libexec/ folder, off PATH: the CatalEx
# app runs its own copy, and catalex finds this one through the record.
# An earlier installation's unchanged copy in the commands folder moves
# there on any later run. Downloads use gh when logged in, else GITHUB_TOKEN or GH_TOKEN
# (in a private curl header file), else downloads.catalex.co (RELAY_DOWNLOADS_URL= off), then GitHub.
#
# POSIX sh has no pipefail, so a failing command early in a pipeline is not
# fatal by itself. Each pipeline's result here is checked instead: checksums
# must equal the expected value, and an archive whose listing fails also
# fails to extract under set -e.
set -eu

REPO="${RELAY_RELEASE_REPO:-catalex-ai/catalex-builds}"
BRANCH="${RELAY_RELEASE_BRANCH:-main}"
API="https://api.github.com"
OWNER="catalex-relay/developer-install-v1"
# The marker keeps the skill's earlier name so existing installations stay owned.
SKILL_OWNER="catalex-relay/relay-setup"

version=""
only=""
setup_mode=""
service_url=""
token_file=""
agent_folder=""
agent_provider=""
native_providers=""
agent_model=""
agent_effort=""
no_agent=0
channels=""
yes=0
open=""
skipped=""
bin_dir="$HOME/.local/bin"
bin_dir_explicit=0
join_computer=0
join_file=""
join_trust=""
join_service_home="/var/lib/catalex"
join_service_home_explicit=0
# Control timeouts in milliseconds.
join_wait_ms="${CATALEX_JOIN_WAIT_MS:-30000}"
join_probe_ms="${CATALEX_JOIN_PROBE_MS:-1000}"
join_service_changed=0
join_tty_mode=""
join_active_pid=""
join_term_grace=2 # seconds a helper gets to obey TERM before an interrupt kills it
join_input="/dev/null"
join_input_code=0
join_quiet=0
work=""
join_probe_cache_created=0
join_probe_prefix_created=0
from_dir=""
prefix="$HOME/.local/share/catalex-relay"
# private_dir holds commands that are not for the terminal (the web app
# server, which the CatalEx app and catalex start); it is never put on PATH.
private_dir="$prefix/libexec"
skill_dir="$HOME/.codex/skills/catalex-setup"
legacy_skill_dir="$HOME/.codex/skills/relay-setup"
add_path=1

say() { printf '%s\n' "$*" >&2; }
die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}
usage() {
	cat >&2 <<'USAGE'
usage: sh install.sh [--version V] [--only catalex,service,web]
                     [--setup local|connect|skip | --no-setup]
                     [--service-url URL] [--token-file FILE]
                     [--agent-folder DIR] [--agent-provider claude|codex]
                     [--native-providers codex|claude|codex,claude]
                     [--agent-model MODEL] [--agent-effort EFFORT] [--no-agent]
                     [--channels slack,whatsapp | none]
                     [--open | --no-open] [--yes] [--bin-dir DIR] [--no-path]
                     [--from-dir DIR]
                     [--join | --join-file FILE] [--trust FINGERPRINT]
                     [--service ORIGIN] [--service-home DIR]

  --join     install the catalex client and CatalEx and join this
             computer (Linux/systemd); read the code hidden from
             /dev/tty. --join-file reads a private file instead. --trust
             pins the issuer; --service selects its CatalEx service
             address. Provider setup is reported afterward.
  --only     parts to install: catalex (the command), service (runs agents;
             always installs catalex too) and web (the CatalEx web app).
  --no-path  do not add the commands' folder to your login shell's PATH;
             by default the installer adds it to ~/.zprofile (zsh),
             ~/.bash_profile (bash) or fish's conf.d, once.
USAGE
	exit "$1"
}

need_value() {
	[ "$#" -ge 2 ] && [ -n "$2" ] || die "$1 needs a value"
}

join_require_terminal() {
 if ! { [ -t 0 ] </dev/tty; } 2>/dev/null; then
  die "--join needs a terminal; use --join-file for unattended installation"
 fi
}

join_validate_input() {
 if [ -n "$join_file" ]; then
  case "$join_file" in /*) ;; *) die "--join-file must be an absolute path";; esac
  [ ! -L "$join_file" ] && [ -f "$join_file" ] && [ -r "$join_file" ] || die "--join-file must name a readable private regular file"
  # POSIX ls keeps the permission columns identical on BSD and GNU systems.
  # The CLI additionally validates opened-file ownership and refuses links.
  # shellcheck disable=SC2012 # Only fixed permission columns are read.
  [ "$(LC_ALL=C ls -ld "$join_file" | cut -c1-10)" = '-rw-------' ] || die "--join-file must be private (0600)"
 else
  join_require_terminal
 fi
}

join_cleanup() {
 if [ -n "$join_tty_mode" ];then stty "$join_tty_mode" </dev/tty 2>/dev/null || true;fi
 if [ -n "$work" ];then rm -rf "$work";work="";fi
 if [ "$join_probe_cache_created" = 1 ];then rmdir "$prefix/cache" 2>/dev/null || true;fi
 if [ "$join_probe_prefix_created" = 1 ];then rmdir "$prefix" 2>/dev/null || true;fi
 join_probe_cache_created=0
 join_probe_prefix_created=0
}
# Async wait lets sh trap while a helper blocks; stop and reap only our child, then restore the terminal.
join_interrupt() {
 trap '' INT TERM
 if [ -n "$join_active_pid" ];then
  kill -TERM "$join_active_pid" 2>/dev/null || true
  # A TERM that lands before the child resets its inherited trap is lost; KILL ends the wait.
  ( sleep "$join_term_grace"; kill -KILL "$join_active_pid" 2>/dev/null ) & join_guard_pid=$!
  wait "$join_active_pid" 2>/dev/null || true
  kill "$join_guard_pid" 2>/dev/null || true
  join_active_pid=""
 fi
 say "Installation interrupted. Run the same command to resume."
 exit 130
}
join_run() {
 # Redirect the child itself: async stdin inheritance differs between BSD sh and dash. A code stays in a
 # private here-document; file inputs are verified installer-owned assets. A signal between spawn and
 # recording $! stays pending, so the handler never exits while its new child keeps running.
 join_cancel_pending=0
 trap 'join_cancel_pending=1' INT TERM
 if [ "$join_input_code" = 1 ];then
  "$@" <<JOIN_CODE_INPUT &
$join_code
JOIN_CODE_INPUT
 elif [ "$join_quiet" = 1 ];then
  "$@" <"$join_input" 2>/dev/null &
 else
  "$@" <"$join_input" &
 fi
 join_active_pid=$!
 join_input=/dev/null
 join_input_code=0
 join_quiet=0
 trap 'join_interrupt' INT TERM
 [ "$join_cancel_pending" = 0 ] || join_interrupt
 join_active_result=0
 wait "$join_active_pid" || join_active_result=$?
 join_active_pid=""
 return "$join_active_result"
}
# json_field prints one raw top-level JSON value. The CLI already validates and
# encodes its result; string-aware depth tracking avoids confusing nested data
# with the result's connection (notably a successful result with connection:null).
json_field() {
 awk -v wanted="$1" '
 function qend(s,p, i,c,escaped) {for(i=p+1;i<=length(s);i++){c=substr(s,i,1);if(escaped){escaped=0;continue}if(c=="\\"){escaped=1;continue}if(c=="\"")return i}return 0}
 function vend(s,p, i,c,d,j) {c=substr(s,p,1);if(c=="\"")return qend(s,p);if(c!="{"&&c!="["){for(i=p;i<=length(s);i++)if(substr(s,i,1)~/[ ,}\r\n\t]/)return i-1;return length(s)}d=0;for(i=p;i<=length(s);i++){c=substr(s,i,1);if(c=="\""){j=qend(s,i);if(!j)return 0;i=j;continue}if(c=="{"||c=="[")d++;if(c=="}"||c=="]"){d--;if(d==0)return i}}return 0}
 BEGIN{RS=""}
 {s=$0;d=0;for(i=1;i<=length(s);i++){c=substr(s,i,1);if(c=="\""){j=qend(s,i);if(!j)exit;if(d==1){name=substr(s,i+1,j-i-1);k=j+1;while(substr(s,k,1)~/[ \r\n\t]/)k++;if(name==wanted&&substr(s,k,1)==":"){p=k+1;while(substr(s,p,1)~/[ \r\n\t]/)p++;e=vend(s,p);if(e>=p)print substr(s,p,e-p+1);exit}}i=j;continue}if(c=="{"||c=="[")d++;if(c=="}"||c=="]")d--}}'
}
json_identifier() { sed -n 's/^"\([A-Za-z0-9._-][A-Za-z0-9._-]*\)"$/\1/p'; }

join_as_service() {
 if [ "$join_system" = 1 ]; then
  join_run runuser -u catalex -- env -i HOME="$join_service_home" \
   PATH="$join_service_home/.local/bin:/usr/local/bin:/usr/bin:/bin" \
   CATALEX_RELAY_HOME="$join_service_home/.catalex" \
   XDG_CONFIG_HOME="$join_service_home/.config" XDG_STATE_HOME="$join_service_home/.local/state" \
   XDG_CACHE_HOME="$join_service_home/.cache" "$@"
 else join_run "$@"; fi
}

join_controller_paths() {
 if [ "$join_system" = 1 ];then
  join_controller="$join_service_home/.local/state/catalex-relay/controller"
  join_relay_home="$join_service_home/.catalex"
  join_record="$join_service_home/.local/share/catalex-relay/installation.json"
 else
  join_controller="$HOME/.local/state/catalex-relay/controller"
  join_relay_home="${CATALEX_RELAY_HOME:-$HOME/.catalex}"
  join_record="$prefix/installation.json"
 fi
}

# `catalex computers this` only reads a running CatalEx and never starts one. Check existing
# membership before requiring a fresh code, downloading or changing a service.
join_existing_membership() {
 join_controller_paths
 join_existing_catalex="$bin_dir/catalex"
 [ -e "$join_controller/controller.json" ] && [ -e "$join_existing_catalex" ] || return 0
 [ ! -L "$join_existing_catalex" ] && [ -f "$join_existing_catalex" ] && [ -x "$join_existing_catalex" ] || die "the existing CatalEx program is not a regular executable; inspect it before joining"
 if [ "$join_system" = 1 ];then
  # Parent directories have already passed the root ownership checks.
  # shellcheck disable=SC2012 # Numeric owner and fixed permission fields.
  join_binary_info=$(LC_ALL=C ls -ldn "$join_existing_catalex") || die "the existing CatalEx program cannot be inspected"
  [ "$(printf '%s\n' "$join_binary_info" | awk '{print $3}')" = 0 ] || die "the existing CatalEx program must be root-owned before a system installation can inspect it"
  case "$(printf '%s\n' "$join_binary_info" | awk '{print $1}' | cut -c6,9)" in *w*) die "the existing CatalEx program must not be group/world-writable";;esac
  join_system_directory "$prefix/cache"
 fi
 [ -d "$prefix" ] || join_probe_prefix_created=1
 [ -d "$prefix/cache" ] || join_probe_cache_created=1
 if [ "$join_system" = 1 ];then
  (umask 022; mkdir -p "$prefix/cache")
 else
  mkdir -p "$prefix/cache"
 fi
 work=$(mktemp -d "$prefix/cache/computer-probe.XXXXXX")
 trap 'join_cleanup' EXIT
 trap 'join_interrupt' INT TERM
 join_actor_home=$HOME
 [ "$join_system" = 0 ] || join_actor_home=$join_service_home
 join_quiet=1
 if ! join_as_service env -i HOME="$join_actor_home" PATH="$bin_dir:/usr/local/bin:/usr/bin:/bin" CATALEX_RELAY_HOME="$join_relay_home" \
  "$join_existing_catalex" computers this --json >"$work/computer-status.json";then
  join_cleanup
  die "cannot verify the existing computer; inspect catalex status and start its CatalEx before retrying; no code was read"
 fi
 # catalex wraps the computer's state in its result's data field.
 json_field data < "$work/computer-status.json" > "$work/computer-state.json"
 join_membership_state=$(json_field state < "$work/computer-state.json")
 case "$join_membership_state" in
  '"not_joined"'|'"account_moved"') join_cleanup;return 0;;
  '"joined"')
   join_existing_id=$(json_field computer_id < "$work/computer-state.json" | json_identifier)
   join_existing_service=$(json_field service_url < "$work/computer-state.json" | sed -n 's/^"\([^"\\]*\)"$/\1/p')
   case "$join_existing_service" in http://?*|https://?*) ;; *) join_existing_service="";;esac
   join_existing_authority=${join_existing_service#*://}
   join_existing_authority=${join_existing_authority%/}
   case "$join_existing_authority" in ''|*/*|*@*|*'?'*|*'#'*|*[[:space:]]*) join_existing_service="";;esac
   [ -n "$join_existing_id" ] && [ -n "$join_existing_service" ] || {
    join_cleanup
    die "the existing CatalEx setup returned incomplete membership; inspect catalex computers this; no code was read"
   }
   join_cleanup
   if [ -n "$service_url" ] && [ "${service_url%/}" != "${join_existing_service%/}" ];then
    die "this computer is already joined to $join_existing_service; leave it before joining another service; no code was read"
   fi
   say "This computer is already joined to $join_existing_service as $join_existing_id; nothing changed."
   exit 0;;
  *) join_cleanup;die "the existing CatalEx setup returned unrecognized membership; inspect catalex computers this; no code was read";;
 esac
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--join) join_computer=1; shift ;;
    --join-file) need_value "$@"; join_computer=1; join_file="$2"; shift 2 ;;
    --join-file=*) join_computer=1; join_file="${1#*=}"; [ -n "$join_file" ] || die "--join-file needs a value"; shift ;;
    --trust) need_value "$@"; join_trust="$2"; shift 2 ;;
    --trust=*) join_trust="${1#*=}"; [ -n "$join_trust" ] || die "--trust needs a value"; shift ;;
    --service) need_value "$@"; service_url="$2"; shift 2 ;;
    --service=*) service_url="${1#*=}"; [ -n "$service_url" ] || die "--service needs a value"; shift ;;
    --service-home) need_value "$@"; join_service_home="$2"; join_service_home_explicit=1; shift 2 ;;
    --service-home=*) join_service_home="${1#*=}"; [ -n "$join_service_home" ] || die "--service-home needs a value"; join_service_home_explicit=1; shift ;;
	--version)
		need_value "$@"
		version="$2"
		shift 2
		;;
	--version=*)
		version="${1#*=}"
		shift
		;;
	--only)
		need_value "$@"
		only="$2"
		shift 2
		;;
	--only=*)
		only="${1#*=}"
		shift
		;;
	--setup)
		# A bare --setup keeps its earlier meaning: the default local setup.
		case "${2:-}" in
		local | connect | skip)
			setup_mode="$2"
			shift 2
			;;
		*)
			setup_mode=local
			shift
			;;
		esac
		;;
	--setup=*)
		setup_mode="${1#*=}"
		shift
		;;
	--no-setup)
		setup_mode=skip
		shift
		;;
	--service-url)
		need_value "$@"
		service_url="$2"
		shift 2
		;;
	--service-url=*)
		service_url="${1#*=}"
		shift
		;;
	--token-file)
		need_value "$@"
		token_file="$2"
		shift 2
		;;
	--token-file=*)
		token_file="${1#*=}"
		shift
		;;
	--agent-folder)
		need_value "$@"
		agent_folder="$2"
		shift 2
		;;
	--agent-folder=*)
		agent_folder="${1#*=}"
		shift
		;;
	--native-providers)
        need_value "$@"
        native_providers="$2"
        shift 2
        ;;
    --native-providers=*)
        native_providers="${1#*=}"
        [ -n "$native_providers" ] || die "--native-providers needs a value"
        shift
        ;;
	--agent-provider)
		need_value "$@"
		agent_provider="$2"
		shift 2
		;;
	--agent-provider=*)
		agent_provider="${1#*=}"
		shift
		;;
	--agent-model)
		need_value "$@"
		agent_model="$2"
		shift 2
		;;
	--agent-model=*)
		agent_model="${1#*=}"
		shift
		;;
	--agent-effort)
		need_value "$@"
		agent_effort="$2"
		shift 2
		;;
	--agent-effort=*)
		agent_effort="${1#*=}"
		shift
		;;
	--no-agent)
		no_agent=1
		shift
		;;
	--channels)
		need_value "$@"
		channels="$2"
		shift 2
		;;
	--channels=*)
		channels="${1#*=}"
		shift
		;;
	--yes | -y)
		yes=1
		shift
		;;
	--open)
		open=1
		shift
		;;
	--no-open)
		open=0
		shift
		;;
	--bin-dir)
		need_value "$@"
		bin_dir="$2"
		bin_dir_explicit=1
		shift 2
		;;
	--bin-dir=*)
		bin_dir="${1#*=}"
		bin_dir_explicit=1
		shift
		;;
	--no-path)
		add_path=0
		shift
		;;
	--from-dir)
		need_value "$@"
		from_dir="$2"
		shift 2
		;;
	--from-dir=*)
		from_dir="${1#*=}"
		shift
		;;
	-h | --help) usage 0 ;;
	*)
		say "unknown option $1"
		usage 2
		;;
	esac
done

if [ "$join_computer" = 1 ]; then
 [ -n "$join_trust" ] || die "--join needs --trust FINGERPRINT from the device that created the code"
 [ -z "$setup_mode" ] || die "--join is separate from --setup; omit --setup"
 [ -z "$token_file$agent_folder$agent_provider$agent_model$agent_effort$native_providers" ] || die "--join does not take token or agent setup flags; configure providers after joining"
 [ -z "$channels" ] || [ "$channels" = none ] || die "--join does not configure messaging channels"
 case "$only" in ""|catalex,service|service,catalex) ;; *) die "--join installs catalex and service only; omit --only";; esac
 for join_bound in "$join_wait_ms" "$join_probe_ms";do
  case "$join_bound" in ''|*[!0-9]*) die "join wait/probe bounds must be decimal milliseconds";; esac
  [ "$join_bound" -ge 1000 ] && [ "$join_bound" -le 600000 ] || die "join wait/probe bounds must be 1000 through 600000 ms"
 done
 join_wait_ms=$(printf '%s\n' "$join_wait_ms" | sed 's/^0*//')
 join_probe_ms=$(printf '%s\n' "$join_probe_ms" | sed 's/^0*//')
 [ "$join_probe_ms" -le "$join_wait_ms" ] || die "join probe timeout must not exceed its wait budget"
 only=catalex,service
 setup_mode=skip
 no_agent=1
 channels=none
 yes=1
 open=0
elif [ -n "$join_trust$join_file" ] || [ "$join_service_home_explicit" = 1 ]; then
 die "--trust, --join-file and --service-home require --join"
fi

case "$setup_mode" in
"" | local | connect | skip) ;;
*) die "--setup must be local, connect or skip" ;;
esac
case "$agent_provider" in
"" | claude | codex) ;;
*) die "--agent-provider must be claude or codex" ;;
esac
channel_list=""
case "$channels" in
"" | none) ;;
*)
	old_ifs="$IFS"
	IFS=,
	for name in $channels; do
		case "$name" in
		slack | whatsapp) channel_list="$channel_list $name" ;;
		*) die "--channels takes slack, whatsapp or none" ;;
		esac
	done
	IFS="$old_ifs"
	;;
esac

# Ask only in a terminal, and never with --yes. RELAY_INSTALL_FORCE_TTY is
# for the installer's own tests.
interactive=0
if [ "$yes" = 0 ] && { { [ -t 0 ] && [ -t 1 ]; } || [ "${RELAY_INSTALL_FORCE_TTY:-}" = 1 ]; }; then
	interactive=1
fi

# ask PROMPT DEFAULT reads one line into $answer; an empty line or end of
# input gives the default.
answer=""
ask() {
	printf '%s [%s]: ' "$1" "$2" >&2
	IFS= read -r answer || answer=""
	[ -n "$answer" ] || answer="$2"
}

# confirm PROMPT Y|N sets $answer to y or n.
confirm() {
	while :; do
		if [ "$2" = Y ]; then ask "$1 [Y/n]" Y; else ask "$1 [y/N]" N; fi
		case "$answer" in
		Y | y | yes | Yes | YES)
			answer=y
			return 0
			;;
		N | n | no | No | NO | s | skip)
			answer=n
			return 0
			;;
		esac
		say "Please answer y or n."
	done
}

# shell_word prints PATH ready to paste into a shell, single-quoted when it
# has any other character than these safe ones.
shell_word() {
	case "$1" in
	*[!A-Za-z0-9/._+:@%=,-]*) printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")" ;;
	*) printf '%s' "$1" ;;
	esac
}

# note TEXT remembers a skipped or unfinished step for the closing summary.
note() {
	skipped="$skipped
  - $*"
}

# read_secret PROMPT reads one line into $answer without echoing it. Echo is
# restored on every exit path (the EXIT trap covers errors and Ctrl-C); without
# a terminal there is nothing to hide.
read_secret() {
	printf '%s: ' "$1" >&2
	hidden=0
	# Traps first: a signal landing right after echo goes off must still restore
	# it, and a repeated signal must not cut the restore short.
	trap 'stty echo 2>/dev/null || true' EXIT
	trap 'trap "" INT TERM; exit 130' INT TERM
	if stty -echo 2>/dev/null; then
		hidden=1
	fi
	IFS= read -r answer || answer=""
	if [ "$hidden" = 1 ]; then
		stty echo 2>/dev/null || true
	fi
	trap - EXIT INT TERM
	printf '\n' >&2
}

# signed_in PROVIDER succeeds when its read-only status command does; the
# installer never signs in.
signed_in() {
	if [ "$1" = claude ]; then
		claude auth status >/dev/null 2>&1
	else
		codex login status >/dev/null 2>&1
	fi
}

# signin_note PROVIDER records how to sign in when the provider is not.
signin_note() {
	command -v "$1" >/dev/null 2>&1 || return 0
	signed_in "$1" && return 0
	if [ "$1" = claude ]; then signin="claude auth login"; else signin="codex login"; fi
	note "Sign in to $1 (the CatalEx app's Settings -> Providers shows its state):
      $signin"
}

# provider_status NAME prints one informational line about a provider.
provider_status() {
	if ! command -v "$1" >/dev/null 2>&1; then
		say "  $1: not found"
		return 0
	fi
	pversion="$("$1" --version 2>/dev/null | head -n 1)" || pversion=""
	if signed_in "$1"; then
		say "  $1: ${pversion:-unknown version}, signed in"
	elif [ "$1" = claude ]; then
		say "  $1: ${pversion:-unknown version}, not signed in; to sign in, run: claude auth login"
	else
		say "  $1: ${pversion:-unknown version}, not signed in; to sign in, run: codex login"
	fi
}

# expand_home turns a leading ~ into $HOME.
expand_home() {
	# shellcheck disable=SC2088
	case "$1" in
	"~") printf '%s\n' "$HOME" ;;
	"~/"*) printf '%s\n' "$HOME/${1#"~/"}" ;;
	*) printf '%s\n' "$1" ;;
	esac
}

# The PATH block is shared with the CatalEx desktop app
# (the app's profile code): each finds the other's block by its
# start marker and never adds a second. Keep the markers and lines identical.
PROFILE_BLOCK_START="# >>> CatalEx command-line tools >>>"
PROFILE_BLOCK_END="# <<< CatalEx command-line tools <<<"
PROFILE_CREATION_LINE="# CatalEx created this profile file"
# PROFILE_FISH_CONFIG is the file under $HOME that fish reads at every start.
PROFILE_FISH_CONFIG=".config/fish/conf.d/catalex.fish"
# PROFILE_FILE_MODE is the mode of a profile file the installer creates; an
# existing file keeps its own.
PROFILE_FILE_MODE=644

# home_path prints FILE under $HOME as $HOME/…, else FILE itself.
home_path() {
	# shellcheck disable=SC2016 # $HOME is written for the shell to expand.
	case "$1" in
	"$HOME"/?*) printf '$HOME/%s\n' "${1#"$HOME"/}" ;;
	*) printf '%s\n' "$1" ;;
	esac
}

# shown_path prints FILE under $HOME as ~/… for messages.
shown_path() {
	# shellcheck disable=SC2088
	case "$1" in
	"$HOME"/?*) printf '~/%s\n' "${1#"$HOME"/}" ;;
	*) printf '%s\n' "$1" ;;
	esac
}

# login_shell prints zsh, bash or fish for $SHELL, or nothing for any other
# or an unset one.
login_shell() {
	login="${SHELL:-}"
	case "${login##*/}" in
	zsh | bash | fish) printf '%s\n' "${login##*/}" ;;
	esac
}

# profile_file SHELL prints the file SHELL reads at login. A bash login shell
# reads only the first of these that exists, so that one; .bash_profile when
# none does.
profile_file() {
	case "$1" in
	zsh) printf '%s\n' "$HOME/.zprofile" ;;
	fish) printf '%s\n' "$HOME/$PROFILE_FISH_CONFIG" ;;
	bash)
		for name in .bash_profile .bash_login .profile; do
			if [ -e "$HOME/$name" ]; then
				printf '%s\n' "$HOME/$name"
				return 0
			fi
		done
		printf '%s\n' "$HOME/.bash_profile"
		;;
	esac
}

# path_line SHELL prints the one line that puts $bin_dir first on PATH.
path_line() {
	if [ "$1" = fish ]; then
		printf 'fish_add_path --global --prepend "%s"\n' "$(home_path "$bin_dir")"
	else
		# shellcheck disable=SC2016 # $PATH is written for the shell to expand.
		printf 'export PATH="%s:$PATH"\n' "$(home_path "$bin_dir")"
	fi
}

# adds_dir FILE succeeds when FILE already has the marked block, or a line
# that is not a comment and names $bin_dir (as $HOME/…, ${HOME}/…, ~/… or its
# absolute path) together with PATH, zsh's path array or fish_add_path. It
# only reads the file.
adds_dir() {
	[ -f "$1" ] || return 1
	grep -qF "$PROFILE_BLOCK_START" "$1" && return 0
	rel=""
	case "$bin_dir" in
	"$HOME"/?*) rel="${bin_dir#"$HOME"/}" ;;
	esac
	RELAY_DIR="$bin_dir" RELAY_REL="$rel" awk '
		BEGIN {
			names[ENVIRON["RELAY_DIR"]] = 1
			r = ENVIRON["RELAY_REL"]
			if (r != "") { names["$HOME/" r] = 1; names["${HOME}/" r] = 1; names["~/" r] = 1 }
		}
		{
			line = $0; sub(/^[ \t]+/, "", line)
			if (line == "" || substr(line, 1, 1) == "#") next
			if (line !~ /(^|[^A-Za-z0-9_])PATH([^A-Za-z0-9_]|$)/ && line !~ /(^|[^A-Za-z0-9_])path=/ && line !~ /fish_add_path/) next
			n = split(line, parts, /[ \t:"'"'"'=()]+/)
			for (i = 1; i <= n; i++) { p = parts[i]; sub(/\/+$/, "", p); if (p in names) { found = 1; exit } }
		}
		END { exit found ? 0 : 1 }' "$1"
}

# stat's flags follow its implementation, not the OS: macOS can have GNU
# coreutils first on PATH, so probe GNU -c once and fall back to BSD -f.
if stat -c %i / >/dev/null 2>&1; then stat_gnu=1; else stat_gnu=0; fi

# profile_identity captures identity, permissions and metadata without following a leaf link.
profile_identity() {
	if [ "$stat_gnu" = 1 ]; then stat -c '%d:%i:%f:%u:%g:%s:%Y' "$1"; else stat -f '%d:%i:%p:%u:%g:%z:%m' "$1"; fi
}

# Private ten-line receipt shared with the Local and desktop PATH writers.
PROFILE_JOURNAL_PREFIX=.catalex-profile-
PROFILE_INTENT_VERSION=catalex-profile-v1
profile_inode() {
	if [ "$stat_gnu" = 1 ]; then stat -c '%d:%i' "$1"; else stat -f '%d:%i' "$1"; fi
}
profile_mode() {
	if [ "$stat_gnu" = 1 ]; then stat -c '%a' "$1"; else stat -f '%Lp' "$1"; fi
}
profile_uid() {
	if [ "$stat_gnu" = 1 ]; then stat -c '%u' "$1"; else stat -f '%u' "$1"; fi
}
profile_private_file() {
	[ -f "$1" ] && [ ! -L "$1" ] && [ "$(profile_mode "$1")" = 600 ] && [ "$(profile_uid "$1")" = "$(id -u)" ]
}
# Resolves a linked profile even when its final regular target is absent.
profile_target() {
	profile_candidate=$1
	profile_seen='|'
	while [ -L "$profile_candidate" ]; do
		profile_link_id=$(profile_inode "$profile_candidate") || return 1
		case "$profile_seen" in *"|$profile_link_id|"*) return 1 ;; esac
		profile_seen="$profile_seen$profile_link_id|"
		profile_dest=$(readlink "$profile_candidate") || return 1
		case "$profile_dest" in /*) profile_candidate=$profile_dest ;; *) profile_candidate="$(dirname "$profile_candidate")/$profile_dest" ;; esac
	done
	profile_parent=$(cd -P "$(dirname "$profile_candidate")" && pwd -P) || return 1
	printf '%s/%s\n' "$profile_parent" "$(basename "$profile_candidate")"
}

# A closed receipt survives process interruption. POSIX shell does not claim
# per-file power-loss durability; Go and desktop additionally fsync receipts.
profile_prepare_intent() {
	profile_receipt_leaf=absent
	profile_receipt_original=-
	profile_receipt_mode=-
	if [ -n "$profile_id" ]; then
		profile_receipt_leaf=direct
		[ -z "$profile_leaf" ] || profile_receipt_leaf="link:$(profile_inode "$profile_file_path")"
		profile_receipt_original=$(profile_inode "$profile_real") || return 1
		profile_receipt_mode=$(profile_mode "$profile_real") || return 1
	fi
	chmod 600 "$profile_original" || return 1
	profile_staged_id=$(profile_inode "$profile_staged") || return 1
	(umask 077; printf '%s\n' "$PROFILE_INTENT_VERSION" "$$" "$profile_file_path" "$profile_real" "$profile_receipt_leaf" "$profile_receipt_original" "$profile_receipt_mode" write "$profile_staged_id" "$(basename "$profile_work")" >"$profile_work/intent") || return 1
	chmod 600 "$profile_work/intent" || return 1
	profile_active_work=$profile_work
}
# Only positive publication or exclusive restoration authorizes cleanup.
profile_recover() {
	recovery_logical=$1
	case "$recovery_logical" in *'
'* | *"$(printf '\r')"*) return 1 ;; esac
	[ -d "$(dirname "$recovery_logical")" ] || return 0
	recovery_target=$(profile_target "$recovery_logical") || return 1
	for recovery_dir in "$(dirname "$recovery_target")"/"$PROFILE_JOURNAL_PREFIX"*; do
		[ -d "$recovery_dir" ] && [ ! -L "$recovery_dir" ] || continue
		[ -e "$recovery_dir/intent" ] || [ -L "$recovery_dir/intent" ] || continue
		[ "$(profile_mode "$recovery_dir")" = 700 ] && [ "$(profile_uid "$recovery_dir")" = "$(id -u)" ] && profile_private_file "$recovery_dir/intent" || return 1
		[ "$(wc -l <"$recovery_dir/intent" | tr -d ' ')" = 10 ] || return 1
		recovery_nonce=$(sed -n '10p' "$recovery_dir/intent")
		[ "$recovery_nonce" = "$(basename "$recovery_dir")" ] || return 1
		recovery_version=$(sed -n '1p' "$recovery_dir/intent")
		[ "$recovery_version" = "$PROFILE_INTENT_VERSION" ] || return 1
		recovery_profile=$(sed -n '3p' "$recovery_dir/intent")
		[ "$recovery_profile" = "$recovery_logical" ] || continue
		recovery_pid=$(sed -n '2p' "$recovery_dir/intent")
		case "$recovery_pid" in '' | *[!0-9]* | 0) return 1 ;; esac
		recovery_saved_target=$(sed -n '4p' "$recovery_dir/intent")
		[ "$recovery_saved_target" = "$recovery_target" ] || return 1
		recovery_leaf=$(sed -n '5p' "$recovery_dir/intent")
		recovery_original_id=$(sed -n '6p' "$recovery_dir/intent")
		recovery_original_mode=$(sed -n '7p' "$recovery_dir/intent")
		recovery_operation=$(sed -n '8p' "$recovery_dir/intent")
		recovery_staged_id=$(sed -n '9p' "$recovery_dir/intent")
		case "$recovery_operation" in write | remove) ;; *) return 1 ;; esac
		case "$recovery_leaf" in
			direct | absent) ;;
			link:*) [ -L "$recovery_logical" ] && [ "$recovery_leaf" = "link:$(profile_inode "$recovery_logical")" ] || return 1 ;;
			*) return 1 ;;
		esac
		if [ "$recovery_pid" = "$$" ]; then
			[ "${profile_active_work:-}" != "$recovery_dir" ] || return 1
		elif [ -n "$(ps -p "$recovery_pid" -o pid= 2>/dev/null)" ]; then
			return 1
		fi
		recovery_captured="$recovery_dir/captured"
		recovery_published=0
		if [ "$recovery_operation" = write ] && [ -f "$recovery_target" ] && [ ! -L "$recovery_target" ] && [ -f "$recovery_dir/new" ] && [ ! -L "$recovery_dir/new" ] && [ "$(profile_inode "$recovery_target")" = "$recovery_staged_id" ] && [ "$(profile_inode "$recovery_dir/new")" = "$recovery_staged_id" ]; then recovery_published=1; fi
		if [ -e "$recovery_captured" ] || [ -L "$recovery_captured" ]; then
   if [ ! -f "$recovery_captured" ] || [ -L "$recovery_captured" ] || ! profile_private_file "$recovery_dir/original" || [ "$(profile_inode "$recovery_captured")" != "$recovery_original_id" ] || [ "$(profile_mode "$recovery_captured")" != "$recovery_original_mode" ] || ! cmp -s "$recovery_captured" "$recovery_dir/original"; then
    say "Profile changed; retained captured profile and original snapshot at $recovery_dir. Preserve both before retrying."
    return 1
   fi
			if [ ! -e "$recovery_target" ] && [ ! -L "$recovery_target" ]; then
				link "$recovery_captured" "$recovery_target" 2>/dev/null || return 1
				rm -rf "$recovery_dir" || return 1
				say "Interrupted profile edit restored; check the profile and retry PATH management."
				return 2
			fi
			if [ "$(profile_inode "$recovery_target")" = "$(profile_inode "$recovery_captured")" ]; then
				rm -rf "$recovery_dir" || return 1
				say "Interrupted profile edit restored; check the profile and retry PATH management."
				return 2
			fi
			if [ "$recovery_published" = 1 ]; then
				rm -rf "$recovery_dir" || return 1
				continue
			fi
			say "Profile changed; retained captured profile at $recovery_captured. Finish the other edit before retrying."
			return 1
		fi
		recovery_completed=0
		if profile_private_file "$recovery_dir/completed" && [ "$(cat "$recovery_dir/completed")" = "$PROFILE_INTENT_VERSION" ]; then recovery_completed=1; fi
		if [ "$recovery_published" = 1 ] || [ "$recovery_completed" = 1 ] || [ "$recovery_leaf" = absent ]; then rm -rf "$recovery_dir" || return 1; continue; fi
		if [ -f "$recovery_target" ] && [ ! -L "$recovery_target" ] && [ "$(profile_inode "$recovery_target")" = "$recovery_original_id" ]; then rm -rf "$recovery_dir" || return 1; continue; fi
		say "Profile changed; preserve recovery directory $recovery_dir."
		return 1
	done
	return 0
}

# restore_profile preserves the actual moved file without overwriting a newcomer.
restore_profile() {
	if link "$profile_moved" "$profile_real" 2>/dev/null; then
		rm -rf "$profile_work"
	else
		say "Profile changed; preserved the captured file at $profile_moved. Finish the other edit before retrying."
	fi
	profile_active_work=""
	return 1
}

# write_block SHELL FILE binds publication to the captured file, not its filename.
write_block() {
	command -v link >/dev/null 2>&1 || return 1
	profile_recover "$2" || return 1
	profile_file_path="$2"
	profile_real="$2"
	profile_leaf=""
	if [ -L "$2" ]; then
		command -v readlink >/dev/null 2>&1 || return 1
		profile_leaf="$(profile_identity "$2")" || return 1
		profile_real="$(profile_target "$2")" || return 1
	fi
	if [ -e "$profile_real" ] && [ ! -f "$profile_real" ]; then return 1; fi
	mkdir -p "$(dirname "$profile_real")" || return 1
	profile_real="$(profile_target "$profile_real")" || return 1
	profile_work="$(umask 077 && mktemp -d "$(dirname "$profile_real")/$PROFILE_JOURNAL_PREFIX"XXXXXX)" || return 1
	profile_staged="$profile_work/new"
	profile_original="$profile_work/original"
	profile_id=""
	profile_created=0
	profile_active_work=""
	if [ -e "$profile_real" ]; then
		profile_id="$(profile_identity "$profile_real")" || { rm -rf "$profile_work"; return 1; }
		cp -pP "$profile_real" "$profile_original" || { rm -rf "$profile_work"; return 1; }
		if [ "$profile_id" != "$(profile_identity "$profile_real")" ] || ! cmp -s "$profile_real" "$profile_original"; then rm -rf "$profile_work"; return 1; fi
		cp -p "$profile_original" "$profile_staged" || { rm -rf "$profile_work"; return 1; }
	else
		[ ! -L "$profile_real" ] || { rm -rf "$profile_work"; return 1; }
		profile_created=1
		(umask 077; : >"$profile_original") || { rm -rf "$profile_work"; return 1; }
		if ! (umask 077 && : >"$profile_staged") || ! chmod "$PROFILE_FILE_MODE" "$profile_staged"; then rm -rf "$profile_work"; return 1; fi
	fi
	# No blank separator: removal keeps every byte outside the block, so adding
	# then removing the block restores a newline-terminated profile exactly.
	separator=""
	if [ -s "$profile_staged" ]; then
		[ -z "$(tail -c 1 "$profile_staged")" ] || separator='\n'
	fi
	{
		# shellcheck disable=SC2059 # separator holds only newline escapes.
		printf "$separator"
		printf '%s\n' "$PROFILE_BLOCK_START"
		[ "$profile_created" = 0 ] || printf '%s\n' "$PROFILE_CREATION_LINE"
		printf '%s\n' "# Added by the CatalEx installer so Terminal finds the catalex command."
		path_line "$1"
		printf '%s\n' "$PROFILE_BLOCK_END"
	} >>"$profile_staged" || { rm -rf "$profile_work"; return 1; }
	profile_prepare_intent || { rm -rf "$profile_work"; return 1; }
	if [ -z "$profile_id" ]; then
		link "$profile_staged" "$profile_real" 2>/dev/null || { rm -rf "$profile_work"; return 1; }
		rm -rf "$profile_work"
		profile_active_work=""
		return 0
	fi
	if [ -n "$profile_leaf" ] && [ "$profile_leaf" != "$(profile_identity "$profile_file_path")" ]; then rm -rf "$profile_work"; return 1; fi
	profile_moved="$profile_work/captured"
	mv "$profile_real" "$profile_moved" || { profile_active_work=""; return 1; }
	if [ "$profile_id" != "$(profile_identity "$profile_moved")" ] || ! cmp -s "$profile_moved" "$profile_original"; then restore_profile; return 1; fi
	if [ -n "$profile_leaf" ] && [ "$profile_leaf" != "$(profile_identity "$profile_file_path")" ]; then restore_profile; return 1; fi
	link "$profile_staged" "$profile_real" 2>/dev/null || { restore_profile; return 1; }
	if [ "$profile_id" != "$(profile_identity "$profile_moved")" ] || ! cmp -s "$profile_moved" "$profile_original"; then profile_active_work=""; say "Profile changed; retained captured profile at $profile_moved."; return 1; fi
	if ! (umask 077; printf '%s\n' "$PROFILE_INTENT_VERSION" >"$profile_work/completed") || ! chmod 600 "$profile_work/completed"; then profile_active_work=""; return 1; fi
	rm -rf "$profile_work"
	profile_active_work=""
}

# add_to_path puts $bin_dir on the login shell's PATH for new terminals and
# prints one line saying what it did; only when it cannot does it print the
# line to add by hand.
add_to_path() {
	already_in_path=0
	case ":$PATH:" in
	*":$bin_dir:"*) already_in_path=1 ;;
	esac
	shown_bin="$(shown_path "$bin_dir")"
	if [ "$add_path" = 0 ]; then
		[ "$already_in_path" = 0 ] || return 0
		say "$shown_bin is not on PATH and --no-path left it so; run the commands by their full path."
		return 0
	fi
	shell="$(login_shell)"
	if [ -z "$shell" ]; then
		[ "$already_in_path" = 0 ] || return 0
		say "Could not add $shown_bin to PATH: the installer does not know how your shell (${SHELL:-unknown}) sets PATH. Add this line to its startup file:"
		say "  export PATH=\"$bin_dir:\$PATH\""
		return 0
	fi
	if [ "$shell" = bash ]; then
		for candidate in .bash_profile .bash_login .profile; do
			if ! profile_recover "$HOME/$candidate"; then
				say "Preserve the Bash profile and its recovery files; check the profile and retry PATH management."
				return 0
			fi
		done
	fi
	file="$(profile_file "$shell")"
	shown_file="$(shown_path "$file")"
	case "$bin_dir" in
	*'$'* | *'`'*)
		say "Could not add $shown_bin to PATH: its name has a dollar sign or a backtick. Add it to $shown_file yourself."
		return 0
		;;
	esac
	if ! profile_recover "$file"; then
		say "Could not add $shown_bin to PATH: preserve the profile and its recovery files; finish the other edit and retry PATH management."
		return 0
	fi
	[ "$already_in_path" = 0 ] || return 0
	if adds_dir "$file"; then
		say "$shown_file already adds $shown_bin to PATH; a new terminal finds the commands."
		return 0
	fi
	if write_block "$shell" "$file"; then
		say "Added $shown_bin to PATH in $shown_file; a new terminal finds the commands."
		return 0
	fi
	say "Could not change $shown_file. To run the commands by name, add this line to it yourself:"
	say "  $(path_line "$shell")"
}

case "$(uname -s)" in
Darwin) os=darwin ;;
Linux) os=linux ;;
*) die "unsupported operating system $(uname -s)" ;;
esac
case "$(uname -m)" in
arm64 | aarch64) arch=arm64 ;;
x86_64 | amd64) arch=amd64 ;;
*) die "unsupported architecture $(uname -m)" ;;
esac

# Headless Linux installs use the verified Linux runtime payload.
# The default parts of an ordinary installation; a computer joins with --join.
runtime_platform=0
case "$os/$arch" in darwin/arm64|linux/amd64|linux/arm64) runtime_platform=1;; esac
default_local_platform=0
[ "$os/$arch" = darwin/arm64 ] && default_local_platform=1
if [ -z "$only" ]; then
	only="catalex,service,web"
	if [ "$default_local_platform" = 0 ]; then
		only="catalex,web"
		say "Installing the catalex client and the CatalEx web app by default for
$os/$arch; use --join or --only service to run agents on supported Linux
computers."
	fi
	if [ "$interactive" = 1 ]; then
		say ""
		say "Step 1: parts to install."
		say "  catalex     the command"
		say "  service     runs your agents (always brings catalex)"
		say "  web         the CatalEx web app"
		ask "Parts to install" "$only"
		[ "$answer" != all ] || answer="$only"
		only="$answer"
	fi
fi

service=0
web=0
client=0
old_ifs="$IFS"
IFS=,
for name in $only; do
	case "$name" in
	service) service=1 ;;
	web) web=1 ;;
	catalex) client=1 ;;
	*) die "unknown --only part ${name:-''}
       choose from catalex, service, web" ;;
	esac
done
IFS="$old_ifs"
[ $((client + service + web)) -gt 0 ] || die "--only selects nothing to install"
# Setup runs catalex commands (accounts, agents, open), so the service brings the client.
[ "$service" = 0 ] || client=1
if [ "$service" = 1 ] && [ "$runtime_platform" = 0 ]; then
	die "CatalEx cannot run agents on $os/$arch yet;
       install with --only web"
fi

# A root installer never writes a binary through a directory another OS user
# can replace. A sticky temporary ancestor is allowed only above a protected
# root-owned child, matching server-mode home ownership constraints.
join_system_directory() {
 join_check_dir=$1
 join_protected=0
 while :;do
  [ ! -L "$join_check_dir" ] || die "system installation directories must not be symlinks"
  if [ -e "$join_check_dir" ] && [ ! -d "$join_check_dir" ];then die "system installation path is not a directory";fi
  if [ -d "$join_check_dir" ];then
   # shellcheck disable=SC2012 # Numeric ownership and fixed mode fields only.
   join_info=$(LC_ALL=C ls -ldn "$join_check_dir") || die "system installation directory cannot be inspected"
   join_mode=$(printf '%s\n' "$join_info" | awk '{print $1}')
   join_uid=$(printf '%s\n' "$join_info" | awk '{print $3}')
   [ "$join_uid" = 0 ] || die "system installation directories must be root-owned"
   [ "$(printf '%s' "$join_mode" | cut -c10)" = x ] || [ "$(printf '%s' "$join_mode" | cut -c10)" = t ] || die "system installation directories must be searchable"
   case "$(printf '%s' "$join_mode" | cut -c6,9)" in
    *w*) [ "$join_protected" = 1 ] && [ "$(printf '%s' "$join_mode" | cut -c10)" = t ] || die "system installation directories must not be group/world-writable";;
   esac
   join_protected=1
  fi
  [ "$join_check_dir" != / ] || break
  join_check_dir=$(dirname "$join_check_dir")
 done
}

join_system=0
if [ "$join_computer" = 1 ]; then
 [ "$os" = linux ] || die "--join installation needs Linux with systemd; on macOS start CatalEx in the app, then run catalex join"
 if [ "$(id -u)" = 0 ]; then
  join_system=1
  [ "$bin_dir_explicit" = 1 ] || bin_dir=/usr/local/bin
  case "$bin_dir" in /*) ;; *) die "--bin-dir must be an absolute path";; esac
  prefix="$(dirname "$bin_dir")/share/catalex-relay"
  private_dir="$prefix/libexec"
  join_system_directory "$bin_dir"
  join_system_directory "$prefix"
  for join_tool in systemctl runuser;do command -v "$join_tool" >/dev/null 2>&1 || die "$join_tool is required for a Linux system service";done
 elif [ "$join_service_home_explicit" = 1 ];then
  die "--service-home needs root; omit it for a per-user service"
 fi
 case "$join_service_home" in /*) ;; *) die "--service-home must be absolute";; esac
fi

case "$bin_dir" in
/*) ;;
*) die "--bin-dir must be an absolute path" ;;
esac
case "$bin_dir$prefix$skill_dir$join_service_home" in
*\"* | *\\*) die "install paths must not contain quotes or backslashes" ;;
esac

if [ "$join_computer" = 1 ];then
 join_existing_membership
 join_validate_input
fi

# A standalone client installs without configuring anything.
if [ "$service" = 0 ] && [ "$web" = 0 ] && [ -z "$setup_mode" ]; then
	setup_mode=skip
fi

# Step 2: how to set CatalEx up. Skipped when a flag answered it.
if [ -z "$setup_mode" ]; then
	setup_mode=local
	if [ "$interactive" = 1 ]; then
		say ""
		say "Step 2: setup."
		say "  1) On this computer (default)"
		if [ "$service" = 1 ]; then
			say "  2) Connect to a CatalEx service"
		fi
		say "  3) Skip; set CatalEx up later with catalex setup"
		while :; do
			ask "Choose" 1
			case "$answer" in
			1 | local)
				setup_mode=local
				break
				;;
			2 | connect)
				if [ "$service" = 1 ]; then
					setup_mode=connect
					break
				fi
				;;
			3 | s | skip)
				setup_mode=skip
				break
				;;
			esac
			say "Please choose one of the listed numbers."
		done
	fi
fi
if [ "$setup_mode" = connect ] && [ "$service" = 0 ]; then
	die "--setup connect needs the service part"
fi
if [ "$setup_mode" = connect ]; then
	if [ -z "$service_url" ] && [ "$interactive" = 1 ]; then
		ask "CatalEx service URL" ""
		service_url="$answer"
	fi
	[ -n "$service_url" ] || die "--setup connect needs --service-url"
	case "$service_url" in
	http://* | https://* | ws://* | wss://*) ;;
	*) die "--service-url must start with http://, https://, ws:// or wss://" ;;
	esac
	if [ -z "$token_file" ]; then
		[ "$interactive" = 1 ] || die "--setup connect needs --token-file"
		read_secret "Connector token (not shown)"
		[ -n "$answer" ] || die "a connector token is required to connect"
		connect_token="$answer"
	else
		token_file="$(expand_home "$token_file")"
		[ -f "$token_file" ] && [ -r "$token_file" ] || die "--token-file $token_file is not a readable file"
		case "$token_file" in
		/*) ;;
		*) die "--token-file must be an absolute path" ;;
		esac
		# ls -l prints the group and other bits in columns 5 to 10; stat differs
		# between macOS and Linux.
		# shellcheck disable=SC2012
		[ "$(ls -ld "$token_file" | cut -c5-10)" = "------" ] ||
			die "--token-file $token_file is readable by other users; run chmod 600 on it and retry"
	fi
fi
connect_token="${connect_token:-}"

# Step 3: Claude Code and Codex. Read-only; the installer never signs in.
if [ "$interactive" = 1 ] && [ "$service" = 1 ] && [ "$setup_mode" != skip ]; then
	say ""
	say "Step 3: AI providers (shown for information; nothing is signed in for you)."
    shown_providers="$native_providers"
    [ -n "$shown_providers" ] || shown_providers="$agent_provider"
    case ",$shown_providers," in ,,|*,claude,*) provider_status claude || true ;; esac
    case ",$shown_providers," in ,,|*,codex,*) provider_status codex || true ;; esac
fi

# Step 4: messaging channels. Slack and WhatsApp run through a CatalEx
# service, so they are offered only when the setup connects to one.
channels_ok=0
if [ "$service" = 1 ] && [ "$setup_mode" = connect ]; then
	channels_ok=1
fi
if [ -n "$channel_list" ] && [ "$channels_ok" = 0 ]; then
	die "--channels needs the service part and --setup connect"
fi
if [ -z "$channels" ] && [ "$interactive" = 1 ] && [ "$service" = 1 ] && [ "$setup_mode" != skip ]; then
	say ""
	say "Step 4: messaging channels."
	if [ "$channels_ok" = 0 ]; then
		say "  Slack and WhatsApp need a connection to a CatalEx service;"
		say "  add them later in the CatalEx app's Settings."
	else
		confirm "Add Slack/WhatsApp channels now" N
		if [ "$answer" = y ]; then
			while :; do
				ask "Platforms (slack, whatsapp)" "slack,whatsapp"
				channel_list=""
				valid=1
				old_ifs="$IFS"
				IFS=,
				for name in $answer; do
					case "$name" in
					slack | whatsapp) channel_list="$channel_list $name" ;;
					*) valid=0 ;;
					esac
				done
				IFS="$old_ifs"
				[ "$valid" = 1 ] && [ -n "$channel_list" ] && break
				say "Please list slack, whatsapp or both."
			done
		fi
	fi
fi
slack_name=Slack
whatsapp_name=WhatsApp
case "$channel_list" in
*slack*) [ "$interactive" = 0 ] || { ask "Slack workspace name" Slack; slack_name="$answer"; } ;;
esac
case "$channel_list" in
*whatsapp*) [ "$interactive" = 0 ] || { ask "WhatsApp phone number name" WhatsApp; whatsapp_name="$answer"; } ;;
esac
if [ -z "$channel_list" ] && [ "$channels_ok" = 1 ]; then
	note "Messaging channels (Slack, WhatsApp): add them in the CatalEx
      app's Settings -> Channels."
fi

# Step 5: the first agent. Without a terminal an agent is created only when
# a flag names its folder: an agent can work in every file of its folder.
if [ "$no_agent" = 1 ] && { [ -n "$agent_folder" ] || [ -n "$agent_provider" ] || [ -n "$agent_model" ] || [ -n "$agent_effort" ]; }; then
	die "--no-agent conflicts with the other --agent-* options"
fi
want_agent=0
if [ -n "$agent_folder" ] || [ -n "$agent_provider" ] || [ -n "$agent_model" ] || [ -n "$agent_effort" ]; then
	want_agent=1
elif [ "$no_agent" = 0 ] && [ "$interactive" = 1 ] && [ "$service" = 1 ] && [ "$setup_mode" != skip ]; then
	say ""
	say "Step 5: first agent (a folder with Claude Code or Codex working in it)."
	confirm "Create a first agent" Y
	[ "$answer" = y ] && want_agent=1
fi
if [ "$want_agent" = 1 ]; then
	[ "$service" = 1 ] && [ "$setup_mode" != skip ] || die "a first agent needs the service part and a setup
       (not --setup skip)"
	if [ -z "$agent_folder" ]; then
		[ "$interactive" = 1 ] || die "--agent-folder is required to create an agent without prompts"
		while :; do
			ask "Folder the agent works in" "$PWD"
			agent_folder="$(expand_home "$answer")"
			case "$agent_folder" in
			/*) [ ! -d "$agent_folder" ] || break ;;
			esac
			say "Please give an existing folder (an absolute path, or one starting with ~)."
		done
	fi
	agent_folder="$(expand_home "$agent_folder")"
	case "$agent_folder" in
	/*) ;;
	*) die "--agent-folder must be an absolute path" ;;
	esac
	[ -d "$agent_folder" ] || die "--agent-folder $agent_folder is not an existing folder"
	if [ -z "$agent_provider" ]; then
		detected=""
		if command -v claude >/dev/null 2>&1; then
			detected=claude
		elif command -v codex >/dev/null 2>&1; then
			detected=codex
		fi
		if [ "$interactive" = 1 ] && [ -n "$detected" ]; then
			while :; do
				ask "Provider (claude or codex)" "$detected"
				case "$answer" in
				claude | codex)
					if command -v "$answer" >/dev/null 2>&1; then
						agent_provider="$answer"
						break
					fi
					say "$answer was not found on PATH; install it or choose the other."
					continue
					;;
				esac
				say "Please answer claude or codex."
			done
		else
			agent_provider="$detected"
		fi
	fi
	if [ -n "$agent_provider" ] && ! command -v "$agent_provider" >/dev/null 2>&1; then
		die "$agent_provider was not found on PATH; install it or choose the other provider"
	fi
	if [ -z "$agent_provider" ] && { [ -n "$agent_model" ] || [ -n "$agent_effort" ]; }; then
		die "--agent-model and --agent-effort need --agent-provider"
	fi
	if [ "$interactive" = 1 ] && [ -n "$agent_provider" ]; then
		if [ -z "$agent_model" ]; then
			ask "Model (empty for the provider's default)" ""
			agent_model="$answer"
		fi
		if [ -z "$agent_effort" ]; then
			ask "Effort (empty for the model's default)" ""
			agent_effort="$answer"
		fi
	fi
	[ -z "$agent_provider" ] || signin_note "$agent_provider"
fi

# Step 5: open CatalEx. It defaults to opening only after a setup.
open_default=1
[ "$setup_mode" = skip ] && open_default=0
# The web app opens in the CatalEx app, which is for macOS only.
if [ "$os" != darwin ]; then
	[ "$open" != 1 ] || die "--open needs the CatalEx app, which is for macOS; omit --open"
	open_default=0
fi
if [ -z "$open" ]; then
	open="$open_default"
	if [ "$interactive" = 1 ] && [ "$web" = 1 ] && [ "$os" = darwin ]; then
		say ""
		say "Step 6: the CatalEx app."
		if [ "$open_default" = 1 ]; then confirm "Open the CatalEx app when done" Y; else confirm "Open the CatalEx app when done" N; fi
		open=0
		[ "$answer" = y ] && open=1
	fi
fi
# local_mode is the setup on this computer: native chats only.
local_mode=native_chat
setup=1
[ "$setup_mode" = skip ] && setup=0

for command in curl tar awk sed; do
	command -v "$command" >/dev/null 2>&1 || die "$command is required; install it and retry"
done

sha256() {
	if command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{print $1}'
	else
		sha256sum "$1" | awk '{print $1}'
	fi
}

# How to reach the release: a local folder, gh, a token, or anonymously.
token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -n "$from_dir" ]; then
	source=local
	[ -f "$from_dir/tree/latest.json" ] || die "--from-dir $from_dir has no tree/latest.json"
elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
	source=gh
elif [ -n "$token" ]; then
	source=token
else
	source=anonymous
fi

# The installation prefix records who owns it, so another folder is never taken over.
marker="$prefix/.relay-install-owned"
if [ -n "$(ls -A "$prefix" 2>/dev/null)" ] && { [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$OWNER" ]; }; then
	die "installation prefix is not CatalEx-owned: $prefix; choose an empty prefix or move it"
fi

record="$prefix/installation.json"
previous() {
	[ -f "$record" ] || return 0
	sed -n "s/^ *\"$1\": *\"\\([^\"]*\\)\".*/\\1/p" "$record" | head -n 1
}

# Replacing commands under a running CatalEx would mix releases; stop it first.
# A component (an object with id, label, url and state, in the status's compact JSON) is live only
# while starting or ready. Other states, such as a connect-mode service's "disconnected", and
# destination or operation states, do not mean a running process. Strings are matched whole, so ']'
# or escaped quotes in text do not confuse the match.
live_component='"id":"([^"\\]|\\.)*","label":"([^"\\]|\\.)*","url":"([^"\\]|\\.)*","state":"(starting|ready)"'
installed_relay="$(previous binary_path)"
[ -n "$installed_relay" ] || installed_relay="$bin_dir/relay"
if [ "$join_computer" = 0 ] && [ $((service + web)) -gt 0 ] && [ -x "$installed_relay" ] && controller_status="$("$installed_relay" controller status 2>/dev/null)"; then
	printf '%s\n' "$controller_status" | grep -Eq "$live_component" && die "CatalEx is running; stop it with catalex stop --all, then rerun the installer"
	printf '%s\n' "$controller_status" | grep -q '"health":{' && { "$installed_relay" controller shutdown >/dev/null 2>&1 || die "CatalEx's management service did not stop; stop it with catalex stop --all, then rerun the installer"; }
fi
# A saved setup needs neither the command to set CatalEx up later nor the first-agent hint.
if ! printf '%s\n' "${controller_status:-}" | grep -q '"configured":true'; then
	[ "$setup" = 0 ] && [ "$service" = 1 ] && [ "$join_computer" = 0 ] && note "CatalEx setup: skipped. Later, run these in a terminal (or use the CatalEx app's \"Set Up CatalEx…\", no terminal needed):
      $(shell_word "$bin_dir/catalex") setup --mode $local_mode --start"
	[ "$want_agent" = 1 ] || [ "$service" = 0 ] || note "First agent: not created; add one in the CatalEx app's Agents page,
      or in a terminal:
      $(shell_word "$bin_dir/catalex") agents add --name NAME --folder /absolute/folder"
fi

if [ "$join_computer" = 1 ] && [ "$join_system" = 1 ];then
 # Only new public system directories receive searchable modes. Existing
 # unsafe ancestors were refused above; never chmod a caller-owned path.
 # Keep the caller's private umask for records, code and temporary work.
 (umask 022; mkdir -p "$bin_dir" "$prefix/cache")
else
 mkdir -p "$prefix/cache"
fi
if [ "$join_computer" = 0 ] || [ ! -f "$marker" ];then
 (umask 077 && printf '%s\n' "$OWNER" >"$marker")
fi
work="$(mktemp -d "$prefix/cache/install.XXXXXX")"
trap 'join_cleanup' EXIT
trap 'join_interrupt' INT TERM

# curl reads the token from this private file (-H @file), keeping it out of
# the process list.
auth="$work/authorization"
if [ "$source" = token ]; then
	(umask 077 && printf 'Authorization: Bearer %s\n' "$token" >"$auth")
fi

fetch_latest() {
	case "$source" in
	local) cp "$from_dir/tree/latest.json" "$1" ;;
	gh) gh api "repos/$REPO/contents/latest.json?ref=$BRANCH" -H "Accept: application/vnd.github.raw" >"$1" ;;
	token) curl -fsSL -H "@$auth" -H "Accept: application/vnd.github.raw" \
		"$API/repos/$REPO/contents/latest.json?ref=$BRANCH" -o "$1" ;;
	anonymous) { [ "$REPO" = catalex-ai/catalex-builds ] && [ "$BRANCH" = main ] && curl -fsSL "${RELAY_DOWNLOADS_URL-https://downloads.catalex.co}/latest.json" -o "$1" 2>/dev/null; } || curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/latest.json" -o "$1" ;;
	esac || die "cannot read latest.json from $REPO; check your network connection"
}

# asset_url NAME prints the API URL of a release asset (token downloads).
asset_url() {
	if [ ! -f "$work/release.json" ]; then
		curl -fsSL -H "@$auth" "$API/repos/$REPO/releases/tags/$tag" -o "$work/release.json" ||
			die "cannot read release $tag from $REPO; check that GITHUB_TOKEN can read it"
	fi
	tr ',' '\n' <"$work/release.json" | awk -v want="$1" '
		/"url" *: *"https:\/\/api\.github\.com\/repos\/[^"]*\/releases\/assets\/[0-9]+"/ {
			u = $0; sub(/^.*"url" *: *"/, "", u); sub(/".*$/, "", u); next
		}
		match($0, /"name" *: *"[^"]*"/) {
			n = substr($0, RSTART, RLENGTH); sub(/^"name" *: *"/, "", n); sub(/"$/, "", n)
			if (n == want && u != "") { print u; exit }
		}'
}

download() {
	name="$1"
	target="$work/$name"
	say "Downloading $name"
	case "$source" in
	local) cp "$from_dir/assets/$name" "$target" ;;
	gh) gh release download "$tag" -R "$REPO" -p "$name" -D "$work" --clobber ;;
	token)
		url="$(asset_url "$name")"
		[ -n "$url" ] || die "release $tag has no asset $name"
		curl -fsSL -H "@$auth" -H "Accept: application/octet-stream" "$url" -o "$target"
		;;
	anonymous) { [ "$REPO" = catalex-ai/catalex-builds ] && curl -fsSL "${RELAY_DOWNLOADS_URL-https://downloads.catalex.co}/$tag/$name" -o "$target" 2>/dev/null; } ||
		curl -fsSL "https://github.com/$REPO/releases/download/$tag/$name" -o "$target" ;;
	esac || die "cannot download $name from release $tag; for a private repository run gh auth login or set GITHUB_TOKEN"
	[ -f "$target" ] || die "download of $name produced no file"
}

# verify NAME checks a downloaded asset against SHA256SUMS and latest.json.
verify() {
	expected="$(awk -v n="$1" '$2 == n {print $1}' "$work/SHA256SUMS")"
	[ -n "$expected" ] || die "$1 is not listed in SHA256SUMS"
	if [ -f "$work/latest.json" ]; then
		listed="$(grep -F "\"name\":\"$1\"" "$work/latest.json" | sed -n 's/.*"sha256":"\([0-9a-f]*\)".*/\1/p')"
		[ -z "$listed" ] || [ "$listed" = "$expected" ] || die "checksum mismatch for $1 between latest.json and SHA256SUMS"
	fi
	actual="$(sha256 "$work/$1")"
	[ "$actual" = "$expected" ] || die "checksum mismatch for $1; delete it and download again"
}

if [ -z "$version" ]; then
	fetch_latest "$work/latest.json"
	version="$(sed -n 's/.*"version":"\([^"]*\)".*/\1/p' "$work/latest.json" | head -n 1)"
	[ -n "$version" ] || die "latest.json names no version"
elif [ "$source" = local ]; then
	fetch_latest "$work/latest.json"
fi
case "$version" in
"" | *[!0-9A-Za-z._+-]*) die "invalid release version '$version'" ;;
esac
if [ -f "$work/latest.json" ] && ! grep -qF "\"version\":\"$version\"" "$work/latest.json"; then
	rm -f "$work/latest.json"
fi
tag="v$version"
say "Installing CatalEx $version for $os/$arch from $REPO ($source)"

download SHA256SUMS
# The client runs setup, so a release without its archive is refused before
# anything is installed.
if [ "$client" = 1 ] && ! awk -v n="catalex-$version-$os-$arch.tar.gz" '$2 == n {found=1} END {exit !found}' "$work/SHA256SUMS"; then
	die "release $version has no client archive for $os/$arch"
fi
release="$prefix/releases/$version"
mkdir -p "$release"

# unpack MODULE DIR downloads, verifies and unpacks one module archive.
unpack() {
	archive="$1-$version-$os-$arch.tar.gz"
	download "$archive"
	verify "$archive"
	if tar -tzf "$work/$archive" | grep -q -e '^/' -e '\.\./' -e '^\.\.$'; then
		die "$archive contains an unsafe path"
	fi
	# Only regular files and directories: no symbolic or hard links.
	if tar -tvzf "$work/$archive" | grep -qv -e '^-' -e '^d'; then
		die "$archive contains a link or special file"
	fi
	rm -rf "${work:?}/${2:?}"
	mkdir -p "$work/$2"
	tar -xzf "$work/$archive" -C "$work/$2"
	rm -rf "${release:?}/${2:?}"
	mv "$work/$2" "$release/$2"
}

# install_bin SOURCE NAME RECORD_KEY [DIR] installs SOURCE as DIR/NAME
# (default: the commands folder), backing up a different existing file the
# installation did not record.
install_bin() {
	target_dir="${4:-$bin_dir}"
	target="$target_dir/$2"
	mkdir -p "$target_dir"
	if [ -f "$target" ]; then
		current="$(sha256 "$target")"
        if [ "$join_computer" = 1 ] && [ "$current" = "$(sha256 "$1")" ]; then return 0; fi
		if [ "$current" != "$(previous "$3")" ]; then
			backup="$target.before-install-$(printf '%s' "$current" | cut -c1-16)"
			[ -e "$backup" ] || cp -p "$target" "$backup"
		fi
	fi
    if [ "$join_computer" = 1 ] && [ "$2" = relay ]; then join_service_changed=1; fi
	cp "$1" "$target.installing"
	chmod 755 "$target.installing"
	mv -f "$target.installing" "$target"
}

# plain_release RELEASE succeeds when RELEASE is a plain MAJOR.MINOR.PATCH.
plain_release() {
	printf '%s\n' "$1" | grep -Eq '^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$'
}

# release_newer RELEASE OTHER succeeds when plain RELEASE is newer than or
# equal to plain OTHER. It only orders standalone releases by preference;
# no release is refused for its version.
release_newer() {
	old_ifs="$IFS"
	IFS=.
	# shellcheck disable=SC2086 # split both releases into their numbers
	set -- $1 $2
	IFS="$old_ifs"
	[ "$1" -ne "$4" ] && { [ "$1" -gt "$4" ]; return; }
	[ "$2" -ne "$5" ] && { [ "$2" -gt "$5" ]; return; }
	[ "$3" -ge "$6" ]
}

# native_binary prints the Codex the owner runs, without executing it: the codex on PATH, then
# Codex's standalone current release, then the newest standalone release. Paths stay unresolved, so
# a registered agent follows the owner's own Codex updates; selected setup checks version and sign-in.
native_binary() {
	standalone="$HOME/.codex/packages/standalone"
	for candidate in "$(command -v codex 2>/dev/null || true)" "$standalone/current/bin/codex"; do
		case "$candidate" in /*) ;; *) continue ;; esac
		[ -f "$candidate" ] && [ -x "$candidate" ] || continue
		printf '%s\n' "$candidate"
		return 0
	done
	best=""
	best_release=""
	for dir in "$standalone"/releases/*; do
		name="${dir##*/}"
		# <MAJOR.MINOR.PATCH>-<target triple>; a pre-release never matches.
		release="${name%%-*}"
		case "${name#*-}" in aarch64-* | arm64-* | x86_64-*) ;; *) continue ;; esac
		plain_release "$release" || continue
		[ -f "$dir/bin/codex" ] && [ -x "$dir/bin/codex" ] || continue
		if [ -z "$best" ] || release_newer "$release" "$best_release"; then
			best="$dir/bin/codex"
			best_release="$release"
		fi
	done
	[ -n "$best" ] || return 1
	printf '%s\n' "$best"
}

install_skill() {
	if [ -e "$skill_dir" ] && { [ ! -f "$skill_dir/.relay-install-owned" ] ||
		[ "$(cat "$skill_dir/.relay-install-owned")" != "$SKILL_OWNER" ]; }; then
		die "existing setup skill is not CatalEx-owned: $skill_dir; move it before installing"
	fi
	mkdir -p "$(dirname "$skill_dir")"
	staged="$(dirname "$skill_dir")/.catalex-setup.installing"
	rm -rf "$staged"
	cp -R "$1" "$staged"
	# catalex uninstall removes the skill only when this marker is private
	# (0600); a fresh file takes umask 077's mode, so never write into an old one.
	rm -f "$staged/.relay-install-owned"
	(umask 077 && printf '%s\n' "$SKILL_OWNER" >"$staged/.relay-install-owned")
	rm -rf "$skill_dir"
	mv "$staged" "$skill_dir"
	# The skill was called relay-setup before; remove that copy when it is ours.
	if [ -f "$legacy_skill_dir/.relay-install-owned" ] &&
		[ "$(cat "$legacy_skill_dir/.relay-install-owned")" = "$SKILL_OWNER" ]; then
		rm -rf "$legacy_skill_dir"
	fi
}

# Voice transcription: the service command, run as the user that owns the speech folder (join_as_service), installs the release's engine from stdin, then ffmpeg and the model; a failure never fails the installation.
install_speech() { engine="$release/service/speech/whisper-cli"; [ ! -f "$engine" ] || { join_input="$engine"; join_as_service "$binary" speech install --engine - >/dev/null || say "Voice transcription is not fully installed; voice messages reach your agents without a transcript. Run: catalex doctor --fix"; }; }
assets="$(previous assets)"
agent="$(previous agent_binary)"
binary="$(previous binary_path)"
binary_sha256="$(previous binary_sha256)"
skill="$(previous skill_path)"
dash="$(previous dashboard_binary)"
dash_sha256="$(previous dashboard_binary_sha256)"
client_binary="$(previous catalex_binary)"
client_sha256="$(previous catalex_binary_sha256)"
# The app copy this installation installed (written by catalex); kept as is.
app_path="$(previous app_path)"

case "$native_providers" in
""|codex|claude|codex,claude|claude,codex) ;;
*) die "--native-providers must be codex, claude or codex,claude" ;;
esac
if [ -n "$native_providers" ] && [ -n "$agent_provider" ]; then
 case ",$native_providers," in *",$agent_provider,"*) ;; *) die "--agent-provider must be included in --native-providers" ;; esac
fi

if [ "$service" = 1 ]; then
	unpack catalex-service service
	lock="$release/service/runtime/source-lock.json"
	if [ ! -f "$release/service/runtime/assets/manifest.json" ] || [ ! -f "$lock" ]; then
		die "release $version has no Codex runtime bundle for $os/$arch;
       install with --only web"
	fi
    if [ "$join_computer" = 1 ]; then agent=""; else agent="$(native_binary)" || agent=""; fi
	assets="$prefix/runtimes/$(sha256 "$lock")"
	if [ ! -f "$assets/manifest.json" ]; then
		mkdir -p "$prefix/runtimes"
		rm -rf "$assets.installing"
		cp -R "$release/service/runtime/assets" "$assets.installing"
		rm -rf "$assets"
		mv "$assets.installing" "$assets"
	fi
	install_bin "$release/service/relay" relay binary_sha256
	binary="$bin_dir/relay"; binary_sha256="$(sha256 "$binary")"; [ "$join_computer" = 1 ] || install_speech
    if [ "$join_computer" = 0 ]; then
     install_skill "$release/service/skills/catalex-setup"
     skill="$skill_dir"
    else skill=""; fi
fi
if [ "$web" = 1 ]; then
	unpack catalex-web web
	install_bin "$release/web/dashboard" dashboard dashboard_binary_sha256 "$private_dir"
	dash="$private_dir/dashboard"
	dash_sha256="$(sha256 "$dash")"
fi
# An earlier installation put the web command in the commands folder, where Terminal finds it. Move
# it off PATH: the recorded, unchanged copy is replaced by the one just installed, or moved to the
# private folder when this run installs no web app. A copy changed since it was installed is not
# ours to move, so it stays where it is.
legacy_dash="$(previous dashboard_binary)"
if [ -n "$legacy_dash" ] && [ "$legacy_dash" != "$private_dir/dashboard" ] && [ -f "$legacy_dash" ] &&
	[ "$(sha256 "$legacy_dash")" = "$(previous dashboard_binary_sha256)" ]; then
	if [ "$web" = 1 ]; then
		rm -f "$legacy_dash"
	else
		mkdir -p "$private_dir"
		mv -f "$legacy_dash" "$private_dir/dashboard"
		dash="$private_dir/dashboard"
	fi
	say "Moved the CatalEx app server off PATH into $private_dir; the CatalEx app and catalex open use it."
fi

if [ "$client" = 1 ]; then
	unpack catalex catalex
	install_bin "$release/catalex/catalex" catalex catalex_binary_sha256
	client_binary="$bin_dir/catalex"
	client_sha256="$(sha256 "$client_binary")"
fi

# Each component's own release: a run that names only some components leaves
# the others' as recorded, or at the release of a record from before this.
component_release() {
	if [ "$1" = 1 ]; then
		printf '%s' "$version"
	else
		recorded="$(previous "$2")"
		printf '%s' "${recorded:-$(previous release_version)}"
	fi
}
catalex_release="$(component_release "$client" catalex_release)"
relay_release="$(component_release "$service" relay_release)"
dashboard_release="$(component_release "$web" dashboard_release)"

old_umask="$(umask)"
umask 077
installation_record() {
cat <<EOF
{
  "version": 1,
  "release_version": "$version",
  "assets": "${1:-$assets}",
  "agent_binary": "$agent",
  "binary_path": "$binary",
  "binary_sha256": "$binary_sha256",
  "skill_path": "$skill",
  "dashboard_binary": "$dash",
  "dashboard_binary_sha256": "$dash_sha256",
  "catalex_binary": "$client_binary",
  "catalex_binary_sha256": "$client_sha256",
  "catalex_release": "$catalex_release",
  "relay_release": "$relay_release",
  "dashboard_release": "$dashboard_release",
  "app_path": "$app_path"
}
EOF
}
installation_record >"$record.installing"
chmod 600 "$record.installing"
if [ "$join_computer" = 1 ] && [ -f "$record" ] && cmp -s "$record.installing" "$record";then
 rm -f "$record.installing"
else mv -f "$record.installing" "$record";fi
umask "$old_umask"
say "Installed CatalEx $version: $bin_dir"
add_to_path

# All bootstrap client state is temporary: an installer never signs a client in
# or inherits another selected connection. Only the selected local publication
# is scanned, and the authenticated owner must match this installation.
join_cli() {
 join_http_ms=$1
 shift
 set -- HOME="$work/client-home" PATH="$bin_dir:/usr/local/bin:/usr/bin:/bin" \
  CATALEX_RELAY_HOME="$work/client" XDG_CONFIG_HOME="$work/client-config" \
  XDG_STATE_HOME="$work/client-state" XDG_CACHE_HOME="$work/client-cache" \
  CATALEX_SERVER_CONTROL_RECORD="$join_publication" \
  CATALEX_CLIENT_REQUEST_TIMEOUT_MS="$join_http_ms" \
  CATALEX_CLIENT_DISCOVERY_PROBE_TIMEOUT_MS="$join_http_ms" \
  "$client_binary" "$@"
 # Preserve this non-secret override (including explicit empty/disabled),
 # while no client credential or provider configuration enters bootstrap.
 if [ "${CATALEX_CLOUD_SERVICE_URL+x}" = x ];then
  set -- "CATALEX_CLOUD_SERVICE_URL=$CATALEX_CLOUD_SERVICE_URL" "$@"
 fi
 join_run env -i "$@"
}
join_wait_ready() {
 join_now=$(date +%s)
 case "$join_now" in ''|*[!0-9]*) die "cannot measure the CatalEx readiness wait";; esac
 join_deadline=$((join_now * 1000 + join_wait_ms))
 join_first_probe=1
 while [ "$join_first_probe" = 1 ] || [ "$(date +%s)000" -lt "$join_deadline" ]; do
  join_first_probe=0
  join_owner=""
  if [ -f "$join_controller/controller.json" ]; then
   join_owner=$(json_field owner_id < "$join_controller/controller.json" | json_identifier)
  fi
  if [ -n "$join_owner" ]; then
   if [ "$join_system" = 1 ]; then join_publication=/run/catalex-relay/endpoint.json
   else join_publication="$join_relay_home/local-relay/installations/$join_owner.json"; fi
   join_quiet=1
   if join_cli "$join_probe_ms" status --json >"$work/join-status.json"; then
    join_status=$(cat "$work/join-status.json")
    join_connection=$(printf '%s\n' "$join_status" | json_field connection)
    join_data=$(printf '%s\n' "$join_status" | json_field data)
    if [ "$(printf '%s\n' "$join_status" | json_field schema)" = '"catalex.result.v1"' ] &&
       [ "$(printf '%s\n' "$join_status" | json_field ok)" = true ] &&
       [ "$(printf '%s\n' "$join_connection" | json_field kind)" = '"service"' ] &&
       [ "$(printf '%s\n' "$join_connection" | json_field installation_id | json_identifier)" = "$join_owner" ] &&
       [ "$(printf '%s\n' "$join_data" | json_field schema)" = '"relay.controller.v1"' ] &&
       [ "$(printf '%s\n' "$join_data" | json_field owner_id | json_identifier)" = "$join_owner" ]; then
      join_connection_id=$(printf '%s\n' "$join_connection" | json_field id | json_identifier)
      [ -z "$join_connection_id" ] || return 0
    fi
   fi
  fi
  # The minimum configured control probe budget is one second (specification).
  join_run sleep "$((join_probe_ms / 1000))"
 done
 die "CatalEx is not authenticated and ready; inspect catalex status, then rerun the same installer command"
}
join_copy_service_record() {
 join_service_prefix="$join_service_home/.local/share/catalex-relay"
 join_service_assets="$join_service_prefix/runtimes/$(basename "$assets")"
 # Read the verified source as root, but extract/write only as the service
 # user. A daemon-writable home must never receive recursive root chown/copy.
 # shellcheck disable=SC2016 # Variables belong to the service-user child.
 join_as_service sh -c 'umask 077; mkdir -p "$1"; [ -f "$1/manifest.json" ]' sh "$join_service_assets" >/dev/null 2>&1 || {
  join_run tar -czf "$work/service-runtime.tar.gz" -C "$assets" .
  join_input="$work/service-runtime.tar.gz"
  # shellcheck disable=SC2016 # Variables belong to the service-user child.
  join_as_service sh -c 'umask 077; mkdir -p "$1"; tar -xzf - -C "$1"' sh "$join_service_assets"
 }
 installation_record "$join_service_assets" > "$work/service-installation.json"
 join_input="$work/service-installation.json"
 # shellcheck disable=SC2016 # The child owns its stage and cleanup variables.
 join_as_service sh -c '
  umask 077
  mkdir -p "$1"
  staged=$(mktemp "$1/.installation.XXXXXX") || exit 1
  trap '\''rm -f "$staged"'\'' EXIT
  cat > "$staged" || exit 1
  if [ -f "$1/installation.json" ] && cmp -s "$staged" "$1/installation.json"; then
   printf unchanged
  else
   mv -f "$staged" "$1/installation.json" || exit 1
   printf changed
  fi' sh "$join_service_prefix" > "$work/service-record-result"
 join_record_changed=$(cat "$work/service-record-result")
}
join_provider_next_steps() {
 join_provider_found=0
 for join_provider in claude codex; do
  # shellcheck disable=SC2016 # $1 is the child command argument.
  if join_as_service sh -c 'command -v "$1" >/dev/null 2>&1' sh "$join_provider"; then join_provider_found=1;fi
 done
 if [ "$join_provider_found" = 0 ]; then
  say "Computer joined; no AI provider command is installed for the user that runs agents."
  say "Install Claude Code: https://code.claude.com/docs/en/setup"
  say "Or install Codex: https://learn.chatgpt.com/docs/cli"
 fi
 if [ "$join_system" = 1 ]; then
  say "Sign in to your AI provider as catalex (not as the login user):"
  join_provider_path="$join_service_home/.local/bin:/usr/local/bin:/usr/bin:/bin"
  say "  sudo -u catalex -H env PATH=$(shell_word "$join_provider_path") claude auth login"
  say "  sudo -u catalex -H env PATH=$(shell_word "$join_provider_path") codex login --device-auth"
 else
  say "Sign in to your AI provider as your login user: claude auth login, or codex login --device-auth."
 fi
}
# A join_run child reads the line into private file $1: sh defers a trap until a foreground read returns.
join_read_line() { IFS= read -r join_line && (umask 077; printf '%s\n' "$join_line" >"$1"); }
join_read_terminal() {
 join_require_terminal
 # Debug tracing must never turn a pasted code into a log or process argument.
 set +x
 join_tty_mode=$(stty -g </dev/tty) || die "cannot read terminal settings"
 stty -echo </dev/tty || die "cannot hide terminal input; use --join-file"
 printf 'Paste the join code from the device that added this computer.\n\nJoin code (hidden): ' >&2
 join_input=/dev/tty; join_run join_read_line "$work/join-code" || die "the join code could not be read"
 join_code=$(cat "$work/join-code"); rm -f "$work/join-code"
 stty "$join_tty_mode" </dev/tty || die "terminal settings could not be restored; run stty sane"
 join_tty_mode=""
 printf '\n' >&2
 [ -n "$join_code" ] || die "provide the join code"
}

join_bootstrap() {
 join_controller_paths
 set -- --controller-dir "$join_controller" --installation "$join_record" service install --server
 [ "$join_system" = 0 ] || set -- "$@" --service-home "$join_service_home"
 # sudo identifies the requesting login user. Do not guess an account for
 # cloud-init/root shells, or import any of that user's client credentials.
 if [ "$join_system" = 1 ] && [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ];then
  set -- "$@" --login-user "$SUDO_USER"
 fi
 join_run "$binary" "$@" >&2
 join_record_changed=unchanged; install_speech
 if [ "$join_system" = 1 ]; then join_copy_service_record;fi
 if [ "$join_service_changed" = 1 ] || [ "$join_record_changed" = changed ]; then
  if [ "$join_system" = 1 ]; then join_run systemctl restart catalex-relay.service
  else join_run systemctl --user restart catalex-relay.service;fi
 fi
 say "Waiting for CatalEx to be authenticated and ready."
 join_wait_ready
 set -- --connection "$join_connection_id" join --trust "$join_trust"
 [ -z "$service_url" ] || set -- "$@" --service "$service_url"
 if [ -n "$join_file" ]; then
  join_cli "$join_wait_ms" "$@" --join-file "$join_file"
 else
  join_read_terminal
  # curl|sh occupies standard input. The code reaches the CLI only through
  # its published one-line pipe input, never an argument or environment value.
  join_input_code=1
  join_cli "$join_wait_ms" "$@"
  unset join_code
 fi
 join_provider_next_steps
}

if [ "$join_computer" = 1 ]; then
 join_bootstrap
 exit 0
fi

# The same default setup as the developer installer, or the chosen one; the
# first failing step stops the installer.
if [ "$setup" = 1 ]; then
	if [ "$service" = 1 ]; then
		if [ "$agent_provider" = claude ]; then
			set -- --claude-binary claude
            [ -n "$native_providers" ] || native_providers=claude
		else
			set --
		fi
        if [ -n "$native_providers" ]; then
            set -- "$@" --native-providers "$native_providers"
            case ",$native_providers," in *,claude,*) [ "$agent_provider" = claude ] || set -- "$@" --claude-binary claude ;; esac
        fi

		if [ "$setup_mode" = connect ]; then
			if [ -n "$connect_token" ]; then
				home_dir="${CATALEX_RELAY_HOME:-$HOME/.catalex}"
				case "$home_dir" in
				/*) ;;
				*) die "CATALEX_RELAY_HOME must be an absolute path" ;;
				esac
				token_file="$home_dir/connect/service-token"
				(umask 077 && mkdir -p "$home_dir/connect")
				chmod 700 "$home_dir/connect"
				rm -f "$token_file"
				(umask 077 && printf '%s\n' "$connect_token" >"$token_file")
				chmod 600 "$token_file"
			fi
			"$bin_dir/catalex" setup --mode connect --service-url "$service_url" --token-file "$token_file" --start --no-launch "$@" >&2
		else
			"$bin_dir/catalex" setup --mode "$local_mode" --start --no-launch "$@" >&2
		fi
		for name in $channel_list; do
			if [ "$name" = slack ]; then account_name="$slack_name"; else account_name="$whatsapp_name"; fi
			"$bin_dir/catalex" accounts add --platform "$name" --name "$account_name" >&2
			note "Enter $name credentials interactively (in connect mode, on the computer hosting the service):
      $(shell_word "$bin_dir/catalex") destinations setup ACCOUNT_ID --$name"
		done
		if [ "$want_agent" = 1 ]; then
			set -- agents add --name "$(basename "$agent_folder")" --folder "$agent_folder"
			[ -z "$agent_provider" ] || set -- "$@" --agent "$agent_provider"
			[ -z "$agent_model" ] || set -- "$@" --model "$agent_model"
			[ -z "$agent_effort" ] || set -- "$@" --effort "$agent_effort"
			"$bin_dir/catalex" "$@" >&2
		fi
	fi
	if [ "$web" = 1 ]; then
		"$dash" setup >&2
		if [ "$open" = 1 ]; then
			"$dash" open >&2
		else
			"$dash" open --no-browser >&2
		fi
	fi
elif [ "$open" = 1 ]; then
	if [ "$web" = 1 ]; then
		"$dash" open >&2
	elif [ "$service" = 1 ]; then
		"$bin_dir/catalex" open >&2
	fi
fi

if [ "$setup" = 1 ]; then
	if [ "$web" = 1 ] && [ "$service" = 0 ]; then
		say ""
		say "The CatalEx web app has no CatalEx on this computer yet: install it with
  --only service,web."
	fi
	if [ "$web" = 1 ]; then
		say ""
		say "CatalEx web app:"
		"$dash" status >&2 || say "Status unavailable; check it later with: catalex status"
	fi
	if [ "$service" = 1 ]; then
		say ""
		say "CatalEx status:"
		"$bin_dir/catalex" status >&2 || say "Status unavailable; check it later with: catalex status"
		say ""
		say "Next: connect Slack or WhatsApp:"
		say "  $(shell_word "$bin_dir/catalex") destinations setup ACCOUNT_ID"
		say "To stop everything:"
		say "  $(shell_word "$bin_dir/catalex") stop --all"
	fi
fi
if [ -n "$skipped" ]; then
	say ""
	say "Not configured yet:$skipped"
fi
