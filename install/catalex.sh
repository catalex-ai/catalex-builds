#!/bin/sh
# Install CatalEx with one command: the catalex command-line client and, on a
# Mac with Apple Silicon, the CatalEx app.
#
#   sh catalex.sh [--app | --app-only | --no-app] [--version V]
#                 [--bin-dir DIR] [--no-path] [--apps-dir DIR] [--no-launch]
#                 [--yes] [--from-dir DIR]
#
# The client goes into ~/.local/bin (or --bin-dir), is recorded the way
# install.sh records every command, and its folder is put on the login
# shell's PATH with the block install.sh and the app share. On a Mac with
# Apple Silicon the app is installed too, without asking, unless --no-app;
# it then opens, unless --no-launch. Elsewhere only the client is installed.
# Nothing is asked, so the script runs the same from a pipe, a terminal or
# an agent, and running it again is safe.
#
# This script installs nothing itself. It reads the newest release (or
# --version) once, then runs that release's install.sh (--only catalex) and
# install-app.sh, which download, verify and place the files. Downloads use
# gh when it is logged in, else GITHUB_TOKEN or GH_TOKEN, else an anonymous
# download, as those scripts do; a token is passed to curl in a private
# header file, never on its command line. The rest of CatalEx stays
# separate: `catalex install service web`.
set -eu

REPO="${RELAY_RELEASE_REPO:-catalex-ai/catalex-builds}"
BRANCH="${RELAY_RELEASE_BRANCH:-main}"
API="https://api.github.com"

version=""
app=""
bin_dir=""
apps_dir=""
add_path=1
launch=1
yes=0
from_dir=""
join_computer=0
join_file=""
join_trust=""
join_service=""
join_service_home=""

say() { printf '%s\n' "$*" >&2; }
die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}
usage() {
	cat >&2 <<'USAGE'
Install CatalEx: the catalex command-line client and, on a Mac with Apple
Silicon, the CatalEx app.

usage: sh catalex.sh [--app | --app-only | --no-app] [--version V]
                     [--bin-dir DIR] [--no-path] [--apps-dir DIR]
                     [--no-launch] [--yes] [--from-dir DIR]
                     [--join | --join-file FILE] [--trust FINGERPRINT]
                     [--service ORIGIN] [--service-home DIR]

  --join           install the catalex client and CatalEx and join a Linux computer;
                   read the code hidden from /dev/tty, or use --join-file
  --trust FP       pin the key that created the join code
  --service URL    use this CatalEx service address instead of the join code's
  --app            also install the CatalEx app (the default on a Mac with
                   Apple Silicon; refused elsewhere)
  --app-only       install only the CatalEx app
  --no-app         install only the client
  --version V      install release V instead of the newest one
  --bin-dir DIR    put catalex in DIR instead of ~/.local/bin
  --no-path        do not add DIR to your login shell's PATH
  --apps-dir DIR   put the app in DIR instead of /Applications
  --no-launch      do not open the app after installing it
  --yes            ask nothing; quit a running CatalEx that must be replaced
  --from-dir DIR   install from a local release folder (assets/ and tree/)
  -h, --help       show this help

Ordinary installation asks nothing. On a Mac with Apple Silicon it installs the app as
well and opens it, and the app's setup wizard does the rest; elsewhere it
installs only the client. To add the rest of CatalEx, run catalex install
afterwards.
With --join, --trust is required and the code is read privately from the
terminal; --join-file supports unattended Linux installation.

Examples:
  sh catalex.sh
  sh catalex.sh --yes --no-launch
  sh catalex.sh --no-app
USAGE
	exit "$1"
}

need_value() {
	[ "$#" -ge 2 ] && [ -n "$2" ] || die "$1 needs a value"
}

while [ "$#" -gt 0 ]; do
	case "$1" in
    --join) join_computer=1; shift ;;
    --join-file) need_value "$@"; join_computer=1; join_file="$2"; shift 2 ;;
    --join-file=*) join_computer=1; join_file="${1#*=}"; [ -n "$join_file" ] || die "--join-file needs a value"; shift ;;
    --trust) need_value "$@"; join_trust="$2"; shift 2 ;;
    --trust=*) join_trust="${1#*=}"; [ -n "$join_trust" ] || die "--trust needs a value"; shift ;;
    --service | --service-url) need_value "$@"; join_service="$2"; shift 2 ;;
    --service=* | --service-url=*) join_service="${1#*=}"; [ -n "$join_service" ] || die "--service needs a value"; shift ;;
    --service-home) need_value "$@"; join_service_home="$2"; shift 2 ;;
    --service-home=*) join_service_home="${1#*=}"; [ -n "$join_service_home" ] || die "--service-home needs a value"; shift ;;
	--app)
		app=both
		shift
		;;
	--app-only)
		app=only
		shift
		;;
	--no-app)
		app=none
		shift
		;;
	--version)
		need_value "$@"
		version="$2"
		shift 2
		;;
	--version=*)
		version="${1#*=}"
		shift
		;;
	--bin-dir)
		need_value "$@"
		bin_dir="$2"
		shift 2
		;;
	--bin-dir=*)
		bin_dir="${1#*=}"
		shift
		;;
	--no-path)
		add_path=0
		shift
		;;
	--apps-dir)
		need_value "$@"
		apps_dir="$2"
		shift 2
		;;
	--apps-dir=*)
		apps_dir="${1#*=}"
		shift
		;;
	--no-launch)
		launch=0
		shift
		;;
	--yes | -y)
		yes=1
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

# The app is built for macOS on Apple Silicon only.
app_platform=0
if [ "$(uname -s)" = Darwin ]; then
	case "$(uname -m)" in
	arm64 | aarch64) app_platform=1 ;;
	esac
fi

# The app comes with the client wherever it runs, unless --no-app says not.
if [ "$join_computer" = 1 ]; then
 [ -n "$join_trust" ] || die "--join needs --trust FINGERPRINT from the device that created the code"
 case "$app" in ""|none) app=none;; *) die "--join does not install the app; omit app selection flags";;esac
 [ -z "$apps_dir" ] || die "--join does not install the app; omit --apps-dir"
elif [ -n "$join_trust$join_service$join_service_home" ]; then
 die "--trust, --service and --service-home require --join"
fi

app_default=0
if [ -z "$app" ]; then
	app_default=1
	app=none
	[ "$app_platform" = 0 ] || app=both
fi
if [ "$app" != none ] && [ "$app_platform" = 0 ]; then
	die "the CatalEx app is for macOS on Apple Silicon; install the client alone with --no-app"
fi
if [ "$app" = only ] && { [ -n "$bin_dir" ] || [ "$add_path" = 0 ]; }; then
	die "--bin-dir and --no-path apply to the client, which --app-only does not install"
fi
if [ "$join_computer" = 0 ] && [ "$app" = none ] && [ "$app_default" = 0 ] && { [ -n "$apps_dir" ] || [ "$launch" = 0 ]; }; then
	die "--apps-dir and --no-launch apply to the app, which --no-app does not install"
fi

# catalex, which installs the app beside the client, takes absolute folders.
for dir in "$apps_dir" "$from_dir" "$bin_dir"; do
	case "$dir" in
	"" | /*) ;;
	*) die "$dir must be an absolute path" ;;
	esac
done

for command in curl awk sed; do
	command -v "$command" >/dev/null 2>&1 || die "$command is required; install it and retry"
done

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

work="$(mktemp -d "${TMPDIR:-/tmp}/catalex-install.XXXXXX")"
trap 'rm -rf "$work"' EXIT
trap 'say "Installation interrupted. Run the same command to resume."; exit 130' INT TERM

# curl reads the token from this private file (-H @file), keeping it out of
# the process list.
auth="$work/authorization"
if [ "$source" = token ]; then
	(umask 077 && printf 'Authorization: Bearer %s\n' "$token" >"$auth")
fi

# fetch PATH FILE copies PATH from the release repository.
fetch() {
	case "$source" in
	local) cp "$from_dir/tree/$1" "$2" ;;
	gh) gh api "repos/$REPO/contents/$1?ref=$BRANCH" -H "Accept: application/vnd.github.raw" >"$2" ;;
	token) curl -fsSL -H "@$auth" -H "Accept: application/vnd.github.raw" \
		"$API/repos/$REPO/contents/$1?ref=$BRANCH" -o "$2" ;;
	anonymous) curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/$1" -o "$2" ;;
	esac || die "cannot read $1 from $REPO; check your network connection"
}

# Both installers get the same release.
if [ -z "$version" ]; then
	fetch latest.json "$work/latest.json"
	version="$(sed -n 's/.*"version":"\([^"]*\)".*/\1/p' "$work/latest.json" | head -n 1)"
	[ -n "$version" ] || die "latest.json names no version"
