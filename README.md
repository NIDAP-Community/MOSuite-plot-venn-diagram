# MOSuite-plot-venn-diagram

Code Ocean capsule: MOSuite - Plot Venn Diagram

[![tests](https://github.com/NIDAP-Community/MOSuite-plot-venn-diagram/actions/workflows/tests.yml/badge.svg)](https://github.com/NIDAP-Community/MOSuite-plot-venn-diagram/actions/workflows/tests.yml)

- [Code Ocean Capsule](https://poc-nci.codeocean.io/capsule/0361730/tree) | [Latest Release](https://poc-nci.codeocean.io/capsule/5013652/tree/latest)
- [MOSuite R package docs](https://ccbr.github.io/MOSuite/)

## DEG inputs

Attach a MOSuite DEG MOO (`.rds`) or the wide `DEG_Analysis.csv` emitted by
[OMIX DEG Analysis](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-DEG-Analysis).
No counts or sample metadata are required.

- `--input_type`: `auto` (default), `moo`, or `table`. Auto prefers exactly
  one RDS; otherwise it discovers one `DEG_Analysis.csv`, `.tsv`, or `.txt`
  recursively. Companion metadata and count tables are not DEG inputs.
- `--input_file`: optional explicit selector for a differently named table
  or ambiguous inputs. Select `table` to use CSV when both formats are mounted.
- Default settings require unique feature IDs and contrast-prefixed `FC`,
  `logFC`, `tstat`, `pval`, and `adjpval` statistics. The first column is the default feature ID;
  override with `--feature_id_colname`.

Both routes use the existing volcano-summary step to select significant
feature memberships, then render Venn/intersection plots. This preserves the
existing default strict thresholds (adjusted p-value < 0.05 and
absolute log2 fold change > 1); `--select_contrasts` still selects memberships
for named contrasts. There is no new DEG modeling or count processing.
Plot and `results/moo/venn_diagram_data.csv` output paths are unchanged.

## Validation and maintenance

Run `Rscript tests/testthat.R` from the repository root. Tests cover actual
MOO/table plotting and output-table parity, ambiguity and invalid inputs.
Code Ocean validation remains required before release.

`code/deg-input.R` is capsule-owned and shared verbatim with the two Volcano
and Filter Differential Expression capsules. Keep copies and input tests
synchronized.

**Temporary managed-source exception:** the vendored
`code/MOSuite/R/plot_venn_diagram.R` has a three-line `drop = FALSE` patch so
identical significant-gene sets do not crash intersection-summary generation.
The canonical local MOSuite branch `fix/venn-single-intersection` contains the
same fix and a regression test. The existing source lock still identifies the
unpatched baseline, not a newly released version. Before capsule release,
merge/release the upstream fix and update the source through SyncWeaver.
A sync to the current pin would overwrite this temporary patch.
