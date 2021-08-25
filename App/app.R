# https://www.paulamoraga.com/book-geospatial/sec-shinyexample.html#conclusion

library(shiny)
library(rgdal)
library(sf)
library(glue)
library(leaflet)
library(dplyr)
library(purrr)
selectSfDefault = c("L1 Shapes","L1 Hex")

# ui object
ui <- fluidPage(
  titlePanel(p("Spatial app", style = "color:#3474A7")),
  sidebarLayout(
    sidebarPanel(
      fileInput(
        inputId = "selectFiledata",
        label = "Upload data. Choose csv file",
        accept = c(".csv")
      ),
      selectInput("selectSf", ("Select Geography or upload shapefile"), 
                  choices = selectSfDefault),
      # fileInput(
      #   inputId = "selectFilemap",
      #   label = NULL,
      #   multiple = TRUE,
      #   accept = c(".shp", ".dbf", ".sbn", ".sbx", ".shx", ".prj")
      # ),
      selectInput("selectPallete", ("Select Pallete"), 
                  choices = c("Blues","Reds","Greys")),
      uiOutput("variable")
    ),
    
    mainPanel(
      leafletOutput("map"),
      DT::dataTableOutput("table")
    )
  )
)

# server()
server <- function(input, output) {
  load("default_shp.rdata")
  data <- reactive({
    req(input$selectFiledata)
    read.csv(input$selectFiledata$datapath)
  })
  output$variable = renderUI({
    req(nrow(data())>0)
    data = data()
    dataChoices = data %>% select(contains("var_")) %>% names()
    selectInput("selectVars", ("Select Variable to Map"), 
                choices = c(dataChoices))
  })
  output$table = DT::renderDataTable({
    req(nrow(data())>0)
    DT::datatable(data())
  })
  sf  <- reactive({
    selectSfTmp = input$selectSf
    if (selectSfTmp=="L1 Shapes") {
      fileSfL1
    }  else if (selectSfTmp=="L1 Hex") {
      fileSfL1Hex
    }
  })
  
  output$map <- renderLeaflet({
    if (is.null(data()) | is.null(sf())) {return(NULL) }
    req(input$selectVars)
    
    ## Load Tmp Vars
    sf <- sf()
    data <- data()
    palleteTmp = input$selectPallete
    varsTmp = input$selectVars
    
    
    
    
    ## Create sf
    sfTmp = sf %>% 
      left_join(data %>% select(key,variableplot=varsTmp)) %>% 
      filter(!is.na(variableplot)) %>% 
      mutate(labels = glue("<strong>{name}, {country}</strong><br>{varsTmp}: {round(variableplot,2)}") %>% 
               map(~HTML(.x)))
    print("OKAY SF")
    ## Make Pallete
    pal <- colorNumeric(
      palette = palleteTmp,
      domain = sfTmp$variableplot)
    print("Pallete Okay")
    
    ## Map
    leaflet(sfTmp) %>%
      addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
      addPolygons(
        fillColor = ~pal(variableplot),
        label = ~labels,
        weight = 0,
        fillOpacity = 1
      )  %>%
      addLegend("bottomright", 
                pal = pal, 
                values = ~variableplot,
                title = varsTmp,
                opacity = 1
      )
    
  })
}

# shinyApp()
shinyApp(ui = ui, server = server)