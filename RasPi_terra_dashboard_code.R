library(ggplot2)
library(dplyr)
library(lubridate)
library(shiny)
library(shinyWidgets)
library(stringr)

# Path to sensor readings data in .txt file

readings <- "D:/KMMA_documents/side_projects/RasPi_terra/read.data.txt"

# Names of the species in the terrarium relative to gpio pin reading (use your species names to replace the examples) ####
pin18 = "A. felinus"
pin20 = "U. phantasticus"
pin21 = "E. multicarinata"
pin24 = "E. poecilogyrus"

# Build shiny UI
ui <- tabsetPanel(type = "tabs",
              tabPanel("Temperature and Humidity",
                fluidPage(
                  fluidRow(plotOutput("humplot", width = "100%")),
                  fluidRow(plotOutput("tempplot", width = '100%')),
                  setBackgroundColor(color = "white"))),
              tabPanel("Mean humidity",
                fluidPage(
                  fluidRow(plotOutput("meanhumAfe")),
                  fluidRow(plotOutput("meanhumUph")),
                  fluidRow(plotOutput("meanhumEmu")),
                  fluidRow(plotOutput("meanhumEpo")),
                  setBackgroundColor(color = "white"))),
              tabPanel("Mean temperature",
                fluidPage(
                  fluidRow(plotOutput("meantemAfe")),
                  fluidRow(plotOutput("meantemUph")),
                  fluidRow(plotOutput("meantemEmu")),
                  fluidRow(plotOutput("meantemEpo")),
                  setBackgroundColor(color = "white")))
)

server <- function(input, output, session) {
  data <- reactiveFileReader(intervalMillis = 60000,
                             session = NULL,
                             filePath = readings,
                             readFunc = read.csv)
  pal <- c("azure2","gold","plum1","springgreen")
  Tthresh <- 45
  Hthresh <- 100
  
  #dataframe containing every datapoint
  df <- reactive({
    df1 <- data.frame(data())
    colnames(df1) <- c("hour","date","pin","temp","hum")
    time <- parse_date_time(paste(df1$date, df1$hour), orders="dmy HMS")
    df2 <- cbind(df1, time)
    lastday <- tail(df2$date, 1)
    df3 <- df2[which(df2$date %in% lastday),] # select only last day 
    df4 <- df3 %>% mutate(species =
                         case_when(pin == 18 ~ "A. felinus", 
                                   pin == 20 ~ "U. phantasticus",
                                   pin == 21 ~ "E. multicarinata",
                                   pin == 24 ~ "E. poecilogyrus")
    )
    df5 <- df4[!(df4$temp>Tthresh | df4$hum>Hthresh),]
    df5
    })
  
  #dataframe with mean day/night T and humidity per species
  df_means <- reactive({ 
    d1 <- data.frame(data())
    colnames(d1) <- c("hour","date","pin","temp","hum")
    time <- parse_date_time(paste(d1$date, d1$hour), orders="dmy HMS")
    d2 <- cbind(d1,time)
    lastweek <- unique(d1$date) %>% tail(7)
    d3 <- d2[which(d2$date %in% lastweek),]
    daynight <- NULL
    for (i in as.numeric(str_extract(d3$hour, "\\d{2}"))) {
      if (i >= 7 & i < 19) {x<-"day"}
      else {x<-"night"}
      daynight <- rbind(daynight, x)
    }
    d4 <- cbind(d3,daynight)
    d5 <- d4[!(d4$temp>Tthresh | d4$hum>Hthresh),]
    d6 <- d5 %>% mutate(species =
                            case_when(pin == 18 ~ "A. felinus", 
                                      pin == 20 ~ "U. phantasticus",
                                      pin == 21 ~ "E. multicarinata",
                                      pin == 24 ~ "E. poecilogyrus")
    )
    daynight_temps <- group_by(d6, date, species, daynight) %>% summarise(mean_temp = mean(temp, na.rm = T), mean_hum = mean(hum, na.rm = T))
    daynight_temps$date <- as.Date(daynight_temps$date, format='%d/%m/%y')
    daynight_temps
    })
  
  #plotting
  p1 <- reactive({ggplot(df(), aes(x=time, y=hum)) + geom_point(aes(colour = species)) + 
    labs(x=NULL, y="humidity %") + theme_minimal() + scale_fill_manual(values=pal) + 
    theme(
      axis.title.x = element_text(size = 16, face = "bold"),
      axis.title.y = element_text(size = 16, face = "bold"),
      axis.text.x = element_text(size = 16),
      axis.text.y = element_text(size = 16))})
  p2 <- reactive({ggplot(df(), aes(x=time, y=temp)) + geom_point(aes(colour = species)) + 
    labs(x="\ntime", y="Temperature °C\n") + theme_minimal() + scale_fill_manual(values=pal) + 
    theme(
      axis.title.x = element_text(size = 16, face = "bold"),
      axis.title.y = element_text(size = 16, face = "bold"),
      axis.text.x = element_text(size = 16),
      axis.text.y = element_text(size = 16))})
  
  output$humplot <- renderPlot(p1(), res = 96)
  output$tempplot <- renderPlot(p2(), res = 96)
  
  #mean humidity
  m1 <- reactive({ggplot(subset(df_means(), species=="A. felinus"), aes(date, mean_hum)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nA. felinus\n", x="") 
    })
  m2 <- reactive({ggplot(subset(df_means(), species=="U. phantasticus"), aes(date, mean_hum)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nU. phantasticus\n", x="")
    })
  m3 <- reactive({ggplot(subset(df_means(), species=="E. multicarinata"), aes(date, mean_hum)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nE. multicarinata\n", x="")
    })
  m4 <- reactive({ggplot(subset(df_means(), species=="E. poecilogyrus"), aes(date, mean_hum)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold") + labs(y="\nE.poecilogyrus\n", x="")
                                        )})
  
  output$meanhumAfe <- renderPlot(m1(), res = 96)
  output$meanhumUph <- renderPlot(m2(), res = 96)
  output$meanhumEmu <- renderPlot(m3(), res = 96)
  output$meanhumEpo <- renderPlot(m4(), res = 96)
  
  #mean temperature
  t1 <- reactive({ggplot(subset(df_means(), species=="A. felinus"), aes(date, mean_temp)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nA. felinus\n", x="") 
    })
  t2 <- reactive({ggplot(subset(df_means(), species=="U. phantasticus"), aes(date, mean_temp)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nU. phantasticus\n", x="")
    })
  t3 <- reactive({ggplot(subset(df_means(), species=="E. multicarinata"), aes(date, mean_temp)) + 
    geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
    theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nE. multicarinata\n", x="")
    })
  t4 <- reactive({ggplot(subset(df_means(), species=="E. poecilogyrus"), aes(date, mean_temp)) + 
      geom_point(aes(colour = daynight)) + geom_smooth(aes(colour = daynight), se = FALSE) + 
      theme_minimal() + scale_fill_manual(values=c("azure2","gold")) + labs(y="\nE. poecilogyrus\n", x="")
  })
  
  output$meantemAfe <- renderPlot(t1(), res = 96)
  output$meantemUph <- renderPlot(t2(), res = 96)
  output$meantemEmu <- renderPlot(t3(), res = 96)
  output$meantemEpo <- renderPlot(t4(), res = 96)
  
}

shinyApp(ui, server)
                                                                                

