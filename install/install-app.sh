#!/bin/sh
# Install the CatalEx macOS app from a published release, then open it.
#
#   sh install-app.sh [--version V] [--apps-dir DIR] [--no-launch] [--yes]
#                     [--from-dir DIR]
#
# Downloads CatalEx-arm64.dmg from the GitHub Release v<V> of the
# distribution repository, verifies it against the release's SHA256SUMS and
# latest.json, mounts it without showing it in Finder, copies CatalEx.app
# into /Applications (or ~/Applications when /Applications is not writable),
# unmounts it and opens the app, whose first run is its setup wizard. The app
# then installs the command-line tools itself; install.sh installs only them.
#
# Downloads use gh when it is logged in, else GITHUB_TOKEN or GH_TOKEN, else
# an anonymous download, exactly as install.sh does. A token is passed to curl
# in a private header file, never on its command line.
#
# Running it again is safe: the same version is left in place, and a
# different one replaces the installed app only once that app is not running.
# Running copies are identified by bundle identity, whatever their folder.
# A copy running from the app being replaced conflicts; a copy in another
# folder conflicts only when the installer opens the app, since only one
# CatalEx runs at a time (with --no-launch it is kept running). Conflicting
# copies quit through macOS with their own shutdown behavior after asking in
# a terminal, or at once with --yes; without either the installer stops and
# says so.
#
# The app is not signed or notarized. curl and gh do not mark their downloads
# as quarantined, so macOS opens an app installed this way without the
# right-click Open step a browser download needs; the installer never changes
# quarantine attributes itself.
set -eu

REPO="${RELAY_RELEASE_REPO:-catalex-ai/catalex-builds}"
BRANCH="${RELAY_RELEASE_BRANCH:-main}"
API="https://api.github.com"
# APP_NAME is the bundle the DMG holds (dashboard/desktop/forge.config.ts).
APP_NAME="CatalEx.app"
# APP_BUNDLE_ID is the macOS identity in dashboard/desktop/forge.config.ts.
APP_BUNDLE_ID="ai.catalex.relay.desktop"
# DESKTOP_MODULE names the DMG in latest.json.
DESKTOP_MODULE="desktop"
# QUIT_WAIT_SECONDS bounds the wait for a quitting CatalEx to exit; it stops
# its dashboard first, which takes a few seconds.
QUIT_WAIT_SECONDS="${CATALEX_QUIT_WAIT_SECONDS:-30}"

version=""
apps_dir=""
apps_dir_explicit=0
launch=1
yes=0
from_dir=""

say() { printf '%s\n' "$*" >&2; }
die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}
usage() {
	cat >&2 <<'USAGE'
Install the CatalEx app for macOS and open it.

usage: sh install-app.sh [--version V] [--apps-dir DIR] [--no-launch] [--yes]
                         [--from-dir DIR]

  --version V      install release V instead of the newest one
  --apps-dir DIR   install into DIR instead of /Applications (falls back to
                   ~/Applications when /Applications is not writable)
  --no-launch      install without opening the app (for scripts)
  --yes            quit conflicting CatalEx copies without asking
  --from-dir DIR   install from a local release folder (assets/ and tree/)
  -h, --help       show this help

The app's first run is its setup wizard; it installs CatalEx, the messaging service
and the app's server for you. For the commands alone, use install.sh.

Examples:
  sh install-app.sh
  sh install-app.sh --version 0.1.0 --no-launch
USAGE
	exit "$1"
}

need_value() {
	[ "$#" -ge 2 ] && [ -n "$2" ] || die "$1 needs a value"
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--version)
		need_value "$@"
		version="$2"
		shift 2
		;;
	--version=*)
		version="${1#*=}"
		shift
		;;
	--apps-dir)
		need_value "$@"
		apps_dir="$2"
		apps_dir_explicit=1
		shift 2
		;;
	--apps-dir=*)
		apps_dir="${1#*=}"
		[ -n "$apps_dir" ] || die "--apps-dir needs a value"
		apps_dir_explicit=1
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

case "$QUIT_WAIT_SECONDS" in
"" | *[!0-9]*) die "CATALEX_QUIT_WAIT_SECONDS must be a whole number of seconds" ;;
esac

[ "$(uname -s)" = Darwin ] || die "the CatalEx app is for macOS; on $(uname -s) install the commands with install.sh"
case "$(uname -m)" in
arm64 | aarch64) arch=arm64 ;;
*) die "the CatalEx app is built for Apple Silicon (arm64) only; install the commands with install.sh" ;;
esac

for command in curl awk sed hdiutil ditto plutil osascript; do
	command -v "$command" >/dev/null 2>&1 || die "$command is required; install it and retry"
