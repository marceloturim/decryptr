prepare <- function(arqs) {
  UseMethod('prepare')
}

prepare.image_captcha <- function(arqs, only_x = FALSE) {
  if (!only_x && length(arqs) > 1) {
    words <- arqs %>%
      basename() %>%
      tools::file_path_sans_ext() %>%
      stringr::str_match('_([a-zA-Z0-9]+)$') %>%
      magrittr::extract(TRUE, 2)
    all_letters <- unique(sort(unlist(strsplit(words, ''))))
    y <- plyr::laply(words, create_response, all_letters)
    return(list(y = y, x = x))
  }
  x <- plyr::laply(arqs, jpeg::readJPEG)
  if (length(arqs) == 1) dim(x) <- c(1, dim(x))
  return(list(y = NULL, x = x))
}

create_response <- function(x, all_letters) {
  a <- strsplit(x, '')[[1]]
  n <- length(a)
  n_letters <- length(all_letters)
  if (length(unique(a)) == 1) {
    mm <- matrix(rep(1, n), ncol = 1)
  } else {
    mm <- model.matrix(rep(1, n) ~ a - 1)
  }
  m <- matrix(0L, nrow = n, ncol = n_letters)
  colnames(m) <- all_letters
  sua <- sort(unique(a))
  colnames(mm) <- sua
  m[, sua] <- mm
  attributes(m) <- list(dim = c(n, n_letters))
  m
}