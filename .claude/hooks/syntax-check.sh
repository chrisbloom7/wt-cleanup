#!/usr/bin/env bash
# PostToolUse hook: syntax-check an edited shell or Ruby file (bash -n, ruby -c).
# Skips quietly when jq or the checker is missing, so it never blocks a contributor without them.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

file="$(jq -r '.tool_input.file_path // empty')"
[ -f "${file}" ] || exit 0

case "${file}" in
  *.rb)
    command -v ruby >/dev/null 2>&1 || exit 0
    checker=(ruby -c) ;;
  *.sh | *.bash | */bin/wt-cleanup | */install | */uninstall | */run-tests)
    checker=(bash -n) ;;
  *) exit 0 ;;
esac

if ! output="$("${checker[@]}" "${file}" 2>&1)"; then
  printf 'Syntax error in %s (%s):\n%s\n' "${file}" "${checker[*]}" "${output}" >&2
  exit 2
fi
exit 0
