#!/usr/bin/env bash
# Installs Node by one route (ADR-0004). Run only after the tester approved the list.
#
#   bash install-node.sh fnm <major>               fnm per user, then Node <major>; adds the shell line
#   bash install-node.sh nodejs-installer <major>  downloads the nodejs.org installer and opens it
#
# Prints progress lines, then a last line of JSON: {"route":...,"ok":true|false,"message":...}.
# On the fnm route the machine's default Node is left as it was.
# Fake-machine mode (EVAL_PSDET_MACHINE set): prints what it would run, runs nothing, and records
# the result in ~/.playwright-sdet/fake-node so detect.sh sees it.

set -u
route="${1:-}"; major="${2:-}"
STATE_DIR="$HOME/.playwright-sdet"
mkdir -p "$STATE_DIR"

done_json() { printf '{"route":"%s","ok":%s,"message":"%s"}\n' "$route" "$1" "$(printf '%s' "$2" | sed 's/"/\\"/g')"; exit 0; }
[ -z "$route" ] || [ -z "$major" ] && { echo "usage: install-node.sh fnm|nodejs-installer <major>" >&2; exit 2; }

case "$(uname -s)" in Darwin) os=macos ;; MINGW*|MSYS*|CYGWIN*) os=windows ;; *) os=other ;; esac

if [ -n "${EVAL_PSDET_MACHINE:-}" ]; then
  case "$EVAL_PSDET_MACHINE" in windows-*) os=windows ;; macos-*) os=macos ;; esac
  case "$route" in
    fnm)
      if [ "$os" = windows ]; then echo "FAKE: winget install --id Schniz.fnm -e"; echo "FAKE: fnm install $major"; echo "FAKE: add fnm line to \$PROFILE"
      else echo "FAKE: brew install fnm"; echo "FAKE: fnm install $major"; echo "FAKE: add fnm line to ~/.zshrc"; fi ;;
    nodejs-installer) echo "FAKE: download and open the nodejs.org installer for v$major" ;;
  esac
  echo "$route v$major.11.1" > "$STATE_DIR/fake-node"
  done_json true "fake install done"
fi

# Exact version of the latest release of this major, from the official index.
version="$(curl -fsSL --max-time 30 https://nodejs.org/dist/index.json 2>/dev/null | tr '{' '\n' \
          | grep -m1 "\"version\":\"v$major\." | sed -n 's/.*"version":"\(v[0-9.]*\)".*/\1/p')"
[ -z "$version" ] && done_json false "nodejs.org could not be reached"

fnm_bin() {
  command -v fnm 2>/dev/null && return
  [ -n "${LOCALAPPDATA:-}" ] && [ -x "$LOCALAPPDATA/Microsoft/WinGet/Links/fnm.exe" ] && echo "$LOCALAPPDATA/Microsoft/WinGet/Links/fnm.exe" && return
  [ -x /opt/homebrew/bin/fnm ] && echo /opt/homebrew/bin/fnm && return
  [ -x /usr/local/bin/fnm ] && echo /usr/local/bin/fnm
}

add_line() { # file line
  touch "$1"; grep -qF "$2" "$1" 2>/dev/null || printf '\n# Added by Playwright SDET: Node version per project (fnm)\n%s\n' "$2" >> "$1"
}

case "$route" in
  fnm)
    had_node=""; command -v node >/dev/null 2>&1 && had_node=yes
    if [ -z "$(fnm_bin)" ]; then
      if [ "$os" = windows ]; then
        echo "Installing fnm with winget..."
        winget.exe install --id Schniz.fnm -e --source winget --accept-package-agreements --accept-source-agreements || done_json false "winget could not install fnm"
      else
        echo "Installing fnm with Homebrew..."
        brew install fnm || done_json false "Homebrew could not install fnm"
      fi
    fi
    FNM="$(fnm_bin)"; [ -z "$FNM" ] && done_json false "fnm was installed but can't be found"
    echo "Installing Node $version with fnm..."
    "$FNM" install "$major" || done_json false "fnm could not install Node $major"
    # Keep the machine's default Node: if one was there before fnm, point fnm's default back to it.
    [ -n "$had_node" ] && { "$FNM" default system 2>/dev/null || echo "Note: could not set fnm's default to the system Node"; }
    if [ "$os" = windows ]; then
      profile="$(powershell.exe -NoProfile -Command '$PROFILE' | tr -d '\r')"
      profile_unix="$(cygpath -u "$profile" 2>/dev/null || echo "$profile")"
      mkdir -p "$(dirname "$profile_unix")"
      add_line "$profile_unix" 'fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression'
      echo "Added the fnm line to $profile"
    else
      case "$(basename "${SHELL:-zsh}")" in
        bash) add_line "$HOME/.bashrc" 'eval "$(fnm env --use-on-cd --shell bash)"'; echo "Added the fnm line to ~/.bashrc" ;;
        *)    add_line "${ZDOTDIR:-$HOME}/.zshrc" 'eval "$(fnm env --use-on-cd --shell zsh)"'; echo "Added the fnm line to ~/.zshrc" ;;
      esac
    fi
    done_json true "Node $version installed with fnm"
    ;;
  nodejs-installer)
    if [ "$os" = windows ]; then
      case "${PROCESSOR_ARCHITECTURE:-AMD64}" in ARM64) a=arm64 ;; *) a=x64 ;; esac
      file="node-$version-$a.msi"; dest="${TEMP:-/tmp}/$file"
    else
      file="node-$version.pkg"; dest="/tmp/$file"
    fi
    echo "Downloading $file..."
    curl -fL --max-time 600 -o "$dest" "https://nodejs.org/dist/$version/$file" || done_json false "could not download $file"
    if [ "$os" = windows ]; then cmd.exe //c start "" "$(cygpath -w "$dest" 2>/dev/null || echo "$dest")"; else open "$dest"; fi
    done_json true "The installer is open. The tester finishes it (admin password), then says done."
    ;;
  *) echo "unknown route: $route" >&2; exit 2 ;;
esac
