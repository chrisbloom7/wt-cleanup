# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Works with Worktrunk 0.82 and newer. `wt list --format json` now returns an object with an `items` array (JSON schema 2) instead of a bare array, which made the picker crash with a `TypeError`. Both layouts are read, so older Worktrunk keeps working.

### Known limitations

- Worktrunk's schema 2 has no field for an upstream branch that was deleted on the remote, so such a branch shows as `local` instead of `gone`. Schema 1 output still shows `gone`.

## [0.1.0] - 2026-11-15

### Added

- First standalone release, extracted from the author's dotfiles with its history. `./install` links `wt-cleanup` into `~/.local/bin`.

### Changed

- The command is now `wt-cleanup` (was `wt_cleanup`).
- Resolves its helper through symlinks, so it works from `./install`, a Homebrew `libexec` and a plain checkout.
- Logs through built-in functions instead of the dotfiles' `log_*` commands. Colors are off when stdout is not a terminal or `NO_COLOR` is set.
- Exits with a clear error on bash older than 4 (macOS ships 3.2).
