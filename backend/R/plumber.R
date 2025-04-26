# plumber.R
library(plumber)

pr("/home/esteeadnim/gith/idsL/backend/R/api/network.R") |>  # assuming your plumber file is in `api/` directory
  pr_run(
    host = "0.0.0.0",  # IMPORTANT! Makes it accessible from other devices
    port = 4173
  )
