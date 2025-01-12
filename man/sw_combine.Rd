% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sw_combine.R
\name{sw_combine}
\alias{sw_combine}
\title{sw_combine: compute a felling date range by combining multiple sapwood estimates}
\usage{
sw_combine(
  x,
  series = "series",
  last = "last",
  n_sapwood = "n_sapwood",
  waneyedge = "waneyedge",
  sw_data = "Hollstein_1980",
  densfun = "lognormal",
  sep = ";",
  credMass = 0.954,
  hdi = TRUE,
  plot = FALSE
)
}
\arguments{
\item{x}{Name of a \code{data.frame} with at least four columns, providing
information on the id's of the tree-ring series, the number of sapwood
rings observed, the presence of waney edge and the date assigned to the
last measured ring. A column describing the sapwood data set to be used
for modelling and the computation of the hdi can be provided as well.}

\item{series}{Name of the column in \code{x} where id's of the tree-ring series
are listed as \code{character} values.}

\item{last}{Name of the column in \code{x} which lists the calendar year assigned
to the last measured ring. Should be \code{numeric}.}

\item{n_sapwood}{Name of the column in \code{x} where the number of observed
sapwood rings are listed. This variable should be \code{numeric}.}

\item{waneyedge}{Name of the column in \code{x} indicating the presence
(\code{TRUE})/absence (\code{FALSE}) of waney edge. Should be a \code{logical} vector.}

\item{sw_data}{The name of the sapwood data set to use for modelling.
Should be one of \code{\link[=sw_data_overview]{sw_data_overview()}}, or the path to a .csv file with
columns ´n_sapwood´ and ´count´.}

\item{densfun}{Name of the density function fitted to the sapwood data set.
Should be one of:
\itemize{
\item "lognormal" (the default value),
\item "normal",
\item "weibull",
\item "gammma".
}}

\item{sep}{Should be "," (comma)  or ";" (semi-colon) and is used when a
sapwood data set is provided from user-defined .csv-file.}

\item{credMass}{A \code{scalar [0, 1]} specifying the mass within the credible
interval (default = .954).}

\item{hdi}{A \code{logical.} If \code{TRUE}: the lower and upper limit of the
highest density interval (credible interval) is given for the felling date.
When \code{FALSE}: a matrix is returned with scaled p values for calendar years
covering the combined estimate of the felling date range.}

\item{plot}{A \code{logical}. If \code{TRUE} a plot is returned of the individual and
combined estimate of the felling date.
If \code{FALSE} a list with numeric output of the modelling process is returned.}
}
\value{
Depends on the value of plot. If TRUE a ggplot style
When \code{FALSE} a \code{data.frame} with the combined probability and modelling parameters
}
\description{
Combine multiple estimates of the felling date for a single event.
}
\examples{
# a data set in which all series have preserved sapwood

dummy1 <- data.frame(
series = c("trs_06", "trs_07", "trs_08", "trs_09", "trs_10"),
last = c(1000, 1009, 1007, 1005, 1010),
n_sapwood = c(5, 10, 15, 16, 8),
waneyedge = c(FALSE, FALSE, FALSE, FALSE, FALSE)
)
sw_combine(dummy1, plot = TRUE)

# a data set in which one series has an exact felling date (= waney edge preserved)

dummy2 <- data.frame(
series = c("trs_11", "trs_12", "trs_13", "trs_14", "trs_15"),
last = c(1000, 1005, 1008, 1000, 1010),
n_sapwood = c(5, 10, NA, 1, 3),
waneyedge = c(FALSE, FALSE, FALSE, FALSE, TRUE)
)
sw_combine(dummy2, plot = TRUE)

sw_combine(fellingdateR:::dummy4, plot= FALSE)

}
