library(shiny)
library(tidyverse)
library(reactable)

acc_table  <-  tibble(image_id = "", distance_pixels = NA, error_degrees = NA)

ui <- fluidPage(
  headerPanel("Eye-Tracking Accuracy Calculator"),
  sidebarPanel(
    numericInput('fovx', 'Horizontal field of view (º)', 54.4, min = 1, max = 180, width = '60%'),
    numericInput('fovy', 'Vertical field of view (º)', 42.2, min = 1, max = 180, width = '60%'),
    fileInput("myFile", "Choose image file", multiple = TRUE, accept = c('image/png', 'image/jpeg')),
    tags$h6("To measure accuracy, click and drag between point of gaze and validation target. The accuracy of the current selection will show in the box below. Click the 'save to table' button to add it to your list to export."),
    headerPanel(""),
    tags$h4("Current Validation Point Accuracy:"),
    verbatimTextOutput("accuracy"),
    actionButton("Accept", "Save Validation Point to Table ↓"),
    headerPanel(""),
    downloadButton("downloadData", "Download", class = "btn-success"), 
    actionButton("reset", "Reset Everything", class = "btn-danger")
  ),
  mainPanel(
    imageOutput("preImage", brush = "plot_brush", width = "640px", height = "520px"),
    reactableOutput('table'),
  ),
  fluidRow(
    h5("Author: John Franchak"),
    a("Github Page and Instructions", href = "https://github.com/JohnFranchak/et_accuracy"),
  )
)

server <- function(input, output, session) {
  values <- reactiveValues(
                           img_list = "./images/356.jpg",
                           curr_file_name = "test_image",
                           fov_x = 54.4,
                           fov_y = 42.2)
  
  observeEvent(input$fovx, {
    values$fov_x = input$fovx
  })
  
  observeEvent(input$fovy, {
    values$fov_y = input$fovy
  })
  
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile))
      return()
    values$img_list = inFile$datapath
    values$curr_file_name <- inFile$name
  })
  
  xy_dist <- function(e) {
    if(is.null(e)) return(list(dist_px = NA, acc_deg = NA))
    dist_px <- sqrt((e$xmin-e$xmax)^2 + (e$ymin-e$ymax)^2)
    # fov_x <- 101.55
    # fov_y <- 73.6
    fov_res_x <- 640
    fov_res_y <- 480
    
    to_degreesx = fov_res_x/values$fov_x
    to_degreesy = fov_res_y/values$fov_y
    dist_x_deg <- (e$xmax-e$xmin) / to_degreesx
    dist_y_deg <- (e$ymax-e$ymin) / to_degreesy
    
    acc_deg <- sqrt(dist_x_deg^2 + dist_y_deg^2)
    list(dist_px = dist_px, acc_deg = acc_deg)
  }
  
  output$preImage <- renderImage({
    filename <- normalizePath(file.path(values$img_list))
    list(src = filename, width = 640, height = 480)
  }, deleteFile = FALSE)
  
  observeEvent(input$Accept, {
    acc_output <- xy_dist(input$plot_brush)
    acc_table <- bind_rows(acc_table, 
                                  tibble(image_id = values$curr_file_name, 
                                         distance_pixels = acc_output$dist_px, 
                                         error_degrees = acc_output$acc_deg)) %>% 
      drop_na(error_degrees)
    updateReactable("table", data = acc_table)
  })
  
  output$table <- renderReactable({
    reactable(acc_table)
  })
  
  observeEvent(input$reset, {
    acc_table = tibble(image_id = "", distance_pixels = NA, error_degrees = NA)
    values$img_list = "./images/356.jpg"
    values$curr_file_name = "test_image"
    values$fov_x = 54.4
    values$fov_y = 42.2
    updateReactable("table", data = acc_table)
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
