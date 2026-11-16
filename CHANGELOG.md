# Code Ocean capsule - MOSuite - Plot Venn Diagram

## Development version

- Accept OMIX DEG CSV/TSV/TXT alongside MOO input, with MOO-first automatic
  discovery and explicit input type/file controls.
- Reuse the existing DEG summary-to-membership path for both input formats.
- Add MOO/table CLI parity tests, including identical contrast memberships.
- Temporarily patch the vendored Venn function to preserve table dimensions
  for a single intersection. The same fix is in the canonical local MOSuite
  branch `fix/venn-single-intersection`; upstream release and SyncWeaver update
  remain required before capsule release.

## v4.0

- Use MOSuite v0.5.0. (#12, @kelly-sovacool)

## v3.0

- Sync Code Ocean app panel parameter descriptions with MOSuite package documentation for MOSuite v0.4.1 (#6, @phoman14).
- Improved the Code Ocean parameter UI for the plot venn diagram capsule. (#2, @phoman14)

## v2.0

- Use MOSuite v0.3.0.
- Fix: remove `regex_moo` parameter from configuration. multiOmicDataSet input files are now required to follow the standardized naming pattern (`.*\.rds$`).

## v1.0

Initial release

<https://poc-nci.codeocean.io/capsule/5013652/tree/v1> `6af2942`
