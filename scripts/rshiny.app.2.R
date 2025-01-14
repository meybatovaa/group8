library(shiny)
library(shinydashboard)
library(data.table)
library(ggplot2)
library(plotly)
library(DT)
library(viridis)
library(pheatmap)
library(dendextend)
library(grid)
library(gridExtra)
library(RColorBrewer)
library(cluster)
library(dplyr)
library(tidyr)

# Function to categorize parameters based on their name or description
categorize_parameter <- function(param_name, param_id) {
  # Combine both parameter_name and parameter_id to make the search more robust
  param_lower <- tolower(paste(param_name, param_id, sep = " "))
  
  # Weight category
  if (grepl("weight|mass|bw|body weight", param_lower)) {
    return("Weight")
  }
  
  # Image category
  if (grepl("image|xray|picture", param_lower)) {
    return("Images")
  }
  
  # Brain category
  if (grepl("brain|neuro|behavior|cognitive|memory|learning|startle|inhibition|locomotor|activity|arousal|vocalization|movement|speed|distance|rearing|mobile|holepoke", param_lower)) {
    return("Brain")
  }
  
  # Equipment category
  if (grepl("equipment", param_lower)) {
    return("Equipment")
  }
  
  # Eye category (vision)
  if (grepl("eye|retina|lens|vision|optic", param_lower)) {
    return("Vision/Eye")
  }
  
  # Blood category (includes immune system-related)
  if (grepl("blood|immune|cell|hemoglobin|platelet|lymph|plasma", param_lower)) {
    return("Blood")
  }
  
  # Cardiovascular category
  if (grepl("heart|cardio|pressure|pulse|vessel", param_lower)) {
    return("Cardiovascular")
  }
  
  # Muscular category
  if (grepl("muscle|strength|motor|movement", param_lower)) {
    return("Muscular")
  }
  
  # Metabolic category
  if (grepl("metabolism|glucose|lipid|insulin|cholesterol|fat", param_lower)) {
    return("Metabolic")
  }
  
  # Respiratory category
  if (grepl("lung|respirat|breath|hypoxia", param_lower)) {
    return("Respiratory")
  }
  
  # Reproductive category
  if (grepl("placenta|vagina|ovary|teste|uterus|prostate|penis|umbilic", param_lower)) {
    return("Reproductive")
  }
  
  # Coat/Skin category
  if (grepl("skin|coat|hair|dermis", param_lower)) {
    return("Coat/Skin")
  }
  
  # Housing category
  if (grepl("housing|cage", param_lower)) {
    return("Housing")
  }
  
  # Conditions category (experimental context)
  if (grepl("condition|context|cue", param_lower)) {
    return("Conditions")
  }
  
  # Biochemical category (specific IDs like CBC)
  if (grepl("cbc|biochemical", param_lower)) {
    return("Biochemical")
  }
  
  
  # Default catch-all category for parameters that do not match any of the above
  return("Other")
}

# Read and prepare data
merged_data <- fread("merged_data_clean.csv")

# Find the smallest non-zero p-value
min_nonzero_pvalue <- min(merged_data$pvalue[merged_data$pvalue > 0], na.rm = TRUE)

# Fix p-values that are 0 by setting them to the smallest non-zero p-value
merged_data[, pvalue := ifelse(pvalue == 0, min_nonzero_pvalue, pvalue)]

# Create categories using the categorize_parameter function
merged_data[, category := mapply(categorize_parameter, parameter_name, parameter_id)]

# Create processed p-value column
merged_data[, processed_pvalue := -log10(pvalue)]

# Convert to factors
merged_data[, `:=`(
  gene_symbol = as.factor(gene_symbol),
  parameter_name = as.factor(parameter_name),
  category = as.factor(category)
)]

