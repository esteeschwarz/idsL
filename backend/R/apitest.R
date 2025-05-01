library(httr)

# Define the URL and headers
url <- "http://127.0.0.1:4173/network"
headers <- c("Content-Type" = "application/json")

# Read the JSON data from the file
json_data <- readLines("sample_data_100.json", warn = FALSE)

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
