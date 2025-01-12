#' get_header: retrieves the attributes of a .fh/Heidelberg format file
#'
#' @description This function reports the HEADER fields from a .fh/Heidelberg
#'   format file. The header fields are harvested from the .fh file by the
#'   `read_fh()` function, which stores the HEADER fields in the .fh file as
#'   attributes of the `data.frame` it returns.
#'
#' @param rwl The output of `read_fh(x, header = TRUE)`,
#' a `data.frame` of class `rwl`.
#'
#' @return A `data.frame` with 26 header fields.
#'
#' @export

get_header <-
     function(rwl) {
          if (identical(class(rwl), c("rwl", "data.frame"))) {
               attr(rwl, "row.names") <- NULL
               attr(rwl, "po") <- NULL
               attr(rwl, "class") <- NULL
               attr(rwl, "names") <- NULL

               tmp <- attributes(rwl)
               tmp <- data.frame(tmp)

               return(tmp)

          } else {
               cat(gettext('Object should be a data.frame of class "rwl"\n'))

          }
     }