fi
case "$version" in
"" | *[!0-9A-Za-z._+-]*) die "invalid release version '$version'" ;;
esac

set -- --version "$version"
[ -z "$from_dir" ] || set -- "$@" --from-dir "$from_dir"

if [ "$app" != only ]; then
	fetch install/install.sh "$work/install.sh"
    if [ "$join_computer" = 1 ];then say "Installing the CatalEx computer $version";else say "Installing the catalex command-line client $version";fi
    if [ "$join_computer" = 1 ];then
     set -- "$@" --join --trust "$join_trust"
     [ -z "$join_file" ] || set -- "$@" --join-file "$join_file"
     [ -z "$join_service" ] || set -- "$@" --service "$join_service"
     [ -z "$join_service_home" ] || set -- "$@" --service-home "$join_service_home"
    else set -- "$@" --only catalex --setup skip --no-open --yes;fi
	[ -z "$bin_dir" ] || set -- "$@" --bin-dir "$bin_dir"
	[ "$add_path" = 1 ] || set -- "$@" --no-path
	# install.sh prints its installation record; the client's summary is enough.
    if [ "$join_computer" = 1 ];then
     join_child=""
     # shellcheck disable=SC2329 # Invoked by the INT/TERM trap.
     join_interrupt() {
      trap '' INT TERM
      if [ -n "$join_child" ];then
       kill -TERM "$join_child" 2>/dev/null || true
       wait "$join_child" 2>/dev/null || true
      fi
      say "Installation interrupted. Run the same command to resume."
      exit 130
     }
     join_cancel_pending=0
     trap 'join_cancel_pending=1' INT TERM
     sh "$work/install.sh" "$@" &
     join_child=$!
     trap 'join_interrupt' INT TERM
     [ "$join_cancel_pending" = 0 ] || join_interrupt
     join_result=0
     wait "$join_child" || join_result=$?
     join_child=""
     trap 'say "Installation interrupted. Run the same command to resume."; exit 130' INT TERM
     [ "$join_result" = 0 ] || die "computer installation or joining did not finish; see the message above"
     exit 0
    fi
	sh "$work/install.sh" "$@" >/dev/null || die "the client was not installed; see the message above"
	set -- --version "$version"
	[ -z "$from_dir" ] || set -- "$@" --from-dir "$from_dir"
fi

if [ "$app" = both ]; then
	# The client just installed installs the app, so the installation record
	# names the copy it placed: catalex update keeps it current, and
	# catalex setup --start opens it once CatalEx runs.
	client="${bin_dir:-$HOME/.local/bin}/catalex"
	set -- install app "$@"
	[ -z "$apps_dir" ] || set -- "$@" --apps-dir "$apps_dir"
	[ "$launch" = 0 ] || set -- "$@" --open
	[ "$yes" = 0 ] || set -- "$@" --yes
	if ! "$client" "$@" --json >"$work/app.json"; then
		# Homebrew owns an app it installed; that copy is kept and used.
		grep -qF '"code":"PACKAGE_MANAGED"' "$work/app.json" ||
			die "the CatalEx app was not installed; see the message above"
		say "Homebrew installed the CatalEx app, so it is kept; Homebrew updates it."
	fi
elif [ "$app" = only ]; then
	fetch install/install-app.sh "$work/install-app.sh"
	[ -z "$apps_dir" ] || set -- "$@" --apps-dir "$apps_dir"
	[ "$launch" = 1 ] || set -- "$@" --no-launch
	[ "$yes" = 0 ] || set -- "$@" --yes
	sh "$work/install-app.sh" "$@" || die "the CatalEx app was not installed; see the message above"
fi

# Start CatalEx in the background as the app does at launch (catalex prepare
# is idempotent), so it is running before the person opens anything. Best effort:
# the app starts it too, and a client alone has no runtime until catalex install.
if [ "$app" != only ]; then
	client="${bin_dir:-$HOME/.local/bin}/catalex"
	if [ -x "$client" ]; then
		(
			"$client" prepare </dev/null >/dev/null 2>&1 || true
		) &
	fi
fi

say ""
if [ "$app_default" = 1 ] && [ "$app_platform" = 0 ]; then
	say "The CatalEx app is for macOS on Apple Silicon, so only the client was installed."
fi
if [ "$app" != only ]; then
	say "Done. Open a new terminal and run: catalex --help"
	say "Add the rest of CatalEx later with: catalex install"
else
	say "Done. The CatalEx app installs the command-line client when it starts."
fi
