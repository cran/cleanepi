## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk[["set"]](collapse = TRUE, comment = "#>", eval = FALSE,
                           fig.width = 7L, fig.height = 7L,
                           fig.align = "center")
row_id <- group_id <- NULL

## ----setup, eval=TRUE---------------------------------------------------------
library("cleanepi")

## ----eval=TRUE----------------------------------------------------------------
# IMPORTING THE TEST DATASET
test_data <- readRDS(
  system.file("extdata", "test_df.RDS", package = "cleanepi")
)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
test_data %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# SCAN THE DATA
scan_result <- scan_data(test_data)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
scan_result %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = FALSE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# PARAMETERS FOR REPLACING MISSING VALUES WITH NA
replace_missing_values <- list(target_columns = NULL, na_strings = "-99")

# PARAMETERS FOR COLUMN NAMES STANDARDIZATION
standardize_column_names <- list(keep = NULL, rename = NULL)

# PARAMETERS FOR DUBLICATES DETECTION AND REMOVAL
remove_duplicates <- list(target_columns = NULL)

# PARAMETERS FOR STANDARDING DATES
standardize_dates <- list(
  target_columns = NULL,
  error_tolerance = 0.4,
  format = NULL,
  timeframe = as.Date(c("1973-05-29", "2023-05-29")),
  orders = list(
    world_named_months = c("Ybd", "dby"),
    world_digit_months = c("dmy", "Ymd"),
    US_formats = c("Omdy", "YOmd")
  )
)

# PARAMETERS FOR STANDARDING SUBJECT ids
standardize_subject_ids <- list(
  target_columns = "study_id",
  prefix = "PS",
  suffix = "P2",
  range = c(1, 100),
  nchar = 7
)

# CONVERT THE 'sex' COLUMN INTO NUMERIC
to_numeric <- list(target_columns = "sex", lang = "en")

# PARAMETERS FOR CONSTANT COLUMNS, EMPTY ROWS AND COLUMNS REMOVAL
remove_constants <- list(cutoff = 1)

# LAOD THE DATA DICTIONARY FOR DICTIONARY-BASED CLEANING
dictionary <- readRDS(
  system.file("extdata", "test_dictionary.RDS", package = "cleanepi")
)

## ----eval=TRUE----------------------------------------------------------------
# CLEAN THE INPUT DATA FRAME
cleaned_data <- clean_data(
  data = test_data,
  remove_constants = remove_constants,
  replace_missing_values = replace_missing_values,
  remove_duplicates = remove_duplicates,
  standardize_dates = standardize_dates,
  standardize_subject_ids = standardize_subject_ids,
  to_numeric = to_numeric,
  dictionary = dictionary
)

## ----eval=TRUE----------------------------------------------------------------
# ACCESS THE DATA CLEANING REPORT
report <- attr(cleaned_data, "report")

# SUMMARIZE THE REPORT OBJECT
summary(report)

## ----eval=FALSE---------------------------------------------------------------
# print_report(cleaned_data)

## ----echo=TRUE, eval=TRUE-----------------------------------------------------
# IMPORT THE INPUT DATA
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))

# INTRODUCE AN EMPTY COLUMN
data$empty_column <- NA

# remove the constant columns, empty rows and columns
dat <- remove_constants(
  data = data,
  cutoff = 1
)

## ----echo=FALSE, eval=TRUE----------------------------------------------------
dat %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# IMPORT AND PRINT THE INITAL COLUMN NAMES
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))
print(colnames(data))

# KEEP 'date.of.admission' AS IS
cleaned_data <- standardize_column_names(
  data = data,
  keep = "date.of.admission"
)
print(colnames(cleaned_data))

# KEEP 'date.of.admission' AS IS, BUT RENAME 'dateOfBirth' AND 'sex' TO
# 'DOB' AND 'gender' RESPECTIVELY
cleaned_data <- standardize_column_names(
  data = data,
  keep = "date.of.admission",
  rename = c(DOB = "dateOfBirth", gender = "sex")
)
print(colnames(cleaned_data))