# UI
ui <- dashboardPage(
  dashboardHeader(title = "IMPC Gene Phenotype Analysis"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Gene View", tabName = "gene", icon = icon("dna")),
      menuItem("Phenotype View", tabName = "parameter", icon = icon("chart-bar")),
      menuItem("Clustering", tabName = "viz", icon = icon("project-diagram"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Gene Analysis Tab
      tabItem(
        tabName = "gene",
        fluidRow(
          column(3,
            wellPanel(
              # Gene selection - changed to show gene names
              selectInput("selected_gene", "Select Gene:",
                choices = c("All" = "all", sort(as.character(unique(merged_data$gene_symbol))))),
              # Custom gene list input
              textAreaInput("custom_genes", "Or paste custom gene list (one per line or comma-separated):",
                          rows = 4),
              selectInput("selected_strain", "Select Strain:",
                choices = c("All", unique(merged_data$mouse_strain))),
              selectInput("phenotype_category_gene", "Filter by Category:",
                choices = c("All", sort(unique(as.character(merged_data$category))))),
              selectInput("selected_parameters", "Select Parameters:",
                choices = NULL,
                multiple = TRUE),
              numericInput("pvalue_threshold", "P-value threshold:",
                value = 0.05, min = 0, max = 1, step = 0.01)
            )
          ),
          column(9,
            box(width = 12,
              plotlyOutput("gene_plot", height = "500px")
            ),
            box(width = 12,
              title = "Significant Phenotypes",
              DTOutput("gene_phenotypes")
            )
          )
        )
      ),
      
      # Parameter Analysis Tab
      tabItem(
        tabName = "parameter",
        fluidRow(
          column(3,
            wellPanel(
              selectInput("phenotype_category_param", "Filter by Category:",
                choices = c("All", sort(unique(as.character(merged_data$category))))),
              selectInput("selected_parameter", "Select Parameter:",
                choices = NULL),
              numericInput("param_pvalue_threshold", "P-value threshold:",
                value = 0.05, min = 0, max = 1, step = 0.01)
            )
          ),
          column(9,
            box(width = 12,
              plotlyOutput("parameter_plot", height = "500px")
            ),
            box(width = 12,
              title = "Significant Genes",
              DTOutput("parameter_genes")
            )
          )
        )
      ),
      
      # Clustering Tab
      tabItem(
        tabName = "viz",
        fluidRow(
          column(3,
            wellPanel(
              selectInput("clustering_category", "Phenotype Category",
                         choices = c("All", sort(unique(as.character(merged_data$category)))),
                         selected = "All"),
              
              # Dynamic phenotype selector
              conditionalPanel(
                condition = "input.clustering_category != 'All'",
                selectInput("clustering_phenotypes", "Specific Phenotypes",
                           choices = NULL,
                           multiple = TRUE)
              ),
              
              selectInput("clustering_life_stage", "Life Stage",
                         choices = c("All", "Early adult", "Late adult", "E9.5", 
                                   "E12.5", "E15.5", "E18.5"),
                         selected = "All"),
              
              selectInput("clustering_strain", "Mouse Strain",
                         choices = c("All", unique(merged_data$mouse_strain)),
                         selected = "All"),
              
              actionButton("reset_clustering", "Reset Filters",
                          class = "btn-primary"),
              
              br(), br(),
              downloadButton("download_clustering", "Download Results")
            )
          ),
          column(9,
            fluidRow(
              box(width = 12,
                  title = "Principal Component Analysis",
                  status = "primary",
                  solidHeader = TRUE,
                  plotlyOutput("pca_plot", height = "500px")
              )
            ),
            fluidRow(
              box(width = 12,
                  title = "Gene Correlation Heatmap",
                  status = "primary",
                  solidHeader = TRUE,
                  plotOutput("heatmap", height = "700px")  
              )
              
            ),
            fluidRow(
              box(width = 12,
                  title = "Phenotype Distribution",
                  status = "primary",
                  solidHeader = TRUE,
                  plotOutput("phenotype_dist", height = "200px")
              )
            )
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # Process custom gene list
  custom_gene_list <- reactive({
    req(input$custom_genes)
    genes <- unique(unlist(strsplit(gsub("\\s+", ",", input$custom_genes), ",")))
    genes[genes != ""]  # Remove empty strings
  })

  # Update parameters when category is selected (Gene View)
  observeEvent(input$phenotype_category_gene, {
    if (input$phenotype_category_gene == "All") {
      choices <- sort(unique(merged_data$parameter_name))
    } else {
      choices <- sort(unique(merged_data[category == input$phenotype_category_gene]$parameter_name))
    }
    updateSelectInput(session, "selected_parameters",
                     choices = choices,
                     selected = choices) # Auto-select all parameters in category
  })
  
  # Update parameter choices based on category selection
  observe({
    if (input$phenotype_category_param == "All") {
      param_choices <- unique(merged_data$parameter_name)
    } else {
      param_choices <- unique(merged_data[category == input$phenotype_category_param, parameter_name])
    }
    updateSelectInput(session, "selected_parameter",
      choices = c("All" = "all", sort(as.character(param_choices)))
    )
  })

  # Update parameters when category is selected (Parameter View)
  observeEvent(input$phenotype_category_param, {
    if (input$phenotype_category_param == "All") {
      choices <- sort(unique(merged_data$parameter_name))
    } else {
      choices <- sort(unique(merged_data[category == input$phenotype_category_param]$parameter_name))
    }
    updateSelectInput(session, "selected_parameter",
                     choices = choices)
  })
  
  # Update clustering phenotypes when category is selected
  observeEvent(input$clustering_category, {
    if (input$clustering_category == "All") {
      updateSelectInput(session, "clustering_phenotypes", choices = NULL)
    } else {
      choices <- sort(unique(merged_data[category == input$clustering_category]$parameter_name))
      updateSelectInput(session, "clustering_phenotypes",
                       choices = choices,
                       selected = choices) # Auto-select all phenotypes in category
    }
  })
  
  # Gene View Plot
  output$gene_plot <- renderPlotly({
    # Get selected genes (either from dropdown or custom list)
    selected_genes <- if (!is.null(input$custom_genes) && input$custom_genes != "") {
      custom_gene_list()
    } else if (input$selected_gene == "all") {
      unique(merged_data$gene_symbol)
    } else {
      input$selected_gene
    }
    
    # Filter data
    gene_data <- merged_data[gene_symbol %in% selected_genes]
    
    if (input$phenotype_category_gene != "All") {
      gene_data <- gene_data[category == input$phenotype_category_gene]
    }
    
    if (!is.null(input$selected_parameters) && length(input$selected_parameters) > 0) {
      gene_data <- gene_data[parameter_name %in% input$selected_parameters]
    }
    
    # Create plot title
    plot_title <- if (length(selected_genes) == 1) {
      paste("Phenotype Scores for", selected_genes)
    } else {
      "Phenotype Scores for Selected Genes"
    }
    
    p <- ggplot(gene_data, aes(x = parameter_name, y = processed_pvalue,
                              text = sprintf(
                                "Parameter: %s\nP-value: %.2e\nCategory: %s",
                                parameter_name, pvalue, category
                              ))) +
      geom_point(aes(color = pvalue <= input$pvalue_threshold),
                 size = 3) +
      geom_hline(yintercept = -log10(input$pvalue_threshold), 
                 linetype = "dashed", color = "red") +
      scale_color_manual(values = c("grey", "red")) +
      theme_minimal() +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.margin = margin(30, 10, 10, 10)
      ) +
      labs(x = NULL, y = "-log10(p-value)",
           title = plot_title) +
      guides(color = FALSE)
    
    ggplotly(p, tooltip = "text")
  })
  
  # Gene View Table
  output$gene_phenotypes <- renderDT({
    # Get selected genes (either from dropdown or custom list)
    selected_genes <- if (!is.null(input$custom_genes) && input$custom_genes != "") {
      custom_gene_list()
    } else if (input$selected_gene == "all") {
      unique(merged_data$gene_symbol)
    } else {
      input$selected_gene
    }
    
    # Filter data
    gene_data <- merged_data[gene_symbol %in% selected_genes]
    
    if (input$phenotype_category_gene != "All") {
      gene_data <- gene_data[category == input$phenotype_category_gene]
    }
    
    if (!is.null(input$selected_parameters) && length(input$selected_parameters) > 0) {
      gene_data <- gene_data[parameter_name %in% input$selected_parameters]
    }
    
    gene_data <- gene_data[pvalue <= input$pvalue_threshold]
    
    if (nrow(gene_data) == 0) {
      return(datatable(
        data.frame(Message = "No significant phenotypes found. Try adjusting the p-value threshold."),
        options = list(dom = 't'),
        rownames = FALSE
      ))
    }
    
    summary_data <- unique(gene_data[order(pvalue), .(
      Phenotype = parameter_name,
      Category = category,
      `P-value` = format(pvalue, scientific = TRUE, digits = 3)
    )])
    
    datatable(
      summary_data,
      options = list(
        pageLength = 5,
        scrollX = TRUE
      ),
      rownames = FALSE
    )
  })
  
  # Phenotype View Plot
  output$parameter_plot <- renderPlotly({
    param_data <- if (input$selected_parameter == "all") {
      if (input$phenotype_category_param == "All") {
        merged_data
      } else {
        merged_data[category == input$phenotype_category_param]
      }
    } else {
      merged_data[parameter_name == input$selected_parameter]
    }
    
    p <- ggplot(param_data, aes(x = gene_symbol, y = processed_pvalue,
                               text = sprintf(
                                 "Gene: %s\nP-value: %.2e\nStrain: %s",
                                 gene_symbol, pvalue, mouse_strain
                               ))) +
      geom_point(aes(color = pvalue <= input$param_pvalue_threshold),
                 size = 3) +
      geom_hline(yintercept = -log10(input$param_pvalue_threshold), 
                 linetype = "dashed", color = "red") +
      scale_color_manual(values = c("grey", "red")) +
      theme_minimal() +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.margin = margin(30, 10, 10, 10)
      ) +
      labs(x = "Genes", y = "-log10(p-value)",
           title = sprintf("Gene Effects on %s", input$selected_parameter)) +
      guides(color = FALSE)
    
    ggplotly(p, tooltip = "text")
  })
  
  # Phenotype View Table
  output$parameter_genes <- renderDT({
    param_data <- merged_data[parameter_name == input$selected_parameter & 
                             pvalue <= input$param_pvalue_threshold]
    
    if (nrow(param_data) == 0) {
      return(datatable(
        data.frame(Message = "No significant genes found. Try adjusting the p-value threshold."),
        options = list(dom = 't'),
        rownames = FALSE
      ))
    }
    
    summary_data <- unique(param_data[, .(
      Gene = gene_symbol,
      Strain = mouse_strain,
      `P-value` = format(pvalue, scientific = TRUE, digits = 3)
    )])
    
    datatable(
      summary_data,
      options = list(
        pageLength = 5,
        scrollX = TRUE,
        order = list(list(2, 'asc'))
      ),
      rownames = FALSE
    )
  })

  
  # Clustering View Functions
  clustering_data <- reactive({
    print("Clustering data reactive triggered")
    # Filter data based on clustering-specific inputs
    data <- merged_data
    
    print("Initial data rows:")
    print(nrow(data))
    print("Initial categories:")
    print(unique(data$category))
    
    if (input$clustering_strain != "All") {
      data <- data[mouse_strain == input$clustering_strain]
    }
    
    if (input$clustering_life_stage != "All") {
      data <- data[mouse_life_stage == input$clustering_life_stage]
    }
    
    # First filter by category if selected
    if (input$clustering_category != "All") {
      print("Selected category:")
      print(input$clustering_category)
      
      # Handle both single category and multiple categories
      if (grepl(" and ", input$clustering_category)) {
        categories <- unlist(strsplit(input$clustering_category, " and "))
        print("Multiple categories:")
        print(categories)
        data <- data[category %in% categories]
      } else {
        data <- data[category == input$clustering_category]
      }
      
      print("Rows after category filter:")
      print(nrow(data))
      print("Parameters after category filter:")
      print(unique(data$parameter_name))
      
      if (!is.null(input$clustering_phenotypes) && length(input$clustering_phenotypes) > 0) {
        data <- data[parameter_name %in% input$clustering_phenotypes]
      }
    }
    
    # Filter for significant p-values
    data <- data[pvalue <= 0.05]
    
    print("Rows after p-value filter:")
    print(nrow(data))
    
    # Check if we have any data after filtering
    if (nrow(data) == 0) {
      print("No data after filtering")
      return(NULL)  # Return NULL if no significant results
    }
    
    # For each parameter, create a binary indicator of significance
    unique_params <- unique(data$parameter_name)
    all_genes <- unique(data$gene_symbol)
    
    print("Number of unique parameters:")
    print(length(unique_params))
    print("Parameters:")
    print(unique_params)
    print("Number of unique genes:")
    print(length(all_genes))
    print("Genes:")
    print(all_genes)
    
    # Return NULL if we don't have enough data
    if (length(unique_params) == 0 || length(all_genes) == 0) {
      print("No parameters or genes found")
      return(NULL)
    }
    
    # Create a matrix where 1 indicates a significant phenotype for that gene-parameter combination
    tryCatch({
      matrix_data <- matrix(0, nrow = length(all_genes), ncol = length(unique_params))
      rownames(matrix_data) <- all_genes
      colnames(matrix_data) <- unique_params
      
      # Fill the matrix with 1s where there are significant phenotypes
      for (i in seq_along(all_genes)) {
        gene_data <- data[gene_symbol == all_genes[i]]
        if (nrow(gene_data) > 0) {  # Only process if we have data for this gene
          param_indices <- match(gene_data$parameter_name, unique_params)
          matrix_data[i, param_indices] <- 1
        }
      }
      
      print("Matrix dimensions:")
      print(dim(matrix_data))
      
      # Calculate correlation using binary phenotype matrix
      cor_matrix <- try(cor(t(matrix_data), method = "pearson"), silent = TRUE)
      
      # Check if correlation calculation was successful
      if (inherits(cor_matrix, "try-error")) {
        print("Error in correlation calculation")
        return(NULL)
      }
      
      return(list(
        raw_data = data,
        matrix = matrix_data,
        correlation_matrix = cor_matrix,
        genes = all_genes
      ))
    }, error = function(e) {
      print("Error in matrix creation:")
      print(e$message)
      return(NULL)
    })
  })
  
  output$heatmap <- renderPlot({
    # Get the clustering data
    clust_data <- clustering_data()
    
    # Check if clustering data is NULL
    if (is.null(clust_data)) {
      plot.new()
      text(0.5, 0.5, "No significant phenotypes found for the selected criteria", cex = 1.2)
      return()
    }
    
    tryCatch({
      # Ensure that the correlation matrix is valid and non-empty
      if (is.null(clust_data$correlation_matrix) || any(is.na(clust_data$correlation_matrix))) {
        plot.new()
        text(0.5, 0.5, "Error: Invalid or empty correlation matrix", cex = 1.2)
        return()
      }
      
      # Create color palette and breaks
      my_colors <- colorRampPalette(c("white", "red"))(100)
      breaks <- seq(0, 1, length.out = 101)
      
      # Set title based on category
      title <- if (input$clustering_category == "All") {
        "Gene Correlation Heatmap - All Categories"
      } else {
        paste0("Gene Correlation Heatmap - ", input$clustering_category)
      }
      
      # Generate heatmap
      pheatmap(clust_data$correlation_matrix,
               clustering_distance_rows = "correlation",
               clustering_distance_cols = "correlation",
               clustering_method = "complete",
               show_rownames = TRUE,
               show_colnames = TRUE,
               fontsize_row = 8,
               fontsize_col = 8,
               angle_col = 45,
               color = my_colors,
               breaks = breaks,
               main = title,
               legend = TRUE)
    }, error = function(e) {
      plot.new()
      text(0.5, 0.5, paste("Error creating heatmap:", e$message), cex = 1.2)
    })
  })
  
  # PCA Plot
  output$pca_plot <- renderPlotly({
    clust_data <- clustering_data()
    
    if (is.null(clust_data)) {
      plot_ly() %>%
        add_annotations(
          text = "No significant phenotypes found for the selected criteria",
          showarrow = FALSE,
          font = list(size = 16)
        )
    } else {
      # Perform PCA on the matrix
      pca <- prcomp(clust_data$matrix)
      
      # Create plot data
      plot_data <- data.frame(
        PC1 = pca$x[,1],
        PC2 = pca$x[,2],
        gene = clust_data$genes
      )
      
      # Calculate variance explained
      var_explained <- (pca$sdev^2 / sum(pca$sdev^2)) * 100
      
      # Add phenotype counts
      sig_counts <- clust_data$raw_data[, .N, by = gene_symbol]
      plot_data$sig_count <- sig_counts$N[match(plot_data$gene, sig_counts$gene_symbol)]
      
      # Perform k-means clustering on PCA coordinates
      # Number of clusters based on data size
      n_clusters <- min(max(2, floor(nrow(plot_data) / 3)), 8)
      set.seed(123) # for reproducibility
      km <- kmeans(plot_data[, c("PC1", "PC2")], centers = n_clusters)
      plot_data$cluster <- as.factor(km$cluster)
      
      # Create plot with cluster colors
      p <- ggplot(plot_data, aes(x = PC1, y = PC2, 
                                size = sig_count,
                                color = cluster,
                                text = paste0(
                                  "Gene: ", gene, "\n",
                                  "Significant phenotypes: ", sig_count, "\n",
                                  "Cluster: ", cluster
                                ))) +
        geom_point(alpha = 0.8) +
        scale_size_continuous(range = c(2, 6)) +
        scale_color_brewer(palette = "Set1") +  # Use a colorblind-friendly palette
        theme_minimal() +
        labs(x = sprintf("PC1 (%.1f%%)", var_explained[1]),
             y = sprintf("PC2 (%.1f%%)", var_explained[2]),
             size = "Significant\nPhenotypes",
             color = "Gene\nCluster") +
        theme(legend.position = "right")
      
      ggplotly(p, tooltip = "text")
    }
  })
  
  # Phenotype Distribution Plot
  output$phenotype_dist <- renderPlot({
    clust_data <- clustering_data()
    
    if (is.null(clust_data)) {
      plot.new()
      text(0.5, 0.5, "No significant phenotypes found for the selected criteria", cex = 1.2)
      return()
    }
    
    # Count phenotypes per gene
    counts <- clust_data$raw_data[, .N, by = gene_symbol]
    
    # Create title
    title <- if (input$clustering_category == "All") {
      "Distribution of Significant Phenotypes per Gene - All Categories"
    } else {
      paste("Distribution of Significant Phenotypes per Gene -", input$clustering_category)
    }
    
    # Create plot
    ggplot(counts, aes(x = N)) +
      geom_histogram(binwidth = 1, fill = "#4575B4", color = "white") +
      theme_minimal() +
      labs(x = "Number of Significant Phenotypes",
           y = "Number of Genes",
           title = title)
  })
  
  # Reset clustering filters
  observeEvent(input$reset_clustering, {
    updateSelectInput(session, "clustering_category", selected = "All")
    updateSelectInput(session, "clustering_phenotypes", choices = NULL)
    updateSelectInput(session, "clustering_life_stage", selected = "All")
    updateSelectInput(session, "clustering_strain", selected = "All")
  })
  
  # Download handler
  output$download_clustering <- downloadHandler(
    filename = function() {
      paste0("clustering_results_", gsub(" ", "_", input$clustering_category), ".csv")
    },
    content = function(file) {
      clust_data <- clustering_data()
      results <- data.frame(
        Gene = clust_data$genes,
        Phenotypes = rowSums(clust_data$matrix != 0)
      )
      write.csv(results, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
