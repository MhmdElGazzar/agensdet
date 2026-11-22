#!/usr/bin/env bash
# Reads the machine and prints one JSON object. Read-only: it changes nothing.
#
#   bash detect.sh
#
# Fields: os (macos|windows|linux|unknown), osVersion, arch, shell, packageManager
# (homebrew|winget|null), node (version of the default node or null), fnm (version or null),
# fnmNode (version fnm has for the LTS major, or null), ltsMajor (number or null),
# language (from ~/.playwright-sdet/settings.json or null), supported (true|false), reason.
#
# Fake-machine mode (for evals): if EVAL_PSDET_MACHINE is set, nothing is read from the
# machine. The value is tokens joined by "+", for example "macos-15-homebrew-no-node+lang-en":
#   macos-<major> | windows-<10|11> | linux-<name>    the OS
#   homebrew | no-winget                              package manager (Windows has winget unless no-winget)
#   no-node | node-lts | node-old                     the default Node
#   lang-<code>                                       a saved language
# After a fake install (install-node.sh), ~/.playwright-sdet/fake-node holds the installed version.

set -u
STATE_DIR="$HOME/.playwright-sdet"
LTS_FAKE=24

json_str() { if [ -z "${1:-}" ]; then printf 'null'; else printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"; fi; }
json_num() { if [ -z "${1:-}" ]; then printf 'null'; else printf '%s' "$1"; fi; }

saved_language() {
  [ -f "$STATE_DIR/settings.json" ] && sed -n 's/.*"language"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$STATE_DIR/settings.json" | head -1
}

os=""; osVersion=""; arch=""; shell=""; pm=""; node=""; fnm=""; fnmNode=""; lts=""; language=""

if [ -n "${EVAL_PSDET_MACHINE:-}" ]; then
  IFS='+' read -r -a tokens <<< "$EVAL_PSDET_MACHINE"
  base="${tokens[0]}"
  case "$base" in
    macos-*)   os=macos;   osVersion="$(echo "$base" | cut -d- -f2).0"; arch=arm64; shell=zsh ;;
    windows-*) os=windows; v="$(echo "$base" | cut -d- -f2)"; [ "$v" = 11 ] && osVersion=10.0.22631 || osVersion=10.0.19045; arch=AMD64; shell=powershell; pm=winget ;;
    linux-*)   os=linux;   osVersion="$(echo "$base" | cut -d- -f2-)"; arch=x86_64; shell=bash ;;
  esac
  case "$base" in *homebrew*) pm=homebrew ;; esac
  case "$base" in *no-winget*) pm="" ;; esac
  case "$base" in *node-lts*) node="v$LTS_FAKE.11.1" ;; *node-old*) node="v18.20.4" ;; esac
  lts=$LTS_FAKE
  for t in "${tokens[@]:1}"; do case "$t" in lang-*) language="${t#lang-}" ;; esac; done
  if [ -f "$STATE_DIR/fake-node" ]; then
    route="$(cut -d' ' -f1 "$STATE_DIR/fake-node")"; ver="$(cut -d' ' -f2 "$STATE_DIR/fake-node")"
    if [ "$route" = fnm ]; then fnm="1.38.1"; fnmNode="$ver"; else node="$ver"; fi
  fi
  [ -z "$language" ] && language="$(saved_language)"
else
  case "$(uname -s)" in
    Darwin) os=macos; osVersion="$(sw_vers -productVersion 2>/dev/null)"; arch="$(uname -m)"; shell="$(basename "${SHELL:-zsh}")"
            command -v brew >/dev/null 2>&1 && pm=homebrew ;;
    MINGW*|MSYS*|CYGWIN*) os=windows
            osVersion="$(powershell.exe -NoProfile -Command '[Environment]::OSVersion.Version.ToString()' 2>/dev/null | tr -d '\r')"
            arch="${PROCESSOR_ARCHITECTURE:-}"; shell=powershell
            { command -v winget >/dev/null 2>&1 || command -v winget.exe >/dev/null 2>&1; } && pm=winget ;;
    Linux)  os=linux; osVersion="$( (. /etc/os-release 2>/dev/null && echo "$ID-$VERSION_ID") )"; arch="$(uname -m)"; shell="$(basename "${SHELL:-bash}")" ;;
    *)      os=unknown ;;
  esac
  command -v node >/dev/null 2>&1 && node="$(node --version 2>/dev/null | tr -d '\r')"
  FNM="$(command -v fnm 2>/dev/null || true)"
  [ -z "$FNM" ] && [ -n "${LOCALAPPDATA:-}" ] && [ -x "$LOCALAPPDATA/Microsoft/WinGet/Links/fnm.exe" ] && FNM="$LOCALAPPDATA/Microsoft/WinGet/Links/fnm.exe"
  [ -n "$FNM" ] && fnm="$("$FNM" --version 2>/dev/null | awk '{print $2}' | tr -d '\r')"
  # LTS major: first release in the official index whose "lts" is a name, not false.
  lts="$(curl -fsSL --max-time 20 https://nodejs.org/dist/index.json 2>/dev/null \
        | tr '{' '\n' | grep -m1 '"lts":"' | sed -n 's/.*"version":"v\([0-9]*\)\..*/\1/p')"
  if [ -n "$FNM" ] && [ -n "$lts" ]; then
    fnmNode="$("$FNM" list 2>/dev/null | grep -o "v$lts\.[0-9.]*" | head -1)"
  fi
  language="$(saved_language)"
fi

supported=true; reason=""
case "$os" in
  macos)   major="${osVersion%%.*}"; if [ -z "$major" ] || [ "$major" -lt 13 ]; then supported=false; reason="macOS 13 or later is needed"; fi ;;
  windows) build="$(echo "$osVersion" | cut -d. -f3)"; if [ -z "$build" ] || [ "$build" -lt 17763 ]; then supported=false; reason="Windows 10 version 1809 (build 17763) or later is needed"; fi ;;
  *)       supported=false; reason="This version supports macOS and Windows only" ;;
esac
[ -z "$lts" ] && [ "$supported" = true ] && reason="nodejs.org could not be reached"

printf '{"os":%s,"osVersion":%s,"arch":%s,"shell":%s,"packageManager":%s,"node":%s,"fnm":%s,"fnmNode":%s,"ltsMajor":%s,"language":%s,"supported":%s,"reason":%s}\n' \
  "$(json_str "$os")" "$(json_str "$osVersion")" "$(json_str "$arch")" "$(json_str "$shell")" "$(json_str "$pm")" \
  "$(json_str "$node")" "$(json_str "$fnm")" "$(json_str "$fnmNode")" "$(json_num "$lts")" "$(json_str "$language")" \
  "$supported" "$(json_str "$reason")"
