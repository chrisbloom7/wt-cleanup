---
name: release-wt-cleanup
description: Use when releasing a new version of wt-cleanup — when the user asks to "cut a release", "release vX.Y.Z", "bump the version", "tag a release", "publish a new version", or "do a release".
---

# Release wt-cleanup

Release a new version of the wt-cleanup CLI: check preconditions, determine the version, audit help text and docs, date the CHANGELOG, commit on a release branch, open a PR, (after the user merges it) tag and push the tag, and then update the Homebrew tap formula.

This is a temporary copy adapted from the `release-towit` skill in the `to-wit` repo, until a shared release skill exists. The steps that were to-wit specific (plugin validation, `VERSION` file, docs-consistency test, homebrew-core thresholds) are removed. If you fix a step here, check whether `release-towit` needs the same fix.

Never run `wt merge` and never push `main`. All merges into `main` come from remote branches via PR, merged by the user.

## Step 0 — Preconditions

Verify all of the following before doing anything else. If any fails, **stop and report it**.

```bash
git branch --show-current                  # must be main
git status --porcelain                     # must be empty
git fetch origin && git status -sb         # main must not be behind (or ahead of) origin/main
./run-tests                                # full suite green (bats plus Ruby specs)
gh run list --branch main --limit 1 --json conclusion,workflowName   # latest CI on main is success
gh api repos/chrisbloom7/homebrew-tap/contents/Formula/wt-cleanup.rb -q .name   # informational
```

The last command is not a gate. If it returns 404, the formula is not on the tap's `main` yet (its first PR is unmerged), so Step 7 cannot bump anything: tell the user, and say the release will reach Homebrew only when that PR merges.

## Step 1 — Determine the Version

If the user provided an explicit version (e.g. `0.2.0`), use it. Otherwise:

1. Get the current version: `git tag --sort=-version:refname | head -1` → strip the leading `v`
2. Ask the user: **"What's the release level — major, minor, or patch?"** (or accept a literal `X.Y.Z`)
3. Compute the new version by incrementing the appropriate semver component. Reset lower components to `0`.

Tags use a `v` prefix: `v0.2.0`.

Validate the version before continuing (stop if any check fails):

1. It matches `^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$` (no leading `v`, no leading zeros, no pre-release or build suffix)
2. It is strictly greater than the latest tag (compare numerically per component, e.g. `sort -V`)
3. The tag is unused: `git tag -l vX.Y.Z` prints nothing and `git ls-remote --tags origin vX.Y.Z` is empty

Then create the release branch with `wt` (not `git worktree`) and do all remaining edits from the new worktree, never on `main`:

```bash
wt switch --create chore/release-vX.Y.Z --yes
```

Verify the `wt` hooks succeeded; if any failed, stop and report.

## Step 2 — Audit Help Text and Docs

wt-cleanup has no `VERSION` file: the version lives only in `CHANGELOG.md`, the tag and the tap formula.

### 2a — Validate `--help`

The help text is the leading comment block of `bin/wt-cleanup`. Run `bin/wt-cleanup --help` and compare it with the Usage section and the key table in `README.md`, and with the options the script actually parses.

Check for:
- Options or keys present in the implementation but missing from `--help` or the README
- Options or keys documented that no longer exist
- Defaults that contradict the implementation

If any discrepancies are found, **stop and fix them before proceeding**. Help text must match the implementation before a release is tagged.

### 2b — Audit README.md

Read `README.md` and compare it against the `## [Unreleased]` section of `CHANGELOG.md` and recent tagged releases.

Check for:
- New options, keys or behavior not documented
- Changed behavior (defaults, flag names) that contradicts the README
- The Requirements list (Worktrunk, fzf, Ruby, bash 4+) out of date
- The Install section: it says the Homebrew formula is available "once the formula is published". Once the tap PR for the formula has merged, that wording is stale; propose removing it

Present a brief audit summary. If nothing is out of date, say so explicitly. If issues are found, propose edits and wait for approval before editing `README.md`.

## Step 3 — Update CHANGELOG.md

1. Read `CHANGELOG.md`.
2. Confirm there is content under `## [Unreleased]`. If it's empty, warn the user before proceeding.
3. Replace `## [Unreleased]` with two sections:

```markdown
## [Unreleased]

## [X.Y.Z] - YYYY-MM-DD
```

Use today's date from `gdate +%F` (GNU date on macOS). Move all existing Unreleased content under the new version heading. Do not alter the content itself.

## Step 4 — Commit on the Release Branch

