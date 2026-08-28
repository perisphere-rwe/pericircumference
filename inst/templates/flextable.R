

flextable_polish <- function(ft,
                             font_name = "Arial",
                             font_size = 11,
                             header_text = NULL,
                             footer_text = NULL,
                             bold_group_labels = TRUE,
                             use_peripal = TRUE) {

  if(!is.null(header_text))
    ft <- ft %>% add_header_lines(header_text)

  if(!is.null(footer_text))
    ft <- ft %>% add_footer_lines(footer_text)

  if (use_peripal)
    ft <- ft %>% bg(i = 1L, bg = "#95B2DE", part = "header")

  is_grouped <- class(ft$body$dataset)[1L] == "grouped_data"

  if (is_grouped) {
    group_label_idx <- which(!is.na(ft$body$dataset[[1L]]))

    if (bold_group_labels)
      ft <- ft %>% bold(i = group_label_idx, j = 1L)

    if (use_peripal)
      ft <- ft %>% bg(i = group_label_idx, bg = "lightblue")
  }

  ft %>%
    bold(part = 'header') %>%
    font(fontname = font_name, part = "all") %>%
    fontsize(size = font_size, part = "all") %>%
    theme_box() %>%
    align(align = "center", part = "all") %>%
    align(j = 1, align = "left", part = "all")

}

flextable_polish_ppt <- function(ft,
                                 font_name = "Arial",
                                 font_size = 11,
                                 header_text = NULL,
                                 footer_text = NULL){

  ft %>%
    color(color = "white", part = "header") %>%
    bg(bg = "#0070C0", part = "header") %>%
    flextable_polish(font_name = font_name,
                     font_size = font_size,
                     header_text = header_text,
                     footer_text = footer_text)

}

flextable_autofit <- function(ft,
                              prop_used_col_1 = NULL,
                              width_max = 7){


  n_cols <- ncol(ft$header$dataset)

  stopifnot(n_cols > 1)

  width_1 <- width_max * (prop_used_col_1 %||% (1 / n_cols))

  width_other <- (width_max - width_1) / (n_cols-1)


  ft %>%
    width(width = width_other) %>%
    width(j = 1, width = width_1)

}
