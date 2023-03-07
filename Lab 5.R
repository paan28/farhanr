library(shiny)
library(datasets)

ui <- fluidPage(
  h2(textOutput("currentTime")),
  titlePanel("Uploading Files"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      tags$hr(),
      checkboxInput("header", "Header", TRUE),
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = ","),
      radioButtons("quote", "Quote",
                   choices = c(None = "", "Double Quote" = '"', "Single Quote" = "'"),
                   selected = '"'),
      tags$hr(),
      radioButtons("disp", "Display",
                   choices = c(Head = "head", All = "all"),
                   selected = "head"),
      downloadButton("downloadData", "Download")
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Table", tableOutput("table")),
                  tabPanel("Summary", verbatimTextOutput("summary"))
      )
    )
  )
)

server <- function(input, output, session) {
  #Upload
  output$table <- renderTable({
    req(input$file1)
    mydata <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote)
    summaryData <- mydata
    
    if(input$disp == "head") {
      return(head(mydata))
    }
    else {
      return(mydata)
    }
  })
  #Summary
  output$summary <- renderPrint({
    req(input$file1)
    mydata <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
    summaryData <- mydata
    
    if(input$disp == "head") {
      return(head(mydata))
    }
    else {
      return(mydata)
    }
    summaryData <- output$table
    summary(summaryData)
  })
  #Download
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(output$table(), file, row.names = FALSE)
  })
  #Timer
  output$currentTime <- renderText({
    invalidateLater(1000, session)
    paste("The current time is", Sys.time())
  })
}
shinyApp(ui = ui, server = server)
shiny::runApp()