Never commit the release to `main`. From the release worktree, stage only the files that were changed (`CHANGELOG.md` always; `README.md` if edited, plus any `bin/wt-cleanup` help fix from Step 2a). Match the repo's earlier release commit:

```bash
git add CHANGELOG.md README.md   # drop README.md if unchanged; add bin/wt-cleanup if the help text was fixed
git commit -m "Release vX.Y.Z: date the changelog"
```

## Step 5 — Open the PR

Push the release branch (never `main`) and open a PR with `gh`. Follow the earlier release PR: title `Release vX.Y.Z`, a one-line body, and what happens after the merge.

```bash
git push -u origin chore/release-vX.Y.Z
gh pr create --base main --title "Release vX.Y.Z" --body "<CHANGELOG entry for vX.Y.Z>

After merging: tag vX.Y.Z on the merge commit, then bump the formula in chrisbloom7/homebrew-tap."
```

**Stop here.** The user reviews and merges the PR. Do not merge it yourself and do not use `wt merge`.

## Step 6 — Tag and Push the Tag

Only after the user confirms the PR is merged, go to the main worktree (`main` is checked out there, so `git switch main` fails in the release worktree):

```bash
git switch main && git pull --ff-only
git log -1 --oneline                      # confirm this is the merged release commit
```

Ask the user to confirm before pushing the tag. Then create an **annotated** tag on the merged commit (the repo's `v0.1.0` is annotated) and push **only the tag**:

```bash
git tag -a vX.Y.Z -m "wt-cleanup X.Y.Z"
git push origin vX.Y.Z
```

Confirm each command succeeded. Report the tag name and the commit SHA it points to.

Then verify the tag tarball that the formula will download exists:

```bash
curl -fsIL "https://github.com/chrisbloom7/wt-cleanup/archive/refs/tags/vX.Y.Z.tar.gz" | head -1   # must be HTTP 200
```

## Step 7 — Update the Homebrew Tap

The formula lives in a separate repository, `chrisbloom7/homebrew-tap` (`Formula/wt-cleanup.rb`, tap name `chrisbloom7/tap`). Nothing updates it automatically on release (the tap's daily autobump may open the same PR on its own; if it has, use that PR instead of opening a second). Do this right after the tag is pushed, and ask the user before pushing or opening the tap PR.

If `Formula/wt-cleanup.rb` is not on the tap's `main` (Step 0), stop here: the first formula PR has to merge first.

The tap's local checkout is Homebrew's own: `$(brew --repository chrisbloom7/tap)`. If it is not tapped, run `brew tap chrisbloom7/tap` first.

1. Make sure the tap checkout is clean and on `main`, then branch it (this is a normal branch, not a worktree):

```bash
TAP="$(brew --repository chrisbloom7/tap)"
git -C "${TAP}" switch main && git -C "${TAP}" pull --ff-only
git -C "${TAP}" switch -c wt-cleanup-X.Y.Z
```

2. Rewrite the formula's `url` and `sha256` for the new tag (this downloads the tag tarball; it never runs git or commits):

```bash
.claude/skills/release-wt-cleanup/bump-tap-formula X.Y.Z --tap-dir "${TAP}"
```

3. Verify the formula and show the diff to the user:

```bash
brew style chrisbloom7/tap/wt-cleanup
brew reinstall chrisbloom7/tap/wt-cleanup && brew test chrisbloom7/tap/wt-cleanup
brew audit --strict --online chrisbloom7/tap/wt-cleanup
git -C "${TAP}" diff
```

4. After the user approves the diff, commit and open the tap PR (the commit message and title are `wt-cleanup X.Y.Z`, matching earlier tap PRs). The user merges it; the tap's own CI (`brew test-bot`) runs on the PR.

```bash
git -C "${TAP}" commit -am "wt-cleanup X.Y.Z"
git -C "${TAP}" push -u origin wt-cleanup-X.Y.Z
gh pr create -R chrisbloom7/homebrew-tap --base main --head wt-cleanup-X.Y.Z --title "wt-cleanup X.Y.Z" --body "Bump wt-cleanup to vX.Y.Z"
```

5. After the user confirms the tap PR is merged: `git -C "${TAP}" switch main && git -C "${TAP}" pull --ff-only`, delete the branch, then `brew update && brew upgrade wt-cleanup` and confirm `wt-cleanup --help` prints its usage.

Use `command cp -f` / `command rm -f` for any manual file replacement: `cp` and `rm` are interactive-aliased on the maintainer's machine and silently skip when there is no TTY.

## Done

Summarize: version released, release PR, tag pushed, tap PR (and whether it is merged), and any README or help-text changes made.
