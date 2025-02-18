% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/subset_nhdplus.R
\name{subset_nhdplus}
\alias{subset_nhdplus}
\title{Subset NHDPlus}
\usage{
subset_nhdplus(
  comids = NULL,
  output_file = NULL,
  nhdplus_data = NULL,
  bbox = NULL,
  simplified = TRUE,
  overwrite = FALSE,
  return_data = TRUE,
  status = TRUE,
  flowline_only = NULL,
  streamorder = NULL,
  out_prj = 4269
)
}
\arguments{
\item{comids}{integer vector of COMIDs to include.}

\item{output_file}{character path to save the output to defaults
to the directory of the nhdplus_data.}

\item{nhdplus_data}{character path to the .gpkg or .gdb containing
the national seamless database, a subset of NHDPlusHR,
or "download" to use a web service to download NHDPlusV2.1 data.
Not required if \code{\link{nhdplus_path}} has been set or the default
has been adopted. See details for more.}

\item{bbox}{object of class "bbox" as returned by sf::st_bbox in Latitude/Longitude.
If no CRS is present, will be assumed to be in WGS84 Latitude Longitude.}

\item{simplified}{boolean if TRUE (the default) the CatchmentSP layer
will be included. Not relevant to the "download" option or NHDPlusHR data.}

\item{overwrite}{boolean should the output file be overwritten}

\item{return_data}{boolean if FALSE path to output file is returned silently otherwise
data is returned in a list.}

\item{status}{boolean should the function print status messages}

\item{flowline_only}{boolean WARNING: experimental
if TRUE only the flowline network and attributes will be returned}

\item{streamorder}{integer only streams of order greater than or equal will be downloaded.
Not implemented for local data.}

\item{out_prj}{character override the default output CRS of NAD83 lat/lon (EPSG:4269)}
}
\value{
character path to the saved subset geopackage
}
\description{
Saves a subset of the National Seamless database or other
nhdplusTools compatible data based on a specified collection of COMIDs.
This function uses \code{\link{get_nhdplus}} for the "download" data
source but returns data consistent with local data subsets in a subset
file.
}
\details{
This function relies on the National Seamless Geodatabase or Geopackage.
It can be downloaded
\href{https://www.epa.gov/waterdata/nhdplus-national-data}{here.}

The "download" option of this function should be considered preliminary
and subject to revision. It does not include as many layers and may not
be available permenently.
}
\examples{
\donttest{

source(system.file("extdata/sample_data.R", package = "nhdplusTools"))

nhdplus_path(sample_data)

staged_nhdplus <- stage_national_data(output_path = tempdir())

sample_flines <- readRDS(staged_nhdplus$flowline)

geom_col <- attr(sample_flines, "sf_column")

plot(sample_flines[[geom_col]],
     lwd = 3)

start_point <- sf::st_sfc(sf::st_point(c(-89.362239, 43.090266)),
                          crs = 4326)

plot(start_point, cex = 1.5, lwd = 2, col = "red", add = TRUE)

start_comid <- discover_nhdplus_id(start_point)

comids <- get_UT(sample_flines, start_comid)

plot(dplyr::filter(sample_flines, COMID \%in\% comids)[[geom_col]],
     add=TRUE, col = "red", lwd = 2)

output_file <- tempfile(fileext = ".gpkg")

subset_nhdplus(comids = comids,
               output_file = output_file,
               nhdplus_data = sample_data,
               overwrite = TRUE,
               status = TRUE)

sf::st_layers(output_file)

catchment <- sf::read_sf(output_file, "CatchmentSP")

plot(catchment[[attr(catchment, "sf_column")]], add = TRUE)

waterbody <- sf::read_sf(output_file, "NHDWaterbody")

plot(waterbody[[attr(waterbody, "sf_column")]],
     col = rgb(0, 0, 1, alpha = 0.5), add = TRUE)

# Cleanup temp
sapply(staged_nhdplus, unlink)
unlink(output_file)

# Download Option:
subset_nhdplus(comids = comids,
               output_file = output_file,
               nhdplus_data = "download",
               overwrite = TRUE,
               status = TRUE, flowline_only = FALSE)

sf::st_layers(output_file)

# NHDPlusHR
source(system.file("extdata/nhdplushr_data.R", package = "nhdplusTools"))

up_ids <- get_UT(hr_data$NHDFlowline, 15000500028335)

sub_gpkg <- file.path(work_dir, "sub.gpkg")
sub_nhdhr <- subset_nhdplus(up_ids, output_file = sub_gpkg,
                            nhdplus_data = hr_gpkg, overwrite = TRUE)

sf::st_layers(sub_gpkg)
names(sub_nhdhr)

plot(sf::st_geometry(hr_data$NHDFlowline), lwd = 0.5)
plot(sf::st_geometry(sub_nhdhr$NHDFlowline), lwd = 0.6, col = "red", add = TRUE)

unlink(output_file)
unlink(sub_gpkg)

}

}