## ----eval=TRUE----------------------------------------------------------------
# VISUALIZE THE PREDEFINED VECTOR OF MISSING CHARACTERS
print(cleanepi::common_na_strings)

## ----eval=TRUE----------------------------------------------------------------
# REPLACE ALL OCCURENCES OF "-99" WITH NA IN THE "sex" COLUMN
cleaned_data <- replace_missing_values(
  data = readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi")),
  target_columns = "sex",
  na_strings = "-99"
)

# REPLACE ALL OCCURENCES OF "-99" WITH NA FROM ALL COLUMNS
cleaned_data <- replace_missing_values(
  data = readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi")),
  target_columns = NULL,
  na_strings = "-99"
)

## ----echo=FALSE, eval=TRUE----------------------------------------------------
cleaned_data %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## -----------------------------------------------------------------------------
# orders <- list(
#   quarter_partial_dates = c("Y", "Ym", "Yq"),
#   world_digit_months = c("ymd", "ydm", "dmy", "mdy", "myd", "dym", "Ymd", "Ydm",
#                          "dmY", "mdY", "mYd", "dYm"),
#   world_named_months = c("dby", "dyb", "bdy", "byd", "ybd", "ydb", "dbY", "dYb",
#                          "bdY", "bYd", "Ybd", "Ydb"),
#   us_format = c("Omdy", "YOmd")
# )

## ----eval=FALSE---------------------------------------------------------------
# # GIVE PRIORITY TO AMERICAN-STYLE DATES
# us_ord <- orders[c(1L, 3L, 2L)]
# 
# # ADD A FORMAT WITH HOURS TO THE EXISTING orders
# # THIS WILL ALLOW FOR THE CONVERSION OF VALUES SUCH AS "2014_04_05_23:15:43"
# # WHEN THEY APPEAR IN THE TARGET COLUMNS.
# orders$ymdhms <- c("Ymdhms", "Ymdhm")

## ----eval=TRUE----------------------------------------------------------------
# STANDARDIZE VALUES IN THE 'date_first_pcr_positive_test' COLUMN
test_data <- readRDS(
  system.file("extdata", "test_df.RDS", package = "cleanepi")
)

head(test_data$date_first_pcr_positive_test)

res <- standardize_dates(
  data = test_data,
  target_columns = "date_first_pcr_positive_test",
  format = NULL,
  timeframe = NULL,
  error_tolerance = 0.4,
  orders = list(
    world_named_months = c("Ybd", "dby"),
    world_digit_months = c("dmy", "Ymd"),
    US_formats = c("Omdy", "YOmd")
  )
)

## ----echo=FALSE, eval=TRUE----------------------------------------------------
res %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----echo=TRUE, eval=TRUE-----------------------------------------------------
# STANDARDIZE VALUES IN ALL COLUMNS
res <- standardize_dates(
  data = test_data,
  target_columns = NULL,
  format = NULL,
  timeframe = NULL,
  error_tolerance = 0.4,
  orders = list(
    world_named_months = c("Ybd", "dby"),
    world_digit_months = c("dmy", "Ymd"),
    US_formats = c("Omdy", "YOmd")
  )
)

# GET THE REPORT
report <- attr(res, "report")

## ----echo=FALSE, eval=TRUE----------------------------------------------------
# DISPLAY DATE VALUES THAT COMPLY WITH MULTIPLE FORMATS
report$multi_format_dates %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# DETECT AND REMOVE INCORRECT SUBJECT IDs
res <- check_subject_ids(
  data = readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi")),
  target_columns = "study_id",
  prefix = "PS",
  suffix = "P2",
  range = c(1L, 100L),
  nchar = 7L
)

# EXTRACT REPORT
report <- attr(res, "report")

# DISPLAY THE INCORRECT SUBJECT IDs
print(report$incorrect_subject_id)

## ----eval=TRUE----------------------------------------------------------------
# IMPORT THE INPUT DATA
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))

# GENERATE THE CORRECTION TABLE
correction_table <- data.frame(
  from = c("P0005P2", "PB500P2", "PS004P2-1"),
  to = c("PB005P2", "PB050P2", "PS004P2"),
  stringsAsFactors = FALSE
)

# PERFORM THE CORRECTION
dat <- correct_subject_ids(
  data = data,
  target_columns = "study_id",
  correction_table = correction_table
)

## ----eval=TRUE----------------------------------------------------------------
# IMPORT THE DATA AND STANDARDIZE THE TARGET DATE COLUMNS
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))
data <- standardize_dates(
  data,
  target_columns = c("date_first_pcr_positive_test", "date.of.admission")
)

# DETECT ROWS WITH INCORRECT DATE SEQUENCE
res <- check_date_sequence(
  data = data,
  target_columns = c("date_first_pcr_positive_test", "date.of.admission")
)

# DISPLAY THE INCORRECT SEQUENCES OF DATE
incorrect_sequence <- attr(res, "report")[["incorrect_date_sequence"]]
print(incorrect_sequence)

## ----eval=TRUE----------------------------------------------------------------
# CONVERT THE 'age' COLUMN IN THE TEST LINELIST DATA
dat <- readRDS(system.file("extdata", "messy_data.RDS", package = "cleanepi"))
head(dat$age, 10L)
dat <- convert_to_numeric(
  data = dat,
  target_columns = "age",
  lang = "en"
)
head(dat$age, 10L)

## ----eval=TRUE----------------------------------------------------------------
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi")) %>%
  standardize_dates(target_columns = "date.of.admission")

# CREATE THE RECRUITMENT DATE COLUMNS
data$recruitment_date <- sample(20:50, nrow(data), replace = FALSE)

# RETRIVE THE DATE INDIVIDUALS WERE RECRUITED FROM THEIR DATE OF ADMISSION
dat <- convert_numeric_to_date(
  data = data,
  target_columns = "recruitment_date",
  ref_date = "date.of.admission",
  forward = TRUE
)

# RETRIVE THE DATE INDIVIDUALS WERE RECRUITED FROM 2019-10-13
dat <- convert_numeric_to_date(
  data = data,
  target_columns = "recruitment_date",
  ref_date = as.Date("2019-10-13"),
  forward = FALSE
)

## ----eval=TRUE----------------------------------------------------------------
# IMPORT A `linelist` DATA
data <- readRDS(
  system.file("extdata", "test_linelist.RDS", package = "cleanepi")
)

# SHOW THE TAGGED VARIABLES
linelist::tags(data)

# FIND DUPLICATES ACROSS ALL COLUMNS EXCEPT THE SUBJECT ids COLUMN
all_columns <- names(data)
target_columns <- all_columns[all_columns != "id"]
dups <- find_duplicates(
  data = data,
  target_columns = target_columns
)

# FIND DUPLICATES ACROSS TAGGED VARIABLES
dups <- find_duplicates(
  data = data,
  target_columns = "linelist_tags"
)

## ----eval=TRUE----------------------------------------------------------------
# DISPLAY THE DUPLICATES
report <- attr(dups, "report")
duplicates <- report$duplicated_rows

## ----echo=FALSE---------------------------------------------------------------
# duplicates %>%
#   kableExtra::kbl() %>%
#   kableExtra::kable_paper("striped", font_size = 14, full_width = FALSE) %>%
#   kableExtra::scroll_box(height = "200px", width = "100%",
#                          box_css = "border: 1px solid #ddd; padding: 5px; ",
#                          extra_css = NULL,
#                          fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# REMOVE DUPLICATE ACROSS TAGGED COLUMNS ONLY.
res <- remove_duplicates(
  data = readRDS(
    system.file("extdata", "test_linelist.RDS", package = "cleanepi")
  ),
  target_columns = "linelist_tags"
)

## ----eval=TRUE----------------------------------------------------------------
# ACCESS THE REPORT
report <- attr(res, "report")

