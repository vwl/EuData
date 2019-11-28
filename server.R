addUiSlider <- function(feature) {
  pallete_choices <- c("Wes Anderson - Zissou","Viridis","Heat","Reds","Blues","Purples","Greens") 
  label = df.metadata.id[feature,]$descriptionShort
  tagList(
    tags$div(id="features",
             checkboxInput(paste0(feature,"_cond"), label = label),
             conditionalPanel(
               condition = paste0("input.",feature,"_cond == true"),
               sliderInput(inputId = paste0(feature,"_control"), label=label,
                           min = min(df[[feature]],na.rm=T), max = max(df[[feature]],na.rm=T), 
                           value = c(min(df[[feature]],na.rm=T),max(df[[feature]],na.rm=T))),
               selectInput(inputId = paste0(feature,"_palette"), label="Colour Palette", choices = pallete_choices)
             )
    )
  )
}

addMapLayer <- function(mapLayer,feature_name,title,input_name,color) {
  
  number_colors=5
  if (color == "Wes Anderson - Zissou"){
    wes <- wes_palette("Zissou1", n = number_colors, type = c("discrete", "continuous")[2]) 
    pallete = wes[1:length(wes)]
  } else if (color == "Viridis") {
    pallete = viridis(n=number_colors)
  } else if (color == "Heat") {
    pallete = heat.colors(n=number_colors) 
  } else {
    pallete = color
  }
  title = df.metadata.id[feature_name,]$descriptionShort
  feature<-df[[feature_name]]
  qpal <- colorBin(pallete, df[[feature_name]], n = number_colors)
  mapLayer<-  mapLayer %>%
    addPolygons(data = df[df[[feature_name]] >= input_name[1] & df[[feature_name]] <= input_name[2], ],
                color = ~qpal(get(feature_name)), opacity =  0.1) %>%
    addLegend(pal=qpal, values = df[[feature_name]], title = title)
  
  return(mapLayer)
}

shinyServer(function(input, output, session) {
  output$metadata <- renderTable(
    df.metadata
  )
  
  output$table <- renderDataTable(
    #Lookup in metata to search for column name in dataset
    df.subset<-df.subset[df.metadata$descriptionShort %in% input$show_vars]
  )
  
  output$map = renderLeaflet({
    
    thisOutput <- leaflet() %>% 
      addTiles() %>%
      setView(lng=14.5260,lat=57.2551, zoom=2.5)
    
    for (feature in input$custom_features) {
      if (input[[paste0(feature,"_cond")]]) {
        thisOutput <- addMapLayer(thisOutput,feature,feature,input[[paste0(feature,"_control")]],input[[paste0(feature,"_palette")]])
      }
    }
    
    thisOutput
  })
  
  output$scatterplot <- renderPlot({
    
    thisOutput<- ggplot(df, aes_string(x = input$corVarX, y=input$corVarY)) +
      geom_smooth( method='lm', se = TRUE) +
      theme_minimal()
    label=df[[input$corLabel]]
    if (input$repelLabels) {
      thisOutput <- thisOutput +
        geom_label_repel(aes(label = label),
                         box.padding   = 0.35, 
                         point.padding = 0.5,
                         segment.color = 'grey50')
    } else {
      thisOutput <- thisOutput + geom_text(aes(label=label))
    }
    thisOutput
  })
  
  observeEvent(input$custom_features, {
    removeUI("#features > *")
    for (feature in input$custom_features) {
      insertUI("#features", "beforeEnd",addUiSlider(feature))
    }
  })
  
  observeEvent(input$clean, {
    for (feature in input$custom_features) {
      removeUI("#features > *")
    }
    updateSelectizeInput(session,inputId = "custom_features", selected = "")
  })
})