# CLAUDE.md

`wt-cleanup` is an fzf picker for removing [Worktrunk](https://worktrunk.dev) worktrees and branches:
it shows `wt list`, lets you mark several entries, and runs one `wt remove` per mark. A bash front end
plus a Ruby helper (standard library only). macOS and Linux.

## Commands

```bash
./run-tests                                   # bats tests plus Ruby specs
./run-tests tests/bin/wt-cleanup.bats         # one bats file
./run-tests tests/helpers/wt_cleanup_helper_spec.rb   # one Ruby spec (plain `ruby`, minitest)
./run-tests --filter "symlink"                # tests matching a pattern
./install [dir]                               # link bin/wt-cleanup into ~/.local/bin (or dir)
./uninstall
```

Needs `bats-core` (`brew install bats-core`; override the path with `BATS_BIN`), `ruby`, `fzf`, `wt`
and bash 4+ (macOS ships 3.2: `brew install bash`).

## Architecture

- `bin/wt-cleanup`: the bash dispatcher. It resolves its own path through symlinks, so it works from
  `./install`, a Homebrew `libexec` and a plain checkout. Its leading comment block is the `--help`
  text, so keep that block and the README usage section in step.
- `libexec/wt-cleanup/wt_cleanup_helper.rb`: parsing and formatting for the picker and preview.
- `tests/bin/wt-cleanup.bats` (CLI) and `tests/helpers/wt_cleanup_helper_spec.rb` (helper);
  `tests/test_helper.bash` is the shared bats setup.

## Gotchas

- Bash 4+ only. Do not use features that need newer than 4, and do not assume the system `/bin/bash`.
- Ruby specs run with plain `ruby <file>`, not rspec. `./run-tests` runs both suites and exits non-zero
  if either fails.
- CI (`.github/workflows/ci.yml`) runs on macOS and Linux and includes an install smoke test. Actions
  are pinned by commit SHA with a version comment; keep that when editing workflows.
- Keep `CHANGELOG.md` current under `[Unreleased]`. Releases go through a `chore/release-vX.Y.Z` PR,
  then a `vX.Y.Z` tag after the merge. The Homebrew formula lives in `chrisbloom7/homebrew-tap` and is
  bumped there, not here.
- The default branch is `main`; changes go through PRs.

## Claude Code setup

`.claude/settings.json` allows `./run-tests` and registers `syntax-check.sh`, a hook that runs
`bash -n` on edited shell files and `ruby -c` on edited `.rb` files. It skips quietly when a needed
tool is missing.

Changes to `.claude/` (hooks and the allowlist) and to this file run or steer Claude Code on the machine
of whoever opens the repo, so `.github/CODEOWNERS` routes them to the maintainer. When reviewing an
outside PR that touches them, read the diff first (`gh pr diff <number> -- .claude CLAUDE.md`) before
checking the branch out and starting Claude Code there.
