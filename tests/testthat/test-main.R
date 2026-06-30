test_that("Code Ocean panel uses named parameters accepted by main.R", {
  main_args <- extract_main_arguments(read_repo_file("code", "main.R"))
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")
  panel_args <- extract_panel_param_names(panel_lines)

  expect_true(
    any(grepl('"named_parameters"[[:space:]]*:[[:space:]]*true', panel_lines)),
    info = "Code Ocean should pass parameters by name to main.R"
  )
  expect_same_values(panel_args, main_args)
})

test_that("Venn diagram capsule keeps expected CLI parameter contract", {
  main_lines <- read_repo_file("code", "main.R")
  main_text <- paste(main_lines, collapse = "\n")

  expected_args <- c(
    "feature_id_colname",
    "contrasts_colname",
    "select_contrasts",
    "plot_type",
    "intersection_ids",
    "venn_force_unique",
    "venn_numbers_format",
    "venn_significant_digits",
    "venn_fill_colors",
    "venn_fill_transparency",
    "venn_border_colors",
    "venn_font_size_for_category_names",
    "venn_category_names_distance",
    "venn_category_names_position",
    "venn_font_size_for_counts",
    "venn_outer_margin",
    "intersections_order",
    "display_empty_intersections",
    "intersection_bar_color",
    "intersection_point_size",
    "intersection_line_width",
    "table_font_size",
    "table_content",
    "image_width",
    "image_height",
    "dpi",
    "plot_filename"
  )

  expect_same_values(extract_main_arguments(main_lines), expected_args)
  expect_match(main_text, "plot_volcano_summary\\(")
  expect_match(main_text, "plot_venn_diagram\\(")
  expect_match(main_text, "select_contrasts = parse_optional_vector\\(args\\$select_contrasts\\)")
  expect_match(main_text, "intersection_ids = parse_numeric_vector\\(args\\$intersection_ids\\)")
  expect_match(main_text, "readr::write_csv\\(")
  expect_match(main_text, "venn_diagram_data\\.csv")
})

test_that("numeric vector parser handles Venn optional numeric fields", {
  main_lines <- read_repo_file("code", "main.R")
  parser_start <- grep("^parse_numeric_vector <- function", main_lines)
  parser_end <- grep("^# set up capsule environment", main_lines) - 1
  parser_lines <- main_lines[parser_start:parser_end]
  eval(parse(text = paste(parser_lines, collapse = "\n")))

  expect_null(parse_numeric_vector(NULL))
  expect_null(parse_numeric_vector(""))
  expect_null(parse_numeric_vector(" , "))
  expect_equal(parse_numeric_vector("1, 2.5,3"), c(1, 2.5, 3))
  expect_error(parse_numeric_vector("1,nope"), "non-numeric")
})

test_that("Code Ocean panel preserves Venn diagram defaults", {
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")

  expect_equal(extract_panel_default(panel_lines, "contrasts_colname"), "Contrast")
  expect_equal(extract_panel_default(panel_lines, "plot_type"), "Venn diagram")
  expect_equal(extract_panel_default(panel_lines, "venn_numbers_format"), "raw")
  expect_equal(extract_panel_default(panel_lines, "venn_fill_colors"), "darkgoldenrod2,darkolivegreen2,mediumpurple3,darkorange2,lightgreen")
  expect_equal(extract_panel_default(panel_lines, "venn_border_colors"), "fill colors")
  expect_equal(extract_panel_default(panel_lines, "intersections_order"), "degree")
  expect_equal(extract_panel_default(panel_lines, "table_content"), "all intersections")
  expect_equal(extract_panel_default(panel_lines, "plot_filename"), "venn_diagram.png")
})

test_that("Code Ocean boolean controls are TRUE/FALSE lists", {
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")

  expect_boolean_list_parameter(panel_lines, "venn_force_unique", "TRUE")
  expect_boolean_list_parameter(panel_lines, "display_empty_intersections", "FALSE")
})

test_that("run wrapper prepares result directories and forwards CLI arguments", {
  run_lines <- read_repo_file("code", "run")
  run_text <- paste(run_lines, collapse = "\n")

  expect_match(run_text, "mkdir -p \\.\\./results/figures \\.\\./results/moo")
  expect_match(run_text, 'Rscript main\\.R "\\$@"')
})