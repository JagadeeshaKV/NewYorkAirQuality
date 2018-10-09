#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {

   
  output$distPlot <- renderPlot({
    
    sMonth <- input$month
    sWeeks <- seq(input$week[1],input$week[2],1)
    options <- input$checkGroup
    
    if(length(input$checkGroup)==0){
      return(NULL);
    }
    
    dataset <- airquality[airquality$Month==sMonth,]
    dataset$Week <- ifelse((dataset$Day%%7)==0,(dataset$Day%/%7),(dataset$Day%/%7)+1) 
    dataset$DayOfWeek <- ifelse((dataset$Day%%7)==0,7,(dataset$Day%%7)) 
    dataset <- dataset[dataset$Week %in% sWeeks,]
    
    avgTemp <- reactive({
      paste0("<span class=\"tileText\">",
             format(round(mean(dataset$Temp, na.rm=TRUE), 2), nsmall = 2),"</span>")
    })
    
    avgWindSpeed <- reactive({
      paste0("<span class=\"tileText\">",
             format(round(mean(dataset$Wind, na.rm=TRUE), 2), nsmall = 2),"</span>")
    })
    
    avgSolarR <- reactive({
      paste0("<span class=\"tileText\">",
             format(round(mean(dataset$Solar.R, na.rm=TRUE), 2), nsmall = 2),"</span>")
    })
    
    avgOzone <- reactive({
      paste0("<span class=\"tileText\">",
             format(round(mean(dataset$Ozone, na.rm=TRUE), 2), nsmall = 2),"</span>")
    })
    
    output$tempAvg <- renderText({ 
      paste("Average temperature (degrees F)", avgTemp(), sep="<br/>")
    })
    
    output$windAvg <- renderText({ 
      paste("Average Wind Speed (mph)", avgWindSpeed(), sep="<br/>")
    })
    
    output$solarAvg <- renderText({ 
      paste("Average Solar Radiation (lang)", avgSolarR(), sep="<br/>")
    })
    
    output$ozoneAvg <- renderText({ 
      paste("Average Ozone (ppb)", avgOzone(), sep="<br/>")
    })

    p1 <- ggplot(dataset, aes(x=Day, y=Ozone)) +
      geom_bar(stat="identity", fill="darkgreen")+
      ggtitle("Ozone")
    
    # Second plot
    p2 <- ggplot(dataset, aes(x=Day, y=Solar.R)) +
      geom_bar(stat="identity", fill="purple")+
      ggtitle("Solar Radiation")
    
    # Third plot
    p3 <- ggplot(data=dataset, aes(x=DayOfWeek, y=Wind, 
              group = factor(Week), colour = factor(Week))) +
      geom_line() +
      geom_point( size=3, shape=21, fill="white")+
      ggtitle("Weekly Wind Speed Comparison ")+ 
      labs(colour="Week")
    
    spline_int <- as.data.frame(spline(dataset$Day, dataset$Temp))
    # Fourth plot
    p4 <- ggplot(dataset) + 
      geom_point(aes(x = Day, y = Temp, colour = Ozone), size = 3) +
      scale_color_gradient(low="blue", high="red")+
      geom_line(data = spline_int, aes(x = x, y = y))+
      ggtitle("Ozone - Temperature")
    
    lst <- list()
    if(1 %in% options){
      lst1 <- list(p1)
      lst <- c(lst,lst1)
    }
    if(2 %in% options){
      lst2 <- list(p2)
      lst <- c(lst,lst2)
    }
    if("3" %in% options){
      lst3<- list(p3)
      lst <- c(lst,lst3)
    }
    if("4" %in% options){
      lst4 <- list(p4)
      lst <- c(lst,lst4)
    }
    
    col <- length(options)
    
    if(length(options)==4 || length(options)==0 ){
      col <- 2
    }

    multiplot(lst, cols=col)
    
    hide(id = "loading-content", anim = TRUE, animType = "fade")    
    
  })
  
})

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(lst, plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(lst, plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
