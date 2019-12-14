#That's the function library
#It loads required packets and stores project especific functions

if(!require(shiny)) install.packages('shiny')
if(!require(sf)) install.packages('sf')
if(!require(raster)) install.packages('raster')
if(!require(spData)) install.packages('spData') #library(spDataLarge)
if(!require(tmap)) install.packages('tmap')  # for static and interactive maps 
if(!require(leaflet)) install.packages('leaflet') # for interactive maps
if(!require(mapview)) install.packages('mapview')  # for interactive maps
if(!require(ggplot2)) install.packages('ggplot2')  # tidyverse data visualization package
if(!require(ggrepel)) install.packages('ggrepel')  # tidyverse data visualization package
if(!require(wesanderson)) install.packages('wesanderson')
if(!require(viridis)) install.packages('viridis')
if(!require(RColorBrewer)) install.packages('RColorBrewer')


loadDataset <- function() {
  
  #Fahrenheith do celcius degrees
  FtoC <- function(c_degrees) {
    #return(c_degrees)
    return ((c_degrees-32) * 5/9)
  }
  
  #Normalize data
  normalize <- function(x, scale=1) {
    return ((x - min(x)) / (max(x) - min(x)) * scale)
  }
  
  dataset.folder = paste0('dataset//files//')
  dataset.files = list.files(path=dataset.folder, pattern="*.csv")
  
  #Dynamically import multiple csv files
  for (i in 1:length(dataset.files)) {
    csv_file_name = dataset.files[i]
    variable_name=paste0("dataset.",strsplit(csv_file_name, ".csv")[[1]])
    csv_file_location=paste0(dataset.folder,csv_file_name)
    
    assign(variable_name,read.csv(csv_file_location, stringsAsFactors = F))
  }
  
  #Clean up variables
  remove(i,dataset.folder,dataset.files,csv_file_location,csv_file_name,variable_name)
  
  #Merge the datasets imported into a single one
  environment_variables=ls()
  dataset_variables=c()
  for (i in 1:length(environment_variables)) {
    variable_name = environment_variables[i]
    
    if (grepl("dataset.",variable_name)) {
      dataset_variables[[i]] <- get(variable_name)
    }
  }
  df<-Reduce(function(x, y) merge(x, y, all=TRUE), as.list(dataset_variables))
  
  #Drop columns with NA
  df<-df[ , !(grepl("X",names(df)))] 
  
  #Fahrenheit to Celcius
  df$avg_high_temp<-FtoC(df$avg_high_temp)
  df$avg_temp<-FtoC(df$avg_temp)
  df$avg_low_temp<-FtoC(df$avg_low_temp)
  
  #Normalization and scale to 100
  df$total_pop<-normalize(df$total_pop,100)
  df$median_income<-normalize(df$median_income,100)
  df$gdp<-normalize(df$gdp,100)
  
  #Escale to 100
  df$police_trust_rating<-df$police_trust_rating*10
  df$legal_trust_rating<-df$legal_trust_rating*10
  #df$unemp_rate<-df$unemp_rate*10
  df$political_trust_rating<-df$political_trust_rating*10
  
  #Merge with World map dataset
  df$country[df$country == "Czechia"] <- as.character("Czech Republic") #Fixes name difference
  df<-df[!df$country == "Malta",] #Removes Malta since no geometry is provided
  world2 = base::merge(x = world, y = df, by.y = "country", by.x="name_long", all.x = TRUE)
  
  #Metadata dataset to allow showing variable description rather than a unfriendly variable name   
  metadata.id <- read.csv("dataset//metadata.csv",row.names = "id")
  metadata <- read.csv("dataset//metadata.csv",stringsAsFactors = TRUE)
  
  quote_type_names <- metadata$descriptionShort
  quote_type_feature <- metadata$feature
  names(quote_type_feature) <- quote_type_names
  
  metadata.numeric<-metadata[metadata$type == 'Numeric',]
  quote_type_names <- metadata.numeric$descriptionShort
  quote_type_feature_numeric <- metadata.numeric$feature
  names(quote_type_feature_numeric) <- quote_type_names
  
  
  assign("df", world2 , envir = .GlobalEnv)
  assign("df.eu", df , envir = .GlobalEnv)
  assign("df.metadata.id", metadata.id , envir = .GlobalEnv)
  assign("df.metadata", metadata , envir = .GlobalEnv)
  assign("df.features.all", quote_type_feature , envir = .GlobalEnv)
  assign("df.features.numeric", quote_type_feature_numeric , envir = .GlobalEnv)
  
}

loadDataset()

df.subset <- df[!is.na(df$gdp),]
