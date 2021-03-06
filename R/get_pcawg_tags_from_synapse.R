get_pcawg_tags_from_synapse <- function() {
  synapser::synLogin()
  # Get the data from Synapse.
  pcawg_tags_synapse <- "syn20717211" %>%
    synapser::synGet() %>%
    purrr::pluck("path") %>%
    read.table(stringsAsFactors = F, header = T, sep = "\t") %>%
    dplyr::as_tibble() %>%
    dplyr::inner_join(
      get_pcawg_sample_tbl_cached(),
      by = c("sample" = "aliquot_id")
    ) %>%
    dplyr::select(sample = icgc_donor_id, subtype, dcc_project_code) %>%
    dplyr::mutate(dataset = "PCAWG")
  return(pcawg_tags_synapse)
}
