#!/usr/bin/env bash
# Runs a command in the project folder with the project's Node.
#
#   bash run.sh <project-dir> <command> [args...]      for example: bash run.sh ~/tests npx playwright test
#
# If ~/.playwright-sdet/machine.json says nodeRoute is "fnm", the command runs through
# `fnm exec --using=<major>` with the major from the project's .nvmrc; otherwise it runs as is.
# Fake-machine mode (EVAL_PSDET_MACHINE set): prints the command and runs nothing.

set -u
dir="${1:?project dir}"; shift
[ $# -eq 0 ] && { echo "usage: run.sh <project-dir> <command> [args...]" >&2; exit 2; }

if [ -n "${EVAL_PSDET_MACHINE:-}" ]; then
  echo "FAKE (in $dir): $*"
  exit 0
fi

cd "$dir" || { echo "Folder not found: $dir" >&2; exit 2; }
route="$(sed -n 's/.*"nodeRoute"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.playwright-sdet/machine.json" 2>/dev/null | head -1)"

if [ "$route" = fnm ]; then
  FNM="$(command -v fnm 2>/dev/null || true)"
  [ -z "$FNM" ] && [ -n "${LOCALAPPDATA:-}" ] && FNM="$LOCALAPPDATA/Microsoft/WinGet/Links/fnm.exe"
  [ -z "$FNM" ] && for p in /opt/homebrew/bin/fnm /usr/local/bin/fnm; do [ -x "$p" ] && FNM="$p"; done
  major="$(tr -d ' \r\n' < .nvmrc 2>/dev/null)"
  exec "$FNM" exec --using="${major:?no .nvmrc in $dir}" "$@"
else
  exec "$@"
fi