done

# Where the app goes: --apps-dir, else /Applications when writable, else
# ~/Applications.
if [ -n "$apps_dir" ]; then
	case "$apps_dir" in
	/*) ;;
	*) die "--apps-dir must be an absolute path" ;;
	esac
	mkdir -p "$apps_dir" || die "cannot create $apps_dir"
	[ -w "$apps_dir" ] || die "$apps_dir is not writable"
elif [ -w /Applications ]; then
	apps_dir=/Applications
else
	apps_dir="$HOME/Applications"
	say "/Applications is not writable; installing into $apps_dir"
	mkdir -p "$apps_dir" || die "cannot create $apps_dir"
fi
case "$apps_dir" in
*\"* | *\\*) die "the Applications folder must not contain quotes or backslashes" ;;
esac
# Compare physical directories with the bundle locations macOS reports.
apps_dir="$(cd "$apps_dir" && pwd -P)" || die "cannot resolve $apps_dir"
app="$apps_dir/$APP_NAME"

interactive=0
if [ "$yes" = 0 ] && [ -t 0 ] && [ -t 1 ]; then
	interactive=1
fi

sha256() { shasum -a 256 "$1" | awk '{print $1}'; }

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

work="$(mktemp -d "${TMPDIR:-/tmp}/catalex-app.XXXXXX")"
mount=""
# cleanup unmounts the image (if mounted) and removes the download folder.
cleanup() {
	if [ -n "$mount" ]; then
		hdiutil detach "$mount" -quiet >/dev/null 2>&1 || hdiutil detach "$mount" -force -quiet >/dev/null 2>&1 || true
	fi
	rm -rf "$work"
}
trap cleanup EXIT
trap 'say "Installation interrupted. Run the same command to resume."; exit 130' INT TERM

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
	anonymous) curl -fsSL "https://raw.githubusercontent.com/$REPO/$BRANCH/latest.json" -o "$1" ;;
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
	anonymous) curl -fsSL "https://github.com/$REPO/releases/download/$tag/$name" -o "$target" ;;
	esac || die "cannot download $name from release $tag; check your network connection"
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
	[ "$actual" = "$expected" ] || die "checksum mismatch for $1; never install it; download it again"
}

# app_version APP prints the app's version, or nothing when it has none.
app_version() {
	plutil -extract CFBundleShortVersionString raw -o - "$1/Contents/Info.plist" 2>/dev/null || true
}

# app_control uses macOS's running application metadata, never a path/name
# match or a LaunchServices lookup that could start another installed copy.
# Quit targets only the concrete PID while it still has CatalEx's identity.
app_control() {
	osascript -l JavaScript -e '
ObjC.import("AppKit");
function run(args) {
    var applications = $.NSWorkspace.sharedWorkspace.runningApplications;
    var found = [];
    for (var i = 0; i < applications.count; i++) {
        var application = applications.objectAtIndex(i);
        if (ObjC.unwrap(application.bundleIdentifier) !== args[1]) continue;
        var pid = String(application.processIdentifier);
        if (args[0] === "list") {
            var location = ObjC.unwrap(application.bundleURL.path);
            if (/[\t\r\n]/.test(location)) throw new Error("unsupported application path");
            found.push(pid + "\t" + location);
        } else if (args[0] === "quit" && pid === args[2]) {
            if (!application.terminate) throw new Error("application refused to quit");
        }
    }
    return found.join("\n");
}' "$1" "$APP_BUNDLE_ID" "${2:-}" 2>/dev/null
}

# running_apps prints PID<TAB>bundle-location records for all CatalEx copies.
running_apps() {
	app_control list || die "cannot identify running CatalEx copies; quit CatalEx from its menu and rerun"
}

tab="$(printf '\t')"
initial_running="$(running_apps)" || exit 1
if [ -n "$initial_running" ]; then
	locations="$(printf '%s\n' "$initial_running" | cut -f 2- | sort -u | wc -l | tr -d ' ')"
	if [ "$apps_dir_explicit" = 0 ] && [ "$locations" -gt 1 ]; then
		while IFS="$tab" read -r pid location; do
			say "Running CatalEx copy: $location"
		done <<RUNNING
$initial_running
RUNNING
		die "multiple CatalEx copies are running; choose the copy to manage with --apps-dir DIR (other app bundles are kept)"
	fi
	say "Managing CatalEx copy: $app"
	while IFS="$tab" read -r pid location; do
		[ "$location" = "$app" ] || say "Keeping unmanaged CatalEx copy: $location"
	done <<RUNNING
$initial_running
RUNNING
fi

# conflicting filters running copies (PID<TAB>location on stdin) to those that
# block this run: the target copy only when it is replaced, and every other
# copy only when the installer will open the app (#978).
conflicting() {
	awk -F '\t' -v keep="$app" -v replace="$replace" -v launch="$launch" \
		'($2 == keep && replace == 1) || ($2 != keep && launch == 1)'
}

# quit_apps asks only the selected process IDs to quit through macOS, then
# waits until the same selection is gone. New/restarted copies block replacement.
quit_apps() {
	while IFS="$tab" read -r pid location; do
		[ -n "$pid" ] || continue
		say "Quitting CatalEx: $location"
		app_control quit "$pid" || die "could not ask CatalEx at $location to quit; quit it from its menu and rerun"
	done <<RUNNING
$quit_running
RUNNING
	waited=0
	while :; do
		remaining="$(running_apps)" || exit 1
		remaining="$(printf '%s\n' "$remaining" | conflicting)"
		[ -n "$remaining" ] || break
		[ "$waited" -lt "$QUIT_WAIT_SECONDS" ] ||
			die "CatalEx is still running after ${QUIT_WAIT_SECONDS}s; quit it from its menu and rerun"
		sleep 1
		waited=$((waited + 1))
	done
}

# prepare_apps applies the existing quit authorization to every conflicting
# running copy. A current target copy is kept when no replacement is needed.
prepare_apps() {
	quit_running="$(running_apps)" || exit 1
	quit_running="$(printf '%s\n' "$quit_running" | conflicting)"
	[ -n "$quit_running" ] || return 0
	if [ "$yes" = 1 ]; then
		quit_apps
	elif [ "$interactive" = 1 ]; then
		printf 'CatalEx is running. Quit the conflicting copies to use %s? [y/N]: ' "$app" >&2
		IFS= read -r answer || answer=n
		case "$answer" in
		Y | y | yes | Yes | YES) quit_apps ;;
		*) die "CatalEx is running; quit it and rerun" ;;
		esac
	else
		die "CatalEx is running; quit it and rerun, or pass --yes to quit it"
	fi
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
dmg="CatalEx-$arch.dmg"
if [ -f "$work/latest.json" ] && ! grep -F "\"module\":\"$DESKTOP_MODULE\"" "$work/latest.json" | grep -qF "\"name\":\"$dmg\""; then
	die "release $version has no CatalEx app ($dmg); install the commands with install.sh"
fi

installed="$(app_version "$app")"
if [ -d "$app" ] && [ "$installed" = "$version" ]; then
	replace=0
	prepare_apps
	say "CatalEx $version is already installed in $apps_dir"
else
	say "Installing CatalEx $version into $apps_dir from $REPO ($source)"
	download SHA256SUMS
	download "$dmg"
	verify "$dmg"

	mount="$work/mount"
	mkdir -p "$mount"
	hdiutil attach "$work/$dmg" -nobrowse -noautoopen -readonly -mountpoint "$mount" -quiet ||
		{ mount=""; die "cannot open $dmg"; }
	[ -d "$mount/$APP_NAME" ] || die "$dmg holds no $APP_NAME"
	[ "$(app_version "$mount/$APP_NAME")" = "$version" ] ||
		die "$dmg holds CatalEx $(app_version "$mount/$APP_NAME"), not $version"

	replace=1
	prepare_apps

	# Copy beside the old app, then swap, so an interrupted copy never leaves
	# a half-written CatalEx.app.
	staged="$apps_dir/.$APP_NAME.installing"
	rm -rf "$staged"
	ditto "$mount/$APP_NAME" "$staged" || die "cannot copy $APP_NAME into $apps_dir"
	hdiutil detach "$mount" -quiet >/dev/null 2>&1 || true
	mount=""
	if [ -e "$app" ]; then
		old="$apps_dir/.$APP_NAME.replaced"
		rm -rf "$old"
		mv "$app" "$old" || die "cannot move the installed $APP_NAME aside"
		if ! mv "$staged" "$app"; then
			mv "$old" "$app"
			die "cannot install $APP_NAME into $apps_dir; the previous app is kept"
		fi
		rm -rf "$old"
	else
		mv "$staged" "$app"
	fi
	if [ -n "$installed" ]; then
		say "Replaced CatalEx $installed with $version: $app"
	else
		say "Installed CatalEx $version: $app"
	fi
fi

if [ "$launch" = 1 ]; then
	say "Opening CatalEx; its setup wizard installs the command-line tools."
	open "$app" || die "cannot open $app; open it from $apps_dir"
else
	say "Open CatalEx from $apps_dir when you are ready; its setup wizard installs the command-line tools."
fi
