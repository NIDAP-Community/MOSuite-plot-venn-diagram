test_that("Venn diagram capsule keeps expected CLI parameter contract", {
  main_lines <- read_repo_file("code", "main.R")
  main_text <- paste(main_lines, collapse = "\n")

  expected_args <- c(
    "feature_id_colname",
    "signif_colname",
    "signif_threshold",
    "change_colname",
    "change_threshold",
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
  expect_same_values(
    extract_panel_param_names(read_repo_file(".codeocean", "app-panel.json")),
    expected_args
  )
  expect_false(grepl("plot_volcano_summary\\(", main_text))
  expect_match(main_text, "plot_venn_diagram\\(")
  expect_match(
    main_text,
    "venn_result <- plot_venn_diagram\\(\\s*moo,",
    perl = TRUE
  )
  expect_match(
    main_text,
    "select_contrasts = parse_character_vector\\(args\\$select_contrasts\\)"
  )
  expect_match(
    main_text,
    "intersection_ids = parse_numeric_vector\\(args\\$intersection_ids\\)"
  )
  expect_match(main_text, "readr::write_csv\\(")
  expect_match(main_text, "venn_diagram_data\\.csv")
})

test_that("character vector parser handles optional contrast subsets", {
  main_lines <- read_repo_file("code", "main.R")
  parser_start <- grep("^parse_character_vector <- function", main_lines)
  parser_end <- grep("^# parse comma-separated numeric vectors", main_lines) - 1
  parser_lines <- main_lines[parser_start:parser_end]
  eval(parse(text = paste(parser_lines, collapse = "\n")))

  expect_null(parse_character_vector(NULL))
  expect_null(parse_character_vector(""))
  expect_null(parse_character_vector(" , "))
  expect_equal(
    parse_character_vector("B-A, C-A,B-A"),
    c("B-A", "C-A")
  )
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

test_that("Code Ocean boolean controls are TRUE/FALSE lists", {
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")

  expect_boolean_list_parameter(panel_lines, "venn_force_unique", "TRUE")
  expect_boolean_list_parameter(
    panel_lines,
    "display_empty_intersections",
    "FALSE"
  )
})

test_that("Code Ocean panel exposes direct DEG controls", {
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")
  panel_parameters <- extract_panel_param_names(panel_lines)

  expect_false("contrasts_colname" %in% panel_parameters)
  expect_equal(extract_panel_default(panel_lines, "signif_colname"), "adjpval")
  expect_equal(extract_panel_default(panel_lines, "signif_threshold"), "0.05")
  expect_equal(extract_panel_default(panel_lines, "change_colname"), "logFC")
  expect_equal(extract_panel_default(panel_lines, "change_threshold"), "1.0")
  expect_true("select_contrasts" %in% panel_parameters)
})

test_that("capsule uses all DEG contrasts when selection is blank", {
  workspace <- setup_cli_workspace()
  on.exit(unlink(workspace$workspace, recursive = TRUE), add = TRUE)

  output <- withr::with_dir(
    workspace$code_dir,
    system2(
      "Rscript",
      c("main.R", common_cli_args, "--select_contrasts="),
      stdout = TRUE,
      stderr = TRUE
    )
  )

  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
  expect_outputs_created(workspace$results_dir)
  result <- readr::read_csv(
    file.path(workspace$results_dir, "moo", "venn_diagram_data.csv"),
    show_col_types = FALSE
  )
  expect_true(any(grepl("B-C", result$Intersection, fixed = TRUE)))
})

test_that("capsule accepts a comma-separated DEG contrast subset", {
  workspace <- setup_cli_workspace()
  on.exit(unlink(workspace$workspace, recursive = TRUE), add = TRUE)

  output <- withr::with_dir(
    workspace$code_dir,
    system2(
      "Rscript",
      c(
        "main.R",
        common_cli_args,
        shQuote("--select_contrasts=B-A, C-A")
      ),
      stdout = TRUE,
      stderr = TRUE
    )
  )

  expect_null(attr(output, "status"), info = paste(output, collapse = "\n"))
  expect_outputs_created(workspace$results_dir)
  result <- readr::read_csv(
    file.path(workspace$results_dir, "moo", "venn_diagram_data.csv"),
    show_col_types = FALSE
  )
  expect_false(any(grepl("B-C", result$Intersection, fixed = TRUE)))
})

test_that("capsule reports unknown DEG contrasts", {
  workspace <- setup_cli_workspace()
  on.exit(unlink(workspace$workspace, recursive = TRUE), add = TRUE)

  output <- suppressWarnings(
    withr::with_dir(
      workspace$code_dir,
      system2(
        "Rscript",
        c("main.R", common_cli_args, "--select_contrasts=missing"),
        stdout = TRUE,
        stderr = TRUE
      )
    )
  )

  expect_equal(attr(output, "status"), 1)
  expect_true(any(grepl("Selected contrasts not found: missing", output)))
})

test_that("run wrapper prepares result directories and forwards CLI arguments", {
  run_lines <- read_repo_file("code", "run")
  run_text <- paste(run_lines, collapse = "\n")

  expect_match(run_text, "mkdir -p \\.\\./results/figures \\.\\./results/moo")
  expect_match(run_text, 'Rscript main\\.R "\\$@"')
})

test_that("Venn diagram capsule writes its CSV companion artifact under results/moo", {
  main_lines <- read_repo_file("code", "main.R")
  main_text <- paste(main_lines, collapse = "\n")

  expect_match(
    main_text,
    'file\\.path\\(getOption\\("moo_plots_dir"\\), "\\.\\.", "moo", "venn_diagram_data\\.csv"\\)'
  )
})
