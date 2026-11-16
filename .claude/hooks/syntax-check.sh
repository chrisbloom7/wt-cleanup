#!/usr/bin/env bash
# PostToolUse hook: syntax-check an edited shell or Ruby file (bash -n, ruby -c), and run
# `shellcheck -S error` on edited bash files. Skips quietly when jq or a checker is missing, so it
# never blocks a contributor without them.
set -uo pipefail
is_bash=0

command -v jq >/dev/null 2>&1 || exit 0

file="$(jq -r '.tool_input.file_path // empty')"
[ -f "${file}" ] || exit 0

case "${file}" in
  *.rb)
    command -v ruby >/dev/null 2>&1 || exit 0
    checker=(ruby -c) ;;
  *.sh | *.bash | */bin/wt-cleanup | */install | */uninstall | */run-tests)
    checker=(bash -n)
    is_bash=1 ;;
  *) exit 0 ;;
esac

if ! output="$("${checker[@]}" "${file}" 2>&1)"; then
  printf 'Syntax error in %s (%s):\n%s\n' "${file}" "${checker[*]}" "${output}" >&2
  exit 2
fi

if [ "${is_bash}" = 1 ] && command -v shellcheck >/dev/null 2>&1; then
  if ! output="$(shellcheck -S error "${file}" 2>&1)"; then
    printf 'shellcheck errors in %s:\n%s\n' "${file}" "${output}" >&2
    exit 2
  fi
fi
exit 0
