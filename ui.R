source("lib.R")

page.intro <- fluidPage(
  h1("European Political Data"),
  HTML("<article>
  Political information can be used for many purposes, 
  for example, people looking for exchange programs or families 
  seeking new opportunities in a European country.

  The data used is gathered by <a href='https://ec.europa.eu/eurostat/statistics-explained/index.php/Self-perceived_health_statistics#Self-perceived_health'>EuroStat</a> 
  and synthetized in <a href='https://www.kaggle.com/roshansharma/europe-datasets'>Kaggle</a>.
       </article>"),
 
  h3("Objectives"),
  HTML("<article>
       This application aims to explore R interactive graphics and plots, the main goal is to achieve a interactive map that allows exploration of the dataset.
  </article>"),
  
  h3("How to use this application"),
  HTML("<article>
  Navigate using the tabs on the top, the correlation analyser allows the user to pick two dataset features and analyse its correlation
  the 'Map' tab allows to analyse the dataset data ploted in interactive map
  the 'Table' tab will allow to interacively navigate the raw data.
       </article>"),
  
  h3("The dataset"),
  HTML("<article>
       Found in Kaggle, this dataset is a extract of many datasets provided by Eurostat, the statistical office of Europe. 
       The year of the data is provided in the each file name, the many files contain one or more features by country.
       </article>"),
  tableOutput("metadata")
)


page.corr <- fluidPage(
  sidebarPanel(
    checkboxInput("repelLabels", "Repels Label", value = FALSE),
    selectizeInput("corLabel","Label", selected="iso_a2", choices = df.features.all, multiple= FALSE),
    selectizeInput("corVarX","Variable X", selected="prct_leisure_satis_high", choices = df.features.all, multiple= FALSE),
    selectizeInput("corVarY","Variable Y", selected="gdpPercap", choices = df.features.all, multiple= FALSE)
  ),
  mainPanel(
    plotOutput(outputId = "scatterplot")
  )
)

page.map <- sidebarLayout(
  sidebarPanel(
    actionButton(inputId="clean","Clean"),
    selectizeInput("custom_features","Columns:", choices = df.features.numeric, selected = c("avg_hrs_worked"), multiple=TRUE),
    tags$div(id="features")
  ),
  mainPanel(
    leafletOutput(outputId = "map")
  )
)

page.table <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectizeInput("show_vars","Columns:",choices = (df.metadata$descriptionShort), selected = c("name_long","gdp"), multiple=TRUE),
    ),
    mainPanel(
      dataTableOutput('table')
    )
  ) 
)

page.work <- fluidPage(
  h3("Know issues, limitations, improvements"),
  h5(tags$b("Open")),
  tags$ul(
    tags$li("In loadDataset function Malta is being removed from the dataset because it doesn't have a geom shape"),
    tags$li("In 'Correlation Analyser' Add animation"),
    tags$li("In any map, the area covered is not smooth with the map below"),
    tags$li("In 'Table' section the geometry coulmn coudn't be removed")
  ),
  h5(tags$b("Done")),
  tags$ul(
    tags$li("Create a metadata dataframe to allow more dinamism and code abstractionism to manipulate user interface, That would allow to avoid using hardcoded variable titles for example"),
    tags$li("In 'Correlation Analyser' Different options for country label"),
    tags$li("In 'Correlation Analyser' limit to select only numeric values. But it can also show geoprahical region data from dataset "),
    tags$li("In any, display feature description rather than feature id"),
    tags$li("In any map, when the value is low color will be very light, which can be difficult to distinguish of countries with value of NA"),
    tags$li("In any map, limit to select a single feature"),
    tags$li("In any map, allow to features dynamicaly"),
  ),
  h3("Questions to be answered"),
  tags$ul(
    tags$li("Least developed countries, whats in common about then?")
  )
  
)

page.references <- fluidPage(
  h3("References"),
  h6("In search order"),
  tags$ul(
    tags$li(tags$a("Kaggle",href="https://www.kaggle.com/roshansharma/europe-datasets")),
    tags$li(tags$a("EuroStat",href="https://ec.europa.eu/eurostat/cache/metadata/en/ilc_pwb_esms.htm")),
    tags$li(tags$a("Making maps with R",href="https://geocompr.robinlovelace.net/adv-map.html")),
    tags$li(tags$a("Shiny App Cheat Sheet",href="https://shiny.rstudio.com/images/shiny-cheatsheet.pdf")),
    tags$li(tags$a("Shiny App Reference",href="https://shiny.rstudio.com/reference/shiny/latest/")),
    tags$li(tags$a("Shiny App Dynamic UI",href="https://shiny.rstudio.com/articles/dynamic-ui.html")),
    tags$li(tags$a("Leaflet for R",href="https://rstudio.github.io/leaflet/colors.html")),
    tags$li(tags$a("Color palletes for R",href="https://www.datanovia.com/en/blog/top-r-color-palettes-to-know-for-great-data-visualization/")),
    tags$li(tags$a("Select only numeric columns from a dataframe",href="https://stackoverflow.com/questions/5863097/selecting-only-numeric-columns-from-a-data-frame")),
    tags$li(tags$a("Selectize input labels",href="https://stackoverflow.com/questions/44929584/access-r-shiny-selectizeinput-labels"))
    
  )
) 
  
ui <- fluidPage(
  tabsetPanel(
    tabPanel("Intro", page.intro),
    tabPanel("Correlation analyser", page.corr),
    tabPanel("Map", page.map),
    tabPanel("Table", page.table),
    tabPanel("Work in progress", page.work),
    tabPanel("References", page.references)
  )
)

shinyUI(ui)