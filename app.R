library(shiny)
library(tidyverse)
library(reactable)

ui <- fluidPage(
  headerPanel("Eye-Tracking Accuracy Calculator"),
  sidebarPanel(
    numericInput('fovx', 'Horizontal field of view (º)', 54.4, min = 1, max = 180, width = '60%'),
    numericInput('fovy', 'Vertical field of view (º)', 42.2, min = 1, max = 180, width = '60%'),
    fileInput("myFile", "Choose image files", multiple = TRUE, accept = c('image/png', 'image/jpeg')),
    tags$h6("To measure accuracy, click and drag between point of gaze and validation target. The accuracy of the current selection will show in the box below. Click the 'save to table' button to add it to your list to export."),
    headerPanel(""),
    tags$h4("Current Validation Point Accuracy:"),
    verbatimTextOutput("accuracy"),
    actionButton("Accept", "Save Validation Point to Table ↓"),
    headerPanel(""),
    reactableOutput('table', inline = TRUE, width = "100%"),
    br(),
    br(),
    downloadButton("downloadData", "Download", class = "btn-success"), 
    actionButton("reset", "Reset Everything", class = "btn-danger")
  ),
  mainPanel(
    imageOutput("preImage", brush = "plot_brush", width = "640px", height = "520px"),
  ),
  fluidRow(
    h5("Author: John Franchak"),
    a("Github Page and Instructions", href = "https://github.com/JohnFranchak/et_accuracy"),
  )
)

server <- function(input, output, session) {
  initialize_acc_table <- function(inFile){
    if (is.null(inFile)) {
      t <- tibble(image_id = c("./images/356.jpg","./images/357.jpg","./images/358.jpg"), 
                    img_name = c("test_image1", "test_image2", "test_image3"),
                    distance_pixels = NA, error_degrees = NA)
    } else{
      tibble(image_id = inFile$datapath, 
             img_name = inFile$name,
             distance_pixels = NA, error_degrees = NA)
    }
  }
  
  xy_dist <- function(e) {
    if(is.null(e)) return(list(dist_px = NA, acc_deg = NA))
    dist_px <- sqrt((e$xmin-e$xmax)^2 + (e$ymin-e$ymax)^2)
    fov_res_x <- 640
    fov_res_y <- 480
    to_degreesx = fov_res_x/values$fov_x
    to_degreesy = fov_res_y/values$fov_y
    dist_x_deg <- (e$xmax-e$xmin) / to_degreesx
    dist_y_deg <- (e$ymax-e$ymin) / to_degreesy
    acc_deg <- sqrt(dist_x_deg^2 + dist_y_deg^2)
    list(dist_px = dist_px, acc_deg = acc_deg)
  }
  
  values <- reactiveValues(acc_table = initialize_acc_table(NULL),
                           img_current = 1,
                           fov_x = 54.4,
                           fov_y = 42.2)
  
  selected <- reactive(getReactableState("table", "selected"))
  
  observeEvent(input$fovx, {values$fov_x = input$fovx})
  
  observeEvent(input$fovy, {values$fov_y = input$fovy})
  
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile))
      return()
    values$acc_table <- initialize_acc_table(inFile)
    values$img_current = 1
  })
  
  output$preImage <- renderImage({
    filename <- normalizePath(file.path(values$acc_table$image_id[values$img_current]))
    list(src = filename, width = 640, height = 480)
  }, deleteFile = FALSE)
  
  observe({
    values$img_current <- ifelse(length(selected()) < 1, values$img_current, selected())
  })
  
  observeEvent(input$Accept, {
    acc_output <- xy_dist(input$plot_brush)
    values$acc_table[values$img_current, "distance_pixels"] <- acc_output$dist_px
    values$acc_table[values$img_current, "error_degrees"] <- acc_output$acc_deg
    updateReactable("table", data = values$acc_table)
  })
  
  output$table <- renderReactable({
    reactable(values$acc_table, selection = "single", onClick = "select",
              bordered = TRUE, highlight = TRUE, wrap = FALSE, compact = TRUE,
              columns = list(
                img_name = colDef(name = "Image"),
                image_id = colDef(show = FALSE),
                distance_pixels = colDef(name = "Raw Distance", format = colFormat(suffix = " pixels", digits = 2)),
                error_degrees = colDef(name = "Error", format = colFormat(suffix = "º", digits = 2))))
  })
  
  observeEvent(input$reset, {
    values$acc_table = initialize_acc_table(NULL)
    values$img_current = 1
    values$fov_x = 54.4
    values$fov_y = 42.2
    updateReactable("table", data = values$acc_table)
  })
  
  output$accuracy <- renderText({
    acc_output <- xy_dist(input$plot_brush)
    paste("Raw Distance (pixels): ", as.character(round(acc_output$dist_px, 1)),
          "\nOffset Error (º): ", as.character(round(acc_output$acc_deg, 1)))

  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("et_calibration_output.csv", sep = "")
    },
    content = function(file) {
      write.csv(values$acc_table, file, row.names = TRUE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
