# plumber.R
library(plumber)
library(tidytext)
library(igraph)
library(jsonlite)

# call: pr("plumber.R") %>% pr_run(port = 4173)
# pr("/home/esteeadnim/gith/idsL/backend/R/plumber.R") |>  # assuming your plumber file is in `api/` directory
#   pr_run(
#     host = "0.0.0.0",  # IMPORTANT! Makes it accessible from other devices
#     port = 4173
#   )



# #* @post /network
# function(req) {
#   df <- fromJSON(req$postBody)
#   
#   # df should have columns: text1...text9, timestamp
#   
#   # Unnest all text fields into one column
#   tokens <- df %>%
#     pivot_longer(cols = starts_with("text")) %>%
#     unnest_tokens(word, value) %>%
#     group_by(timestamp) %>%
#     distinct(word, .keep_all = TRUE)
#   
#   edges <- tokens %>%
#     inner_join(tokens, by = "word", suffix = c("_1", "_2")) %>%
#     filter(timestamp_1 < timestamp_2) %>%
#     count(timestamp_1, timestamp_2)
#   
#   list(
#     nodes = unique(data.frame(id = tokens$timestamp)),
#     edges = edges
#   )
# }
# library(plumber)
library(dplyr)
 library(tidyr)
library(stringr)
library(purrr)

#* @post /network
#* @json
function(req, res) {
  body <- jsonlite::fromJSON(req$postBody)
  
  # Example body: a list of entries with id, timestamp, field1...field9
  
  # Collapse all fields into tokens
  entries <- body %>%
    as_tibble() %>%
    mutate(all_text = paste(field1, field2, field3, field4, field5, field6, field7, field8, field9, sep = " ")) %>%
    mutate(tokens = str_split(all_text, "\\s+")) %>%  # Tokenize by whitespace
    select(id, timestamp, tokens)
  
  # Create edge list by joining tokens with timestamps
  edges <- entries %>%
    unnest(tokens) %>%
    group_by(token = str_to_lower(tokens)) %>%
    # summarize(timestamps = list(timestamp), .groups = "drop") %>%
    reframe(timestamps = list(timestamp), .groups = "drop") %>%
    filter(lengths(timestamps) > 1) %>%   # Only tokens appearing in multiple timestamps
    unnest(timestamps) %>%
    group_by(token) %>%
    # summarize(pairs = combn(timestamps, 2, simplify = FALSE), .groups = "drop") %>%
    reframe(pairs = combn(timestamps, 2, simplify = FALSE), .groups = "drop") %>%
    unnest(pairs) %>%
    mutate(source = map_chr(pairs, 1),
           target = map_chr(pairs, 2)) %>%
    select(token, source, target) %>%
    mutate(id = paste0(token, "-", source, "-", target))
  
  # Build nodes list
  timestamps <- unique(c(edges$source, edges$target))
  nodes <- tibble(
    id = timestamps,
    label = timestamps
  )
  
  # Return as JSON
  list(
    nodes = nodes,
    edges = edges %>% select(id, source, target)
  )
}
