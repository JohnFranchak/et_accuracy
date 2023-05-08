library(shiny)
library(tidyverse)
library(reactable)
library(readbitmap)

ui <- fluidPage(
  headerPanel("Eye-Tracking Accuracy Calculator"),
  sidebarPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Instructions",
                         h5("Author: John Franchak"),
                         a("Github Page and Full Instructions", href = "https://github.com/JohnFranchak/et_accuracy"),
                         tags$h5("Project Setup: Go to the setup tab to set the field of view of your eye tracker's scene camera (or the visual angle subtended by the remote eye tracker image). Next, use the file browser to upload a set of images to measure accuracy. Every time you upload images it will clear the work you did previously, so be sure to download your output before loading a new batch of images. Currently, image sets > 25 images are not recommended."),
                         tags$h5("Measure Accuracy: Click on a row in the table to select an image. To measure accuracy, click and drag between point of gaze and validation target. The accuracy of the current selection will show in the box below. Click the 'save to table' button to add it to your list to export. Use the download button to get a .csv of all the data you recorded.")
                ),
                tabPanel("Setup",  
                         br(),
                         numericInput('fovx', 'Horizontal field of view (º)', 54.4, min = 1, max = 180, width = '60%'),
                         numericInput('fovy', 'Vertical field of view (º)', 42.2, min = 1, max = 180, width = '60%'),
                         fileInput("myFile", "Choose image files", multiple = TRUE, accept = c('image/png', 'image/jpeg')),
                         ),
                tabPanel("Measure Accuracy",
                         br(),
                         tags$h4("Current Validation Point Accuracy:"),
                         verbatimTextOutput("accuracy"),
                         actionButton("Accept", "Save Validation Point to Table ↓"),
                         headerPanel(""),
                         reactableOutput('table', inline = TRUE, width = "100%"),
                         br(),
                         br(),
                         downloadButton("downloadData", "Download", class = "btn-success"), 
                         actionButton("reset", "Reset Everything", class = "btn-danger")
                         )
    )),
  mainPanel(
    imageOutput("preImage", brush = "plot_brush", width = "1280px", height = "720px"),
    actionButton("previous_img", "Previous Image"),
    actionButton("save_advance", "Save Validation and Advance"),
    actionButton("next_img", "Next Image"),
  ),
)

