# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Unreleased
(nothing yet!)

## [0.3.0] - 2022-09-09
### Changed
- `FileStructure#path_for` is more efficient and the API is simpler, expecting
the argument to be a relative path instead of a list of recursive names.
- `FileStructure#mount` does not handle cleaning "residuals" anymore and
requires the target directory to be empty upon mounting.

## [0.2.0] - 2022-03-05
### Added
- New DSL to more easily describe file structure (`FileStructure::DSL`).
- New method `FileStructure.build` to use the DSL.
### Fixed
- Incorrect error handling preventing cleaning of residual files when `FileStructure#mount` fails.

## [0.1.0] - 2022-02-26
### Added
- Initial working set of functionalities.

[Unreleased]: https://github.com/durierem/file_structure/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/durierem/file_structure/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/durierem/file_structure/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/durierem/file_structure/releases/tag/v0.1.0
