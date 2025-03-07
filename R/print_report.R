#' Generate report from data cleaning operations
#'
#' @param data A \code{<data.frame>} or \code{<linelist>} object returned from
#'    the \code{\link{clean_data}} or the main functions of each data cleaning
#'    module.
#' @param report_title A \code{<character>} with the title that will appear on
#'    the report
#' @param output_file_name A \code{<character>} used to specify the name of the
#'    report file, excluding any file extension. If no file name is supplied,
#'    one will be automatically generated with the format
#'    \code{cleanepi_report_YYMMDD_HHMMSS}.
#' @param format A \code{<character>} with the file format of the report.
#'    Currently only \code{"html"} is supported.
#' @param print A \code{<logical>} that specifies whether to print the generated
#'    HTML file or no. Default is \code{TRUE}.
#'
#' @returns A \code{<character>} containing the name and path of the saved
#'    report
#' @examples
#' \donttest{
#' data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))
#' test_dictionary <- readRDS(
#'   system.file("extdata", "test_dictionary.RDS", package = "cleanepi")
#' )
#'
#' # scan through the data
#' scan_res <- scan_data(data)
#'
#' # Perform data cleaning
#' cleaned_data <- data %>%
#'  standardize_column_names(keep = NULL, rename = c("DOB" = "dateOfBirth")) %>%
#'  replace_missing_values(target_columns = NULL, na_strings = "-99") %>%
#'  remove_constants(cutoff = 1.0) %>%
#'  remove_duplicates(target_columns = NULL) %>%
#'  standardize_dates(
#'    target_columns = NULL,
#'    error_tolerance = 0.4,
#'    format = NULL,
#'    timeframe = as.Date(c("1973-05-29", "2023-05-29"))
#'  ) %>%
#'  check_subject_ids(
#'    target_columns = "study_id",
#'    prefix = "PS",
#'    suffix = "P2",
#'    range = c(1L, 100L),
#'    nchar = 7L
#'  ) %>%
#'  convert_to_numeric(target_columns = "sex", lang = "en") %>%
#'  clean_using_dictionary(dictionary = test_dictionary)
#'
#' # add the data scanning result to the report
#' cleaned_data <- add_to_report(
#'   x = cleaned_data,
#'   key = "scanning_result",
#'   value = scan_res
#' )
#'
#' # save a report in the current directory using the previously-created objects
#' print_report(
#'   data = cleaned_data,
#'   report_title = "{cleanepi} data cleaning report",
#'   output_file_name = NULL,
#'   format = "html",
#'   print = TRUE
#' )
#' }
#'
#' @export
#' @importFrom utils browseURL
print_report <- function(data,
                         report_title = "{cleanepi} data cleaning report",
                         output_file_name = NULL,
                         format = "html",
                         print = TRUE) {

  # extract report, check whether any cleaning operation has been performed, and
  # allow for only HTML output format for the report.
  report <- attr(data, "report")
  if (is.null(report)) {
    cli::cli_abort(c(
      tr_("No report associated with the input data."),
      x = tr_("At least one data cleaning operation must be applied to the data before calling {.fn print_report}."), # nolint: line_length_linter
      i = tr_("The list of functions in {.pkg cleanepi} can be found at: {.url https://epiverse-trace.github.io/cleanepi/reference/index.html}.") # nolint: line_length_linter
    ), call = NULL)
  }
  if (format != "html") {
    cli::cli_abort(c(
      tr_("Incorrect value provided for {.emph format} argument!"),
      i = tr_("Only {.val html} format is currently supported.")
    ), call = NULL)
  }

  # set the report from scan_data() function to NA if no data scanning was
  # performed. NA because the function returns NA if no character column was
  # found in the input data
  if (!("scanning_result" %in% names(report))) {
    report[["scanning_result"]] <- NA
  }

  # generate output file and directory
  timestamp_string <- format(Sys.time(), "_%Y-%m-%d%_at_%H%M%S")
  if (is.null(output_file_name)) {
    output_file_name <- paste0("cleanepi_report_", timestamp_string, ".html")
  }

  # this ensures to add the logo to the report
  report[["report_title"]] <- report_title
  man_path <- file.path("man", "figures")
  report[["logo"]] <- system.file(man_path, "logo.svg", package = "cleanepi")

  # render the Rmd file to generate the report
  temp_dir <- tempdir()
  file_and_path <- file.path(temp_dir, output_file_name)
  cli::cli_alert_info(
    tr_("Generating html report in {.file {temp_dir}}.")
  )
  rmarkdown::render(
    input = system.file(
      "rmarkdown", "templates", "printing-rmd", "skeleton", "skeleton.Rmd",
      package = "cleanepi",
      mustWork = TRUE
    ),
    output_file = file_and_path,
    params = report,
    quiet = TRUE
  )

  # print report if specified
  if (print) {
    utils::browseURL(file_and_path)
  }
  return(file_and_path)
}
