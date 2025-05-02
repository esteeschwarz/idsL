library(httr)
library(jsonlite)
# Define the URL and headers
url <- "http://0.0.0.0:4173/network"
url <- paste0("https://ids.",Sys.getenv("DHI_TOP"),"/api/network")
headers <- c("Content-Type" = "application/json")
wd<-Sys.getenv("GIT_TOP")
# Read the JSON data from the file
json_data <- readLines(paste0(wd,"/idsL/backend/R/sample_data_100.json"), warn = FALSE)

# Perform the POST request
response <- POST(url, add_headers(.headers = headers), body = json_data, encode = "json")

# Print the response
if (http_type(response) == "application/json") {
  print(content(response, as = "parsed", type = "application/json"))
} else {
  print(content(response, as = "text"))
}
df<-content(response, as = "parsed", type = "application/json")
df<-fromJSON(content(response,"text"))
