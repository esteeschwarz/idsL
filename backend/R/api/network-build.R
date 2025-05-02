library(jsonlite)
library(dplyr)
library(tidytext)
library(igraph)
library(ggplot2)
library(stringr)
library(purrr)
library(tidyr)
library(htmlwidgets)
library(pandoc)
pandoc_activate()



# conn <- dbConnect(SQLite(), dbname = paste0(Sys.getenv("HKW_TOP"),"/SRV/mini/idsdatabase.db"))
# result <- dbGetQuery(conn, "SELECT * FROM entries")
#print(result)
## Step 1: Sample JSON schema data creation (if you don't have your own)
create_sample_json <- function(n_entries = 100) {
  entries <- lapply(1:n_entries, function(i) {
    list(
      id = paste0("id_", sprintf("%04d", i)),
      timestamp = format(Sys.time() - runif(1, 0, 86400*365), "%Y-%m-%dT%H:%M:%SZ"),
      text1 = paste(sample(c("data", "science", "analysis", "visualization", "R", "Python"), 5, replace = TRUE), collapse = " "),
      text2 = paste(sample(c("machine", "learning", "deep", "neural", "network", "AI"), 5, replace = TRUE), collapse = " "),
      text3 = paste(sample(c("tokenization", "natural", "language", "processing", "NLP", "text"), 5, replace = TRUE), collapse = " "),
      text4 = paste(sample(c("graph", "network", "nodes", "edges", "igraph", "visualization"), 5, replace = TRUE), collapse = " "),
      text5 = paste(sample(c("JSON", "schema", "data", "structure", "format", "parse"), 5, replace = TRUE), collapse = " "),
      text6 = paste(sample(c("statistics", "probability", "regression", "classification", "clustering"), 5, replace = TRUE), collapse = " "),
      text7 = paste(sample(c("big and fat greek wedding history and the quick brown fox jumps over the lazy fox", "data", "analytics", "business", "intelligence"), 5, replace = TRUE), collapse = " "),
      text8 = paste(sample(c("cloud", "computing", "storage", "AWS", "Azure", "GCP"), 5, replace = TRUE), collapse = " "),
      text9 = paste(sample(c("programming", "coding the quick brown fox jumps over the lazy fox", "development", "software", "engineering"), 5, replace = TRUE), collapse = " ")
    )
  })
  list(entries = entries)
}

build.net<-function(input){
# Create sample JSON data (or load your own)
print("build function called...")
body<-input
json_data <- create_sample_json(200)
json_data <- body
json_string <- toJSON(json_data, pretty = TRUE)
#.x<-entries
#x
## Step 2: Process JSON data into a tidy format with field information
process_json_data_with_fields <- function(json_data) {
 # entries <- json_data$entries
  entries_df <-json_data
#  entries <-json_data[1:length(json_data$id),]
  # Convert to dataframe with field information
  df<- pmap_dfr(entries_df, function(id, timestamp, ...) {
    # Extract all text fields (columns starting with "text")
    text_fields <- list(...)
    text_fields <- text_fields[grepl("^field", names(text_fields))]
    
  # df <- map_df(entries, ~{
  #   # Extract all text fields
  #   text_fields <- .x[grepl("^text", names(.x))]
  #   print(text_fields)
    # field<-"field1"
    # Create a row for each text field
    # map_df(names(text_fields), function(field) {
    #   tibble(
    #     id = .x$id,
    #     timestamp = .x$timestamp,
    #     field = field,
    #     text = text_fields[[field]]
    # 
    #   )
    # })
    map_df(names(text_fields), function(field) {
      tibble(
        id = id,
        timestamp = timestamp,
        field = field,
        text = text_fields[[field]]
        
      )
    })
  })
  
  return(df)
}

processed_data_with_fields <- process_json_data_with_fields(json_data)

## Step 3: Tokenize text and create node/edge dataframes with field information
create_token_network_with_fields <- function(text_df, min_edge_weight = 2, min_token_count = 5) {
  # Tokenize text (remove stopwords and punctuation, lowercase)
  tokens <- text_df %>%
    unnest_tokens(word, text) %>%
    filter(!word %in% stop_words$word,
           str_detect(word, "[a-z]")) %>%
    mutate(word = str_to_lower(word))
  
  # Create nodes dataframe with two types: tokens and fields
  token_nodes <- tokens %>%
    count(word, name = "count") %>%
    filter(count >= min_token_count) %>%
    arrange(desc(count)) %>%
    mutate(id = paste0("word_", row_number()),
           type = "token") %>%
    select(id, label = word, count, type)
  
  field_nodes <- tokens %>%
    distinct(field) %>%
    mutate(id = field,
           label = field,
           count = 0, # Placeholder, will calculate actual counts
           type = "field") %>%
    select(id, label, count, type)
  
  # Calculate field counts (how many tokens appear in each field)
  field_counts <- tokens %>%
    count(field, word) %>%
    group_by(field) %>%
    summarise(count = n(), .groups = "drop")
  
  field_nodes <- field_nodes %>%
    left_join(field_counts, by = c("id" = "field")) %>%
    mutate(count = ifelse(is.na(count.y), 0, count.y)) %>%
    select(id, label, count, type)
  
  # Combine all nodes
  nodes <- bind_rows(token_nodes, field_nodes)
  
  # Create edges of different types:
  # 1. Token-token co-occurrence within documents
  token_edges <- tokens %>%
    group_by(id) %>%
    mutate(from = word) %>%
    mutate(to = lead(word)) %>%
    filter(!is.na(to)) %>%
    ungroup() %>%
    count(from, to, name = "weight") %>%
    filter(weight >= min_edge_weight) %>%
    mutate(type = "token-token") %>%
    left_join(token_nodes %>% select(from_id = id, label), by = c("from" = "label")) %>%
    left_join(token_nodes %>% select(to_id = id, label), by = c("to" = "label")) %>%
    select(from = from_id, to = to_id, weight, type)
  
  # 2. Token-field relationships
  field_edges <- tokens %>%
    count(field, word, name = "weight") %>%
    left_join(token_nodes %>% select(word = label, token_id = id), by = "word") %>%
    filter(!is.na(token_id)) %>%
    mutate(type = "token-field") %>%
    select(from = token_id, to = field, weight, type)
  
  # Combine all edges
  edges <- bind_rows(token_edges, field_edges)
  
  return(list(nodes = nodes, edges = edges))
}

network_data_with_fields <- create_token_network_with_fields(processed_data_with_fields)

## Step 4: Create and plot the enhanced igraph network
plot_enhanced_network <- function(nodes, edges, 
                                  top_n_tokens = 50,
                                  node_size_range = c(3, 15),
                                  edge_width_range = c(0.5, 3)) {
  # Filter to top N most frequent tokens (fields are always included)
  top_tokens <- nodes %>%
    filter(type == "token") %>%
    arrange(desc(count)) %>%
    slice_head(n = top_n_tokens)
  
  # Get all field nodes
  field_nodes <- nodes %>% filter(type == "field")
  
  # Combine nodes to keep
  nodes_to_keep <- bind_rows(top_tokens, field_nodes)
  
  # Filter edges to only include kept nodes
  filtered_edges <- edges %>%
    filter(from %in% nodes_to_keep$id & to %in% nodes_to_keep$id)
  
  # Create igraph object
  net <- graph_from_data_frame(
    d = filtered_edges,
    vertices = nodes_to_keep,
    directed = FALSE
  )
  
  # Calculate layout
  l <- layout_with_fr(net)
  
  # Set visual attributes
  V(net)$size <- ifelse(
    V(net)$type == "token",
    scales::rescale(V(net)$count, to = node_size_range),
    max(node_size_range) * 1.2 # Make field nodes slightly larger
  )
  
  V(net)$color <- ifelse(V(net)$type == "token", "#4B9CD3", "#FF6B6B")
  V(net)$frame.color <- NA
  V(net)$label.color <- "black"
  V(net)$label.cex <- ifelse(V(net)$type == "token", 0.7, 0.9)
  V(net)$shape <- ifelse(V(net)$type == "token", "circle", "square")
  
  E(net)$width <- scales::rescale(E(net)$weight, to = edge_width_range)
  E(net)$color <- ifelse(E(net)$type == "token-token", "#A9A9A9", "#FFA07A")
  E(net)$lty <- ifelse(E(net)$type == "token-token", 1, 2)
  
  # Plot the network
  plot(net, 
       layout = l,
       main = "Token-Field Network",
       vertex.label.dist = 1,
       vertex.label.degree = -pi/2)
  
  # Add legend
  legend("bottomright", 
         legend = c("Token", "Field", "Token-Token", "Token-Field"), 
         col = c("#4B9CD3", "#FF6B6B", "#A9A9A9", "#FFA07A"), 
         pch = c(21, 22, NA, NA),
         lty = c(NA, NA, 1, 2),
         pt.bg = c("#4B9CD3", "#FF6B6B", NA, NA),
         pt.cex = c(2, 2, NA, NA),
         bty = "n")
}

# Plot the enhanced network
plot_enhanced_network(network_data_with_fields$nodes, network_data_with_fields$edges)

## Optional: Interactive visualization with visNetwork
if (!requireNamespace("visNetwork", quietly = TRUE)) {
  install.packages("visNetwork")
}
library(visNetwork)

# Create interactive visualization
network<-visNetwork(
  nodes = network_data_with_fields$nodes %>% 
    mutate(
      title = paste0(label, ": ", count, ifelse(type == "token", " occurrences", " tokens")),
      value = count,
      group = type,
      font.size = 24,
      shape = ifelse(type == "token", "dot", "square"),
      color = ifelse(type == "token", list(background = "#4B9CD3", border = "#2B7CB5"), 
                     list(background = "#FF6B6B", border = "#D64550"))
    ),
  edges = network_data_with_fields$edges %>%
    mutate(
      color = ifelse(type == "token-token", "#A9A9A9", "#FFA07A"),
      dashes = ifelse(type == "token-token", FALSE, TRUE)
    )
) %>%
  visNodes(borderWidth = 2) %>%
  visEdges(smooth = FALSE) %>%
  visGroups(groupname = "token", color = "#4B9CD3", shape = "dot") %>%
  visGroups(groupname = "field", color = "#FF6B6B", shape = "square") %>%
  visLegend() %>%
  visInteraction(
    keyboard = TRUE,
    navigationButtons = TRUE
  ) %>%
  # visOptions(manipulation = list(
  #   enabled = TRUE,
  #   addNode = FALSE,
  #   addEdge = FALSE,
  #   editNode = FALSE,
  #   editEdge = FALSE,
  #   deleteNode = FALSE,
  #   deleteEdge = FALSE,
  #   initiallyActive = FALSE
  # )) %>%
  # visEvents(type = "on", initRedraw = "function() {
  #   // Only create button if it doesn't exist yet
  #   if (!document.getElementById('physicsToggleBtn')) {
  #     var btn = document.createElement('button');
  #     btn.id = 'physicsToggleBtn';
  #     btn.innerHTML = 'Stop Physics';
  #     btn.style.position = 'absolute';
  #     btn.style.top = '10px';
  #     btn.style.left = '10px';
  #     btn.style.zIndex = '1000';
  #     btn.onclick = function() {
  #       network.setOptions({physics: !network.physics.physicsEnabled});
  #       this.innerHTML = network.physics.physicsEnabled ? 'Stop Physics' : 'Start Physics';
  #     };
  #     
  #     // Add to container div (better than document.body)
  #     var container = document.getElementById('htmlwidget_container');
  #     if (container) {
  #       container.style.position = 'relative';
  #       container.appendChild(btn);
  #     } else {
  #       document.body.appendChild(btn);
  #     }
  #   }
  # }") %>%

  visLayout(randomSeed = 2025) %>%
  visPhysics(enabled = FALSE) %>% # THIS DISABLES ANIMATION
  # visIgraphLayout(layout = "layout_with_fr")  # Uses igraph's static layout

  visPhysics(solver = "forceAtlas2Based",
             forceAtlas2Based = list(gravitationalConstant = -50),
             stabilization = list(iterations=20),maxVelocity = 50) %>%
  visEvents(stabilizationIterationsDone = "function() {
    this.setOptions({physics: false});
  }")

saveWidgetFix <- function(plot, file, selfcontained = TRUE) {
  # Fix for saving visNetwork properly
  tempFile <- file.path(tempdir(), "temp.html")
  saveWidget(plot, file = tempFile, selfcontained = selfcontained)
  htm<-readLines(tempFile)
  htm<-gsub("</head>",'<link href="styles.css" rel="stylesheet" />
</head>',htm)
  writeLines(htm,tempFile)
  file.copy(tempFile, file,overwrite = T)
file.copy("styles.css", paste0(Sys.getenv("WWW_TOP"),"/cloud/ids/network/styles.css"),overwrite=T)
  #invisible()
}

# Save the network with a timestamp
output_file <- paste0(Sys.getenv("WWW_TOP"),"/cloud/ids/network/index", ".html")
saveWidgetFix(network, output_file, selfcontained = TRUE)

message("Network saved as: ", normalizePath(output_file))
cat("Network saved as: ", normalizePath(output_file),"\n")
#network
  
net.return<-list(
  nodes = network_data_with_fields$nodes,
  edges = network_data_with_fields$edges
)

}