#' sw_model: modelling of sapwood data
#'
#' @description
#' This function fits a distribution to a data set of observed sapwood numbers
#'   and computes the highest posterior density interval (hdi) for a given
#'   credibility mass.
#'
#' @param sw_data The name of the sapwood data set to use for modelling.
#'  Should be one of [sw_data_overview()], or the path to a .csv file with
#'  columns `n_sapwood` and `count`.
#' @param densfun Name of the density function fitted to the sapwood data set.
#'   Should be one of:
#'   * "lognormal" (the default value),
#'   * "normal",
#'   * "weibull",
#'   * "gamma".
#' @param credMass A `scalar [0, 1]` specifying the mass within the credible
#'   interval (default = .954).
#' @param plot `Logical.` If `TRUE` a plot is returned of the fitted density
#' function. When `FALSE` a list with numeric output of the modelling process
#' is returned.
#' @param sep Should be "," (comma)  or ";" (semi-colon) and is used when a
#'   sapwood data set is provided from user-defined .csv-file.
#'
#' @return Depends on the `plot` parameter.
#'   * `plot = TRUE`: a ggplot-style graph.
#'   * `plot = FALSE`: a list with the numeric output of the modelling process.
#'
#' @export
#'
sw_model <-
     function(sw_data = "Hollstein_1980",
              densfun = "lognormal",
              credMass = 0.954,
              sep = ";",
              plot = TRUE) {
          if (is.na(credMass) || credMass <= 0 || credMass >= 1)
               stop(" --> credMass must be between 0 and 1")

          if (sw_data %in% sw_data_overview()) {
               observed <- get(sw_data)

          } else if (grepl("\\.csv$", sw_data)) {
               observed <- utils::read.csv(sw_data, sep = sep)
               if (!all(c("n_sapwood", "count") %in% names(observed))) {
                    stop("--> .csv file should have columns `n_sapwood` and `count`.)")
               } else {
                    observed <- observed[, c("n_sapwood", "count")]
               }

          } else {
               stop(
                    "--> sw_data should be one of sw_data_overview()
or path to a .csv file with columns `n_sapwood` and `count`.)"
               )
          }
          observed <- observed[, "count" != 0]
          n_obs = sum(observed$count)
          min <- min(observed$n_sapwood)
          max <- max(observed$n_sapwood)
          mean <- round(mean(observed$n_sapwood), 2)
          range <- c(min, mean, max)
          names(range) <- c("min", "mean", "max")

          df <- data.frame(
               n_sapwood = rep(observed$n_sapwood, observed$count)
          )

          fit_params <-
               MASS::fitdistr(df |> dplyr::pull(n_sapwood), densfun)

          sw_model <- data.frame(
               model_fit = d.count(
                    densfun = densfun,
                    x = rep(1:max(df$n_sapwood), 1),
                    param1 = fit_params$estimate[[1]],
                    param2 = fit_params$estimate[[2]],
                    n = n_obs)
          )
          sw_model["n_sapwood"] <- as.numeric(rownames(sw_model))

          sw_model <- sw_model |>
               dplyr::mutate(p = model_fit / n_obs)

          sw_model <- merge(sw_model, observed, all.x = TRUE) |>
               dplyr::relocate(p, .after = n_sapwood)

          hdi_model <-
               hdi(x = sw_model,
                   credMass = credMass)

          spline_int <-
               as.data.frame(stats::spline(sw_model$n_sapwood,
                                           sw_model$model_fit,
                                           xout = seq(1, max, 0.2))
               )

          if (plot) {
               # to avoid notes in CMD check
               n_sapwood <- model_fit <- count <- x <- y <- NULL

               p <- ggplot2::ggplot() +
                    ggplot2::geom_col(
                         data = sw_model,
                         ggplot2::aes(x = n_sapwood,
                                      y = count),
                         fill = "steelblue3",
                         color = "grey60",
                         alpha = .4
                    ) +

                    ggplot2::geom_ribbon(
                         data = subset(
                                 spline_int,
                                 x >= hdi_model[[1]] &
                                      x <= hdi_model[[2]]

                         ),
                         ggplot2::aes(
                              ymin = 0,
                              ymax = y,
                              x = x
                         ),
                         fill = "grey30",
                         alpha = 0.2
                    ) +

                     ggplot2::geom_segment(
                             data = hdi_model,
                             ggplot2::aes(
                                     x = hdi_model[[1]],
                                     xend = hdi_model[[2]],
                                     y = 0, yend = 0),
                             colour = "grey30", size = .8, alpha = 0.8) +

                    ggplot2::geom_line(
                         data = spline_int,
                         ggplot2::aes(x = x, y = y),
                         size = 1,
                         color = "red3"
                    ) +

                    ggplot2::theme_minimal() +
                    ggplot2::scale_x_continuous(breaks = seq(0, 100, by = 10)) +
                    ggplot2::labs(
                         title = paste0("Sapwood model for the ", sw_data, " dataset"),
                         subtitle = paste0(
                              "<span style='color:steelblue3'>blue bars</span>: original data (n = ",
                              n_obs,
                              ")",
                              " <br>
                 <span style='color:red3'>red line</span>: fitted ",
                 densfun,
                 " distribution <br>
                 <span style='color:grey30'>shaded area</span>: highest probability density interval (",
                 credMass * 100,
                 "%) =
                 __between ",
                 hdi_model[1],
                 " and ",
                 hdi_model[2],
                 " sapwood rings__"
                         )
                    ) +
                    ggplot2::xlab("number of sapwood rings") +
                    ggplot2::ylab("n\n") +
                    ggplot2::theme(
                         plot.title = ggtext::element_markdown(),
                         plot.subtitle = ggtext::element_markdown(hjust = 0),
                         plot.title.position = "plot"
                    )
               suppressWarnings(print(p))

          } else {
               output <- list(
                    n = n_obs,
                    range = range,
                    density_function = densfun,
                    fit_parameters = fit_params,
                    sapwood_model = sw_model,
                    hdi_model = hdi_model
               )
               output
          }
     }

################################################################################
# helper function to scale a Prob. Density Function (PDF) to a
# Prob. Frequency Function.

d.count <- function(densfun = densfun,
                    x = x,
                    param1 = 0,
                    param2 = 1,
                    log = FALSE,
                    n = 1) {
     if (densfun == "lognormal") {
          n  * stats::dlnorm(
               x = x,
               meanlog = param1,
               sdlog = param2,
               log = log
          )
     } else if (densfun == "normal") {
          n  * stats::dnorm(
               x = x,
               mean = param1,
               sd = param2,
               log = log
          )
     } else if (densfun == "weibull") {
          n  * stats::dweibull(
               x = x,
               shape = param1,
               scale = param2,
               log = log

          )
     } else if (densfun == "gamma") {
          n  * stats::dgamma(
               x = x,
               shape = param1,
               rate = param2,
               log = log
          )
     } else {
          stop(paste0(
               densfun,
               " is not a supported distribution !"
          ))
     }
}

################################################################################
