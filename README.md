# wt-cleanup

Interactive cleanup for [Worktrunk](https://worktrunk.dev) worktrees and branches. It shows
`wt list` in an [fzf](https://github.com/junegunn/fzf) picker with a preview pane, lets you mark
several entries with Tab, toggle the removal flags live, and runs one `wt remove` per marked entry.

```shell
cd ~/src/my-repo
wt-cleanup              # worktrees only
wt-cleanup --branches   # also branches that have no worktree
wt-cleanup --full       # include CI status, diffs and LLM summaries (slow)
```

## Requirements

- [Worktrunk](https://worktrunk.dev) (`wt`). Both JSON layouts of `wt list` are read: schema 2 (the default since 0.82) and the older bare-array schema 1.
- [fzf](https://github.com/junegunn/fzf)
- Ruby (standard library only)
- bash 4 or newer (macOS ships 3.2; `brew install bash`)

macOS and Linux are supported.

## Install

With Homebrew:

```shell
brew install chrisbloom7/tap/wt-cleanup
```

If Homebrew refuses to load the formula from an untrusted tap, run `brew trust chrisbloom7/tap` first.

From a checkout:

```shell
./install                  # links bin/wt-cleanup into ~/.local/bin
./install /usr/local/bin   # or another directory you can write to
./uninstall                # removes that link
```

## Usage

```
wt-cleanup [options] [-- <wt-args>...]

      --delete-branch   Initial: delete branch on remove (default: keep)
  -D, --force-delete    Initial: --force-delete on remove
  -f, --force           Initial: --force on remove
      --no-hooks        Initial: --no-hooks on remove
  -y, --yes             Skip confirmation prompt before removal
  -b, --branches        Include branches without worktrees (default: worktrees only)
      --full            Use `wt list --full` (CI, diff, LLM summaries — slow)
  -h, --help            Show help
```

Arguments after `--` are appended to each `wt remove` call, for example `--foreground`.
`wt-cleanup` operates on the repository in the current directory.

Keys inside the picker:

| Key | Action |
|---|---|
| Tab / Shift-Tab | mark / unmark (multi-select) |
| Enter | remove all marked entries (or the focused one if none are marked) |
| Alt-d | toggle delete-branch |
| Alt-Shift-D | toggle force-delete |
| Alt-f | toggle force |
| Alt-h | toggle no-hooks |
| ? | toggle preview pane |
| Esc | abort without changes |

By default the branch is kept (`wt remove --no-delete-branch`). Before removing anything it prints
the exact `wt remove` command and the selected entries, and asks for confirmation unless you pass
`--yes`.

## Development

```shell
./run-tests                                         # bats tests plus Ruby specs
./run-tests tests/bin/wt-cleanup.bats               # one file
./run-tests --filter "symlink"                      # tests matching a pattern
```

Tests need [bats-core](https://github.com/bats-core/bats-core) and Ruby. `wt` and `fzf` are stubbed,
so neither needs to be installed. The script resolves its helper (`libexec/wt-cleanup/`) relative
to its real path, following symlinks, so the same file works from a checkout, `./install` and a
Homebrew `libexec`.

## License

[MIT](LICENSE)