server <- function(input, output, session) {
  initialize_acc_table <- function(inFile){
    if (is.null(inFile)) {
      t <- tibble(image_id = c("./images/356.jpg","./images/357.jpg","./images/358.jpg"), 
                    img_name = c("test_image1", "test_image2", "test_image3"), pixx = NA, pixy = NA, degx = NA, degy = NA,
                  error_degrees = NA, distance_pixels = NA,)
    } else{
      tibble(image_id = inFile$datapath, 
             img_name = inFile$name, pixx = NA, pixy = NA, degx = NA, degy = NA,
             error_degrees = NA, distance_pixels = NA)
    }
  }
  
  xy_dist <- function(e) {
    if(is.null(e)) return(list(dist_px = NA, acc_deg = NA))
    dist_px <- sqrt((e$xmin-e$xmax)^2 + (e$ymin-e$ymax)^2)
    to_degreesx = values$fov_res_x/values$fov_x
    to_degreesy = values$fov_res_y/values$fov_y
    dist_x_deg <- (e$xmax-e$xmin) / to_degreesx
    dist_y_deg <- (e$ymax-e$ymin) / to_degreesy
    acc_deg <- sqrt(dist_x_deg^2 + dist_y_deg^2)
    list(dist_px = dist_px, acc_deg = acc_deg)
  }
  
  values <- reactiveValues(acc_table = initialize_acc_table(NULL),
                           img_current = 1,
                           fov_x = 54.4,
                           fov_y = 42.2,
                           fov_res_x = 640,
                           fov_res_y = 480)
  
  selected <- reactive(getReactableState("table", "selected"))
  
  observeEvent(input$fovx, {values$fov_x = input$fovx})
  observeEvent(input$fovy, {values$fov_y = input$fovy})
  
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile))
      return()
    values$acc_table <- initialize_acc_table(inFile)
    values$img_current = 1
    updateReactable("table", selected = values$img_current)
  })
  
  output$preImage <- renderImage({
    filename <- normalizePath(file.path(values$acc_table$image_id[values$img_current]))
    bm <- read.bitmap(filename)
    dims <- dim(bm)
    values$fov_res_y <- dims[1]
    values$fov_res_x <- dims[2]
    list(src = filename, width = values$fov_res_x, height = values$fov_res_y)
  }, deleteFile = FALSE)
  
  observe({
    values$img_current <- ifelse(length(selected()) < 1, values$img_current, selected())
  })
  
  observeEvent(input$Accept, {
    acc_output <- xy_dist(input$plot_brush)
    values$acc_table[values$img_current, "distance_pixels"] <- acc_output$dist_px
    values$acc_table[values$img_current, "error_degrees"] <- acc_output$acc_deg
    values$acc_table[values$img_current, "pixx"] <- values$fov_res_x
    values$acc_table[values$img_current, "pixy"] <- values$fov_res_y
    values$acc_table[values$img_current, "degx"] <- values$fov_x
    values$acc_table[values$img_current, "degy"] <- values$fov_y
    updateReactable("table", data = values$acc_table)
    updateReactable("table", selected = values$img_current)
  })
  
  output$table <- renderReactable({
    reactable(values$acc_table, selection = "single", onClick = "select",
              bordered = TRUE, highlight = TRUE, wrap = FALSE, compact = TRUE,
              showPageSizeOptions = TRUE,
              columns = list(
                img_name = colDef(name = "Image"),
                image_id = colDef(show = FALSE),
                degx = colDef(show = FALSE), degy = colDef(show = FALSE), pixx = colDef(show = FALSE), pixy = colDef(show = FALSE),
                error_degrees = colDef(name = "Error", format = colFormat(suffix = "º", digits = 2)),
                distance_pixels = colDef(name = "Raw Distance", format = colFormat(suffix = " pixels", digits = 2))))
  })
  
  observeEvent(input$reset, {
    values$acc_table = initialize_acc_table(NULL)
    values$img_current = 1
    # values$fov_x = 54.4
    # values$fov_y = 42.2
    updateReactable("table", data = values$acc_table)
    updateReactable("table", selected = values$img_current)
  })
  
  observeEvent(input$previous_img, {
    values$img_current <- ifelse(values$img_current <= 1, 1, values$img_current - 1)
    updateReactable("table", selected = values$img_current)
  })
  
  observeEvent(input$save_advance, {
    acc_output <- xy_dist(input$plot_brush)
    values$acc_table[values$img_current, "distance_pixels"] <- acc_output$dist_px
    values$acc_table[values$img_current, "error_degrees"] <- acc_output$acc_deg
    values$acc_table[values$img_current, "pixx"] <- values$fov_res_x
    values$acc_table[values$img_current, "pixy"] <- values$fov_res_y
    values$acc_table[values$img_current, "degx"] <- values$fov_x
    values$acc_table[values$img_current, "degy"] <- values$fov_y
    values$acc_table[values$img_current, "error_degrees"] <- acc_output$acc_deg
    updateReactable("table", data = values$acc_table)
    values$img_current <- ifelse(values$img_current >= nrow(values$acc_table), nrow(values$acc_table), values$img_current + 1)
    updateReactable("table", selected = values$img_current)
  })
  
  observeEvent(input$next_img, {
    values$img_current <- ifelse(values$img_current >= nrow(values$acc_table), nrow(values$acc_table), values$img_current + 1)
    updateReactable("table", selected = values$img_current)
  })
  
  output$accuracy <- renderText({
    acc_output <- xy_dist(input$plot_brush)
    paste("File: ", values$acc_table$img_name[values$img_current],
          "\nRaw Distance (pixels): ", as.character(round(acc_output$dist_px, 1)),
          "\nOffset Error (º): ", as.character(round(acc_output$acc_deg, 1)))

  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("et_calibration_output.csv", sep = "")
    },
    content = function(file) {
      acc_table_print <- values$acc_table %>% 
        rename(image_pixels_x = pixx, image_pixels_y = pixy, fov_degrees_x = degx, fov_degrees_y = degy)
      write.csv(acc_table_print, file, row.names = TRUE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