# SUMMARIZE THE REPORT OBJECT
summary(report)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
dictionary %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# READING IN THE DATA
data <- readRDS(
  system.file("extdata", "test_df.RDS", package = "cleanepi")
)

# ADD THE EXTRA OPTION TO THE DICTIONARY
dictionary <- add_to_dictionary(
  dictionary = dictionary,
  option = "-99",
  value = "unknow",
  grp = "sex",
  order = NULL
)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
dictionary %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# PERFORM THE DICTIONARY-BASED SUBSTITUTION
cleaned_df <- clean_using_dictionary(
  data = data,
  dictionary = dictionary
)

## ----eval=TRUE, echo=FALSE----------------------------------------------------
cleaned_df %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----eval=TRUE----------------------------------------------------------------
# IMPORT DATA, REPLACE MISSING VALUES WITH 'NA' & STANDARDIZE DATES
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi")) %>%
  replace_missing_values(
    target_columns = "dateOfBirth",
    na_strings = "-99"
  ) %>%
  standardize_dates(
    target_columns = "dateOfBirth",
    error_tolerance = 0.0,
    format = "%m/%d/%Y" # nolint: nonportable_path_linter.
  )

# CALCULATE INDIVIDUAL AGE IN YEARS FROM THE 'dateOfBirth' COLUMN AND SEND THE
# REMAINDER IN MONTHS
age <- timespan(
  data = data,
  target_column = "dateOfBirth",
  end_date = Sys.Date(),
  span_unit = "years",
  span_column_name = "age_in_years",
  span_remainder_unit = "months"
)

# CALCULATE THE TIME SPAN IN DAYS BETWEEN INDIVIDUALS DATE OF ADMISSION AND THE
# DAY THEY TESTED POSITIVE
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))
dat <- data %>%
  replace_missing_values(
    target_columns = "dateOfBirth",
    na_strings = "-99"
  ) %>%
  standardize_dates(
    target_columns = c("date_first_pcr_positive_test", "date.of.admission"),
    error_tolerance = 0.0,
    format = NULL
  ) %>%
  timespan(
    target_column = "date_first_pcr_positive_test",
    end_date = "date.of.admission",
    span_unit = "days",
    span_column_name = "elapsed_days",
    span_remainder_unit = NULL
  )

## ----eval=TRUE, echo=FALSE----------------------------------------------------
# DISPLAY THE OUTPUT OBJECT
dat %>%
  kableExtra::kbl() %>%
  kableExtra::kable_paper("striped", font_size = 14, full_width = TRUE) %>%
  kableExtra::scroll_box(height = "200px", width = "100%",
                         box_css = "border: 1px solid #ddd; padding: 5px; ",
                         extra_css = NULL,
                         fixed_thead = TRUE)

## ----echo=TRUE, eval=TRUE-----------------------------------------------------
# IMPORT THE INPUT DATASET
data <- readRDS(system.file("extdata", "test_df.RDS", package = "cleanepi"))

# IMPORT THE DATA DICTIONARY
test_dictionary <- readRDS(
  system.file("extdata", "test_dictionary.RDS", package = "cleanepi")
)

# SCAN THROUGH THE DATA
scan_res <- scan_data(data)

# PERFORM DATA CLEANING
cleaned_data <- data %>%
  standardize_column_names(keep = NULL, rename = c(DOB = "dateOfBirth")) %>%
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
  convert_to_numeric(target_columns = "sex", lang = "en") %>%
  clean_using_dictionary(dictionary = test_dictionary)

# ADD THE DATA SCANNING RESULT TO THE REPORT
cleaned_data <- add_to_report(
   x = cleaned_data,
   key = "scanning_result",
   value = scan_res
)

## ----echo=TRUE, eval=FALSE----------------------------------------------------
# print_report(
#   data = cleaned_data,
#   report_title = "{cleanepi} data cleaning report",
#   output_directory = ".",
#   output_file_name = NULL,
#   format = "html",
#   print = TRUE
# )

