#!/usr/bin/env bash
# test_helper.bash - shared setup/teardown for the wt-cleanup BATS suite

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"
REPO_BIN="${REPO_ROOT}/bin"

# _setup_common
# Call at the top of each test file's setup() function.
# Creates an isolated temp directory with a mock_bin/ for stubbing commands.
# mock_bin/ also gets a bash symlink so tests that restrict PATH to
# "mock_bin:/usr/bin:/bin" still find a bash new enough for the script
# (macOS's /bin/bash is 3.2).
_setup_common() {
  TEST_TMPDIR="$(mktemp -d)"
  mkdir -p "${TEST_TMPDIR}/mock_bin"
  ln -s "$(command -v bash)" "${TEST_TMPDIR}/mock_bin/bash"
}

# _teardown_common
# Call at the bottom of each test file's teardown() function.
_teardown_common() {
  rm -rf "${TEST_TMPDIR}"
}
