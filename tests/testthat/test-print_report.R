# perform data cleaning
test_data <- readRDS(
  system.file("extdata", "test_df.RDS", package = "cleanepi")
)

test_dictionary <- readRDS(
  system.file("extdata", "test_dictionary.RDS", package = "cleanepi")
)

cleaned_data <- test_data %>%
  standardize_column_names(keep = NULL, rename = NULL) %>%
  replace_missing_values(target_columns = NULL, na_strings = "-99") %>%
  remove_constants(cutoff = 1.0) %>%
  remove_duplicates(target_columns = NULL) %>%
  standardize_dates(
    target_columns = NULL,
    error_tolerance = 0.4,
    format = NULL,
    timeframe = as.Date(c("1973-05-29", "2023-05-29"))
  ) %>%
  check_subject_ids(
    target_columns = "study_id",
    prefix = "PS",
    suffix = "P2",
    range = c(1L, 100L),
    nchar = 7L
  ) %>%
  convert_to_numeric(target_columns = "sex") %>%
  clean_using_dictionary(dictionary = test_dictionary)

# scan through the data
scan_res <- scan_data(data = test_data)

# add the data scanning result to the report
cleaned_data <- add_to_report(
  x = cleaned_data,
  key = "scanning_result",
  value = scan_res
)

# perform the test
test_that("print_report works", {
  testthat::skip_on_cran()
  testthat::skip_on_covr()
  test_print_report <- print_report(
    data = cleaned_data,
    report_title = "{cleanepi} data cleaning report",
    output_file_name = NULL,
    format = "html",
    print = FALSE
  )
  expect_type(test_print_report, "character")
  expect_true(file.exists(test_print_report))
  expect_true(grepl(".html", test_print_report))
  expect_true(file.size(test_print_report) > 0L)
})

test_that("print_report fails when no report is associated to the data", {
  testthat::skip_on_cran()
  testthat::skip_on_covr()
  expect_error(
    print_report(
      data = test_data,
      report_title = "{cleanepi} data cleaning report",
      output_file_name = NULL,
      format = "html",
      print = FALSE
    ),
    regexp = cat("No report associated with the input data.")
  )

  test_data <- add_to_report(
    x = test_data,
    key = "scanning_result",
    value = scan_res
  )
  expect_error(
    print_report(
      data = test_data,
      report_title = "{cleanepi} data cleaning report",
      output_file_name = NULL,
      format = "pdf",
      print = FALSE
    ),
    regexp = cat("Invalid output format!.")
  )
})
