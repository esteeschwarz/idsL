# Load required libraries
# library(jsonlite)
# library(dplyr)
# library(tidytext)
# library(igraph)
# library(ggplot2)
# library(stringr)
# library(purrr)
# library(tidyr)
# library(htmlwidgets)
# library(pandoc)
# pandoc_activate()
#library(RSQLite)

# Set random seed for reproducibility
set.seed(2025)
# plumber.R
library(plumber)
# library(tidytext)
# library(igraph)
# library(jsonlite)

# library(plumber)
# library(dplyr)
# library(tidyr)
# library(stringr)
# library(purrr)

#* @post /network
#* @json
function(req, res) {
  body <- jsonlite::fromJSON(req$postBody)
source(paste0(Sys.getenv("GIT_TOP"),"/idsL/backend/R/api/network-build.R"))
print("build script sourced...")
net.return<-build.net(body)

# list(
#   nodes = network_data_with_fields$nodes,
#   edges = network_data_with_fields$edges
# )
return(net.return)
}
#* @get /status
#* @serializer unboxedJSON
function() {
  list(
    status = "api running",
    time = Sys.time()
  )
}

#* @get /ids-version
#* @serializer unboxedJSON
function() {
  source(paste0(Sys.getenv("GIT_TOP"),"/idsL/backend/R/api/getversion.R"))
  latestversion<-getversion()
  latestversion
  
}

