#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up results directory
results_dir <- file.path('..','results')
plots_dir <- file.path(results_dir, 'figures')
options(moo_plots_dir = plots_dir, moo_save_plots = TRUE)

# log installed packages & versions
pkg_versions <- tibble::as_tibble(installed.packages())
write_csv(pkg_versions, file.path(results_dir, 'r-packages.csv'))

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--regex_moo", type="character", default=".*\\.rds$")
parser$add_argument("--feature_id_colname", type="character", default=NULL, help="Column name for feature IDs")
parser$add_argument("--contrasts_colname", type="character", default="Contrast", help="Column name for contrast names")
parser$add_argument("--select_contrasts", type="character", default="", help="Comma-separated contrast names to select")
parser$add_argument("--plot_type", type="character", default="Venn diagram", help="Type of plot: 'Venn diagram' or 'Intersection plot'")
parser$add_argument("--intersection_ids", type="character", default="", help="Comma-separated intersection IDs to select")
parser$add_argument("--venn_force_unique", type="logical", default=TRUE, help="Force unique elements in Venn diagram")
parser$add_argument("--venn_numbers_format", type="character", default="raw", help="Format for Venn numbers: 'raw', 'percent', 'raw-percent', or 'percent-raw'")
parser$add_argument("--venn_significant_digits", type="integer", default=2, help="Number of significant digits for Venn numbers")
parser$add_argument("--venn_fill_colors", type="character", default="darkgoldenrod2,darkolivegreen2,mediumpurple3,darkorange2,lightgreen", help="Comma-separated fill colors for Venn diagram")
parser$add_argument("--venn_fill_transparency", type="double", default=0.2, help="Transparency level for Venn fill colors")
parser$add_argument("--venn_border_colors", type="character", default="fill colors", help="Border colors for Venn categories")
parser$add_argument("--venn_font_size_for_category_names", type="double", default=3, help="Font size for category names in Venn diagram")
parser$add_argument("--venn_category_names_distance", type="character", default="", help="Distance of category names from Venn circles")
parser$add_argument("--venn_category_names_position", type="character", default="", help="Position of category names in Venn diagram")
parser$add_argument("--venn_font_size_for_counts", type="double", default=6, help="Font size for counts in Venn diagram")
parser$add_argument("--venn_outer_margin", type="double", default=0, help="Outer margin for Venn diagram")
parser$add_argument("--intersections_order", type="character", default="degree", help="Order of intersections: 'degree', 'freq', or other")
parser$add_argument("--display_empty_intersections", type="logical", default=FALSE, help="Display empty intersections in plot")
parser$add_argument("--intersection_bar_color", type="character", default="steelblue4", help="Color for intersection bars")
parser$add_argument("--intersection_point_size", type="double", default=2.2, help="Size of points in intersection plot")
parser$add_argument("--intersection_line_width", type="double", default=0.7, help="Width of lines in intersection plot")
parser$add_argument("--table_font_size", type="double", default=0.7, help="Font size for table in plot")
parser$add_argument("--table_content", type="character", default="all intersections", help="Content of table: 'all intersections' or 'selected intersections'")
parser$add_argument("--image_width", type="integer", default=4000, help="Output image width in pixels")
parser$add_argument("--image_height", type="integer", default=3000, help="Output image height in pixels")
parser$add_argument("--dpi", type="integer", default=300, help="Dots per inch of output image")
parser$add_argument("--plot_filename", type="character", default="venn_diagram.png", help="Plot output filename")


args <- parser$parse_args()

parse_optional_vector <- function(x) {
    if (is.null(x) || identical(x, "") || length(x) == 0) {
        return(NULL)
    }
    return(trimws(unlist(strsplit(x, ","))))
}

parse_numeric_vector <- function(x) {
    parsed <- parse_optional_vector(x)
    if (is.null(parsed)) {
        return(c())
    }
    return(as.numeric(parsed))
}

# validate inputs
data_files <- list.files(file.path('../data'), recursive = TRUE, full.names = TRUE)
moo_files <- Filter(\(x) str_detect(x, regex(args$regex_moo, ignore_case = TRUE)), data_files)

if (length(moo_files) == 0) {
    stop(glue("No files matching regex: {args$regex_moo}"))
}
moo_filename <- moo_files[1]
moo <- read_rds(moo_filename)
message(glue('Reading multiOmicDataSet from {moo_filename}'))
if (!inherits(moo, 'MOSuite::multiOmicDataSet')) {
    stop(glue('The input is not a multiOmicDataSet. class: {class(moo)}'))
}

# First, generate volcano summary to get the differential expression summary data
# (This is required input for the venn diagram function)
summary_dat <- plot_volcano_summary(
    moo,
    print_plots = FALSE,
    save_plots = FALSE
)

# Now generate the venn diagram from the summary data
venn_result <- plot_venn_diagram(
    summary_dat,
    feature_id_colname = args$feature_id_colname,
    contrasts_colname = args$contrasts_colname,
    select_contrasts = parse_optional_vector(args$select_contrasts),
    plot_type = args$plot_type,
    intersection_ids = parse_numeric_vector(args$intersection_ids),
    venn_force_unique = args$venn_force_unique,
    venn_numbers_format = args$venn_numbers_format,
    venn_significant_digits = args$venn_significant_digits,
    venn_fill_colors = parse_optional_vector(args$venn_fill_colors),
    venn_fill_transparency = args$venn_fill_transparency,
    venn_border_colors = args$venn_border_colors,
    venn_font_size_for_category_names = args$venn_font_size_for_category_names,
    venn_category_names_distance = parse_numeric_vector(args$venn_category_names_distance),
    venn_category_names_position = parse_numeric_vector(args$venn_category_names_position),
    venn_font_size_for_counts = args$venn_font_size_for_counts,
    venn_outer_margin = args$venn_outer_margin,
    intersections_order = args$intersections_order,
    display_empty_intersections = args$display_empty_intersections,
    intersection_bar_color = args$intersection_bar_color,
    intersection_point_size = args$intersection_point_size,
    intersection_line_width = args$intersection_line_width,
    table_font_size = args$table_font_size,
    table_content = args$table_content,
    image_width = args$image_width,
    image_height = args$image_height,
    dpi = args$dpi,
    plot_filename = args$plot_filename
)

# Save venn diagram results
readr::write_csv(venn_result, file.path(results_dir, 'moo','venn_diagram_data.csv'))

