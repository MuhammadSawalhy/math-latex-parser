# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-01-07

### Breaking Changes
- **Operator Precedence**: Unary prefix operators (`+`, `-`, `\pm`, etc.) now bind tighter than multiplication.
  - Example: `-a * b` is now parsed as `(-a) * b` instead of `-(a * b)`.
- **API Change**: `Node.prototype.hasChild` and `Node.prototype.hasChildR` have been removed in favor of `Node.prototype.contains`.
- **Renamed Option**: `keepParen` parser option has been renamed to `keepParentheses`.
- **Internal Grammar**: All grammar rules were refactored to use PascalCase (e.g., `Operation1` -> `AdditionAndSubtraction`).

### Added
- **New Prefix Operators**: Added support for `\pm`, `\mp`, `\neg`, and `\lnot` in prefix positions.
- **Recursive Prefix Support**: Support for multiple prefix operators like `--x`.
- **Improved Validation**: Added more robust checks for built-in TeX operators.

## [2.2.2] - 2026-01-07
### Changed
- Minor bug fixes and security updates.

## [2.2.1] - 2026-01-07
### Changed
- Internal release updates.

## [2.2.0] - 2021-02-01
### Added
- Enhanced `Node.prototype.check`.
- Fixed `\operatorname` issues.

## [2.1.1] - 2021-02-01
### Fixed
- Parcel bundler configuration fixes.

## [2.1.0] - 2021-02-01
### Added
- Support for browser-side bundling.

## [2.0.0] - 2021-02-01
### Breaking
- Remove `options.operatorNames`.
- Remove `options.singleCharName`.
- Rename `builtIn` to `builtin` (e.g., `builtinFunctions`).
- `builtInControlSeq` renamed to `builtinLetters`.

### Added
- `Node.prototype.hasChild` and `Node.prototype.hasChildR`.
- New AST Nodes: `"member expression"`, `"set"`, `"tuple"`.
- `options.extra` features.

## [1.2.1] - 2020-10-25
### Fixed
- Fix issue (#1).

## [1.2.0] - 2020-10-22
### Fixed
- Catch error more precisely when unexpected block closing char found.
