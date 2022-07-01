library(shiny)
library(tidyverse)

ui <- pageWithSidebar(
  headerPanel("Eye-tracking accuracy tool"),
  sidebarPanel(
    fileInput("myFile", "Choose a file", accept = c('image/png', 'image/jpeg')),
    verbatimTextOutput("accuracy"),
    actionButton("Accept", "Accept Point"),
    headerPanel(""),
    tableOutput('table'),
    downloadButton("downloadData", "Download")
  ),
  mainPanel(
    imageOutput("preImage", brush = "plot_brush"),
  )
)

server <- function(input, output, session) {
  values <- reactiveValues(acc_table = tibble(image_id = "", distance_pixels = NA, error_degrees = NA),
                           img_list = "./images/355.jpg",
                           curr_file_name = "test_image")
  
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
    fov_x <- 101.55
    fov_y <- 73.6
    fov_res_x <- 640
    fov_res_y <- 480
    
    to_degreesx = fov_res_x/fov_x
    to_degreesy = fov_res_y/fov_y
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
    values$acc_table <- bind_rows(values$acc_table, 
                           tibble(image_id = values$curr_file_name, 
                                  distance_pixels = acc_output$dist_px, 
                                  error_degrees = acc_output$acc_deg)) %>% 
                          drop_na(error_degrees)
  })
  
  output$table <- renderTable(values$acc_table)
  
  output$accuracy <- renderText({
    acc_output <- xy_dist(input$plot_brush)
    paste("dist (px): ", as.character(round(acc_output$dist_px, 1)),
          "\nerror (º): ", as.character(round(acc_output$acc_deg, 1)))

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
