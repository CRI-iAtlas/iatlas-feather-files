present <- function (a) {!identical(a, NA) && !identical(a, NULL)}

get_tag_column_names <- function(df) {
  if (!is_df_empty(df)) {
    column_names <- df %>% names()
    tag_column_names <- column_names %>%
      stringi::stri_extract_first(regex = "^tag(\\.[\\w]{1,})?") %>%
      na.omit()
    return(tag_column_names)
  }
  return(NA)
}

#' get_unique_valid_values
#'
#' Takes a list and returns a new list with all NA values and all duplicate values removed
#'
#' @param values is a list
#' @return unique, non-na values
get_unique_valid_values <- function(values) {
  unique(values[!is.na(values)])
}

is_df_empty <- function(df = data.frame()) {
  if (!identical(class(df), "data.frame") & !tibble::is_tibble(df)) {
    df <- data.frame()
  }
  return(is.null(dim(df)) | dim(df)[1] == 0 | dim(df)[2] == 0)
}

#' load_feather_data:
#'
#' Loads all feather files in a directory, concatinates them togther
#' and retruns tibble.
#'
#' @param folder the path to the folder that contains the feather files to load.
#' @return A single data frame (as tibble) with all feather filke data bound together.
load_feather_data <- function(folder = "data/test", join = FALSE)
  load_feather_files(Sys.glob(paste0(folder, "/*.feather")), join)

load_feather_files <- function(file_names, join = FALSE) {
  df <- dplyr::tibble()

  length <- length(file_names)
  if (length > 0) {
    for (index in 1:length) {
      if (isFALSE(join) | is_df_empty(df)) {
        df <- df %>% dplyr::bind_rows(read_feather_with_info(file_names[[index]]) %>% dplyr::as_tibble())
      } else {
        file <- read_feather_with_info(file_names[[index]]) %>% dplyr::as_tibble()
        df <- df %>% dplyr::full_join(file, by = intersect(names(df), names(file)))
      }
    }
  }
  return(df)
}

rebuild_gene_relational_data <- function(all_genes, ref_name, field_name = "name") {
  relational_data <- all_genes %>%
    dplyr::distinct(!!rlang::sym(ref_name)) %>%
    dplyr::rename_at(ref_name, ~(field_name)) %>%
    dplyr::filter(!is.na(!!rlang::sym(field_name))) %>%
    dplyr::arrange(!!rlang::sym(field_name))
  return(relational_data)
}

flatten_dupes <- function(values) {
  unique_values <- get_unique_valid_values(values)
  value <- values[1]
  if (length(unique_values) > 1) {
    print(unique_values)
    stop("DIRTY DATA! Found multiple values: ", paste(unique_values, collapse = ", "))
  } else if (length(unique_values) == 1) {
    value <- unique_values[[1]]
  }
  return(value)
}
