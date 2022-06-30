library(shiny)

# Define UI for application that draws a histogram
ui <- pageWithSidebar(
  headerPanel("Eye-tracking accuracy tool"),
  sidebarPanel(
    verbatimTextOutput("accuracy")
  ),
  mainPanel(
    imageOutput("preImage", brush = "plot_brush")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # Send a pre-rendered image, and don't delete the image after sending it
  output$preImage <- renderImage({
    filename <- normalizePath(file.path('./images/355.jpg'))
    list(src = filename, width = 640, height = 480)
  }, deleteFile = FALSE)
  
  output$accuracy <- renderText({
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
    acc_output <- xy_dist(input$plot_brush)
    
    paste("dist (px): ", as.character(round(acc_output$dist_px, 1)),
          "\nacc (º): ", as.character(round(acc_output$acc_deg, 1)))

  })
}

# Run the application 
shinyApp(ui = ui, server = server)
