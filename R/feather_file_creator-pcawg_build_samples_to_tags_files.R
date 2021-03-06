pcawg_build_samples_to_tags_files <- function() {
  require(magrittr)

  cat_samples_to_tags_status <- function(message) {
    cat(crayon::cyan(paste0(" - ", message)), fill = TRUE)
  }

  get_samples_to_tags <- function() {

    cat_samples_to_tags_status("Get all PCAWG samples_to_tags from Synapse.")
    samples_to_tags_pcawg <- iatlas.data::get_pcawg_tag_values_cached() %>%
      dplyr::filter(tag != "PCAWG")

    cat_samples_to_tags_status("Get all PCAWG samples and tag them PCAWG_Study.")
    samples_to_pcawg_study <- iatlas.data::get_pcawg_samples_cached() %>%
      dplyr::select(sample = icgc_donor_id) %>%
      dplyr::mutate(tag = "PCAWG_Study")

    cat_samples_to_tags_status("Get all PCAWG samples and tag them Immune_Subtype.")
    samples_to_immune_subtype <- iatlas.data::get_pcawg_samples_cached() %>%
      dplyr::select(sample = icgc_donor_id) %>%
      dplyr::mutate(tag = "Immune_Subtype")

    cat_samples_to_tags_status("Bind the samples_to_tags dataframes together.")
    samples_to_tags <- samples_to_tags_pcawg %>%
      dplyr::bind_rows(samples_to_pcawg_study, samples_to_immune_subtype)

    cat_samples_to_tags_status("Clean up the data set.")
    samples_to_tags <- samples_to_tags %>% dplyr::arrange(sample, tag)

    return(samples_to_tags)
  }

  iatlas.data::synapse_store_feather_file(
    get_samples_to_tags(),
    "pcawg_samples_to_tags.feather",
    "syn22125729"
  )

}
