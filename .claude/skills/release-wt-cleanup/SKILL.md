---
name: release-wt-cleanup
description: Use when releasing a new version of wt-cleanup - "cut a release", "release vX.Y.Z", "bump the version", "tag a release", "publish a new version".
---

# Release wt-cleanup

Use the `chrisbloom7-development:release` skill with the parameters below. That skill holds the
generic steps and the safety rules (never `wt merge`, never push `main`, the owner merges the release
PR, confirm before pushing the tag). If it is not available, stop and tell the owner to install it
(`/plugin marketplace add chrisbloom7/ai-tools`, then install `chrisbloom7-development`).

## Release parameters

- project: wt-cleanup
- flow: release-branch; base_branch: main
- preconditions: `./run-tests` green (bats plus Ruby specs); `gh run list --branch main --limit 1 --json conclusion,workflowName` shows success
- informational: `gh api repos/chrisbloom7/homebrew-tap/contents/Formula/wt-cleanup.rb -q .name`. A 404 means the formula is not on the tap's `main`, so the tap bump cannot run: tell the owner.
- version_file: none (the version lives only in CHANGELOG.md, the tag and the tap)
- tag_style: annotated, `git tag -a vX.Y.Z -m "wt-cleanup X.Y.Z"`
- commit_message: `Release vX.Y.Z: date the changelog`; pr_title: `Release vX.Y.Z`; branch `chore/release-vX.Y.Z`
- pr_body_extra: "After merging: tag vX.Y.Z on the merge commit, then bump the formula in chrisbloom7/homebrew-tap."
- audit:
  - (blocking) `bin/wt-cleanup --help` (the leading comment block) vs the README Usage section and key table, and the options the script parses.
  - (advisory, propose edits and wait for approval) README vs `[Unreleased]`. Check that the Requirements list (Worktrunk, fzf, Ruby, bash 4+) and the Install section (Homebrew command, the `brew trust` note) are current.
- post_tag:
  1. `curl -fsIL https://github.com/chrisbloom7/wt-cleanup/archive/refs/tags/vX.Y.Z.tar.gz | head -1` must be HTTP 200.
  2. Tap bump: formula `wt-cleanup`, repo `chrisbloom7/wt-cleanup`; stop if the formula is not on the tap's `main`. After the tap merge, `brew update && brew upgrade wt-cleanup` and confirm `wt-cleanup --help` prints its usage.
