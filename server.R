shinyServer(function(input, output) {
  
#-------------Panel1----------------
  output$plot_g <- renderHighchart({ 
    highchart() %>%  
      hc_title(text = "Today's New Bookings by Race") %>%  
      hc_yAxis(min=0.00, max=1.00)%>% 
      hc_xAxis(categories = racial.category) %>% 
      hc_add_series(name = "Jail", data = c(racial[1,1], racial[1,2], racial[1,3], racial[1,4]), type = "column") %>%  
      hc_add_series(name = "Champaign County", data = c(0.13, 0.73, 0.06, 0.08), type = "column")  
  }) 
  
  output$plot_kk <- renderHighchart({
    highchart() %>% 
      hc_title(text = "Today's Jail Population by Race") %>%
      hc_add_series_labels_values(Race.info$Race, Race.info$Count, name = "TodayColumn",
                                  colorByPoint = TRUE, type = "column") %>% 
      hc_add_series_labels_values(Race.info$Race, Race.info$Percent,
                                  #colors = substr(terrain.colors(4), 0 , 7), 
                                  type = "pie",
                                  name = "TodayBar", colorByPoint = TRUE, center = c('35%', '10%'),
                                  size = 100, dataLabels = list(enabled = FALSE)) %>% 
      hc_yAxis(title = list(text = "Total Population"),
               labels = list(format = "{value}")) %>% 
      hc_xAxis(categories = Race.info$Race) %>% 
      hc_legend(enabled = FALSE) %>% 
      hc_tooltip(pointFormat = "{point.y}")
  })    
  
  output$Date <- renderValueBox({
    valueBox(
      value = data.sorted$Date[1],
      subtitle = "Date",
      icon = icon("date"),color="blue"
    )
  })
  
  output$Total <- renderValueBox({
    valueBox(
      value = data.sorted$popTot[1],
      subtitle = "Total Jail Population Today",
      icon = icon("group"),color="purple"
    )
  })
  
  output$Newbooking <- renderValueBox({
    valueBox(
      value = data.sorted$bookings[1],
      subtitle = "New Bookings Today",
      icon = icon("sign-in"),color="purple"
    )
  })
  
  output$Newreleased <- renderValueBox({
    valueBox(
      value = data.sorted$releases[1],
      subtitle = "New Releases Today",
      icon = icon("sign-out"),color = "purple"
    )
  })

  #-------------Panel2--------------
  output$plot_m <- renderHighchart({
    race.data<-subset(race,race$BookDate>=input$startdate & race$BookDate<=input$enddate)
    highchart() %>% 
      hc_title(text = "Bookings by Race and Date") %>% 
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Afam, 
                                 name = "African-American") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$White, 
                                 name = "White") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Hisp, 
                                 name = "Hispanic") 
    #hc_add_theme(hc_theme_sandsignika())
  })
  
  #plot_d:Arrest Result by Race
  output$plot_d <- renderHighchart({
    bail2<-subset(bail,bail$BookDate>=input$startdate & bail$BookDate<=input$enddate)
    bail.data <- as.data.frame(table(bail2$result, as.character(bail2$racetype)))
    colnames(bail.data) <- c("Result", "Race", "Freq")
    
    hchart(bail.data, "column", x=Race, y=Freq, group=Result) %>%     
      hc_title(text = "Arrest Result by Race")
  })
  
  #---------Panel3---------------- 
  output$plot_b<- renderHighchart({
    highchart()%>%
      hc_chart(type="column") %>% 
      hc_xAxis(categories = c("<=5000","5000-10000","10000-25000",">25000"),tickmarkPlacement = 'on')%>%
      hc_title(text = "Bond Amount of Jail Population, broken down by Race")%>%
      hc_add_series(data=table.bond.t$`African-American`,name="African-American") %>%
      hc_add_series(data=table.bond.t$White,name="White") %>%
      hc_add_series(data=table.bond.t$Hispanic,name="Hispanic") %>%
      hc_add_series(data=table.bond.t$Other,name="Other") 
  }) 
  
  output$Date2 <- renderValueBox({
    valueBox(
      value = data.sorted$Date[1],
      subtitle = "Date",
      icon = icon("date"),color="blue"
    )
  })
  
  
  #plot_r:representation
  output$plot_r<-renderHighchart({
    
    #rep0<-subset(bkrep,bkrep$BookDate>=format(input$startdate2) & bkrep$BookDate<=format(input$startdate2) )
    bail2<-subset(bail,bail$BookDate>=input$startdate2 & bail$BookDate<=input$enddate2)
    bail.data <- as.data.frame(table(bail2$result, as.character(bail2$racetype)))
    colnames(bail.data) <- c("Result", "Race", "Freq")
    unbail<-subset(bail.data, select=c("Race","Freq"),bail.data$Result=="Jail")
    widthy <- data.frame(replicate(1,sample(0:1,4,rep=TRUE)))
    colnames(widthy) <- "UBPerct"
    for (i in 1:(length(widthy$UBPerct))) {
      #k[i] <- (paste0(daye[i], " to ", daye[i+1], "")) 
      widthy$UBPerct[i] <- round((unbail$Freq[i] / sum(unbail$Freq)*100) ,digit=2)  
    }
    unbail.data <- cbind(unbail, widthy)
    
    rep0<-as.data.frame(table((bail2$BookDate), as.character(bail2$racetype)))
    colnames(rep0) <- c("BookingDate","racetype","Freq")
    rep<-aggregate(rep0$Freq,list(rep0$racetype),sum)
    colnames(rep) <- c("Race","Freq")
    widthy2 <- data.frame(replicate(1,sample(0:1,4,rep=TRUE)))
    colnames(widthy2) <- "BKPerct"
    
    for (i in 1:(length(widthy2$BKPerct))) {
      #k[i] <- (paste0(daye[i], " to ", daye[i+1], "")) 
      widthy2$BKPerct[i] <- round((rep$Freq[i] / sum(rep$Freq)*100) ,digit=2)  
    }
    rep.data <- cbind(rep, widthy2)
    
    final<-merge(unbail.data, rep.data,by="Race")
    widthy3 <- data.frame(replicate(1,sample(0:1,4,rep=TRUE)))
    
    colnames(widthy3) <- "PopPerct"
    widthy3$PopPerct <- as.numeric(list("12.47","5.73","7.64","74.16"))
    
    final.data<- cbind(final, widthy3)
    #final.data<-as.matrix(subset(final.data, select = c("UBPerct","BKPerct","PopPerct")))
    
    highchart()%>%
      hc_chart(type="column") %>% 
      hc_xAxis(categories = unique(final.data$Race),tickmarkPlacement = 'on')%>%
      hc_title(text = "Racial distribution in Champaign County and correctional facilities")%>%
      hc_add_series(data=final.data$PopPerct, name="Percentage in Total Population") %>%
      hc_add_series(data=final.data$BKPerct,name="Percentage in Booking") %>%
      hc_add_series(data=final.data$UBPerct,name="Percentage in Unable to bail out") 
    
  })
  
  #-------------Panel4--------------------
  output$plot_t <- renderHighchart({
    highchart() %>% 
      hc_title(text = "Total Jail Population by Date") %>% 
      hc_add_series_times_values(as.Date(data.t$custDate, "%m/%d/%Y"), data.t$popTot, 
                                 name = "In Jail") 
    #hc_add_theme(hc_theme_sandsignika())
  })
  
  
  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print((tail(data, input$maxrows)),row.names=FALSE)
    options(orig)
    
  })
  
  #-------------Panel5--------------------
  output$JAD <- renderValueBox({
    valueBox(
      value = JAD.df$JAD2014[1],
      subtitle = "Total Juvenile Detention Population",
      icon = icon("group"),
      color = "light-blue"
    )
  })
  output$JAD1 <- renderValueBox({
    valueBox(
      value = JAD.df$JAD2013[1],
      subtitle = "Total Juvenile Detention Population",
      icon = icon("area-chart"),
      color = "light-blue"
    )
  })
  
  output$JP <- renderValueBox({
    valueBox(
      value = JR.df$JB2014[1],
      subtitle = "Total African America Juvenile Detention Population",
      icon = icon("group"),
      color = "light-blue"
    )
  })
  output$JP1 <- renderValueBox({
    valueBox(
      value = JR.df$JB2013[1],
      subtitle = "Total African America Juvenile Detention Population",
      icon = icon("group"),
      color = "light-blue"
    )
  })
  
  output$JTB <- renderValueBox({
    valueBox(
      value = JTP[1],
      subtitle = "Total African America Juvenile Population",
      icon = icon("list"),
      color = "light-blue"
    )
  })
  output$JTB1 <- renderValueBox({
    valueBox(
      value = JTP[2],
      subtitle = "Total African America Juvenile Population",
      icon = icon("list"),
      color = "light-blue"
    )
  })
  
  output$JOT<-renderHighchart({
    highchart() %>%   
      hc_title(text = "Juvenile Detention Population, broken up by Offense Type")%>%
      hc_add_series_labels_values(JOT.df$OT, JOT2014P, type = "pie", name="Percentage",
                                  colorByPoint = TRUE,dataLabels = list(enabled=TRUE)) 
  })
  output$JOT1<-renderHighchart({
    highchart() %>%   
      hc_title(text = "Juvenile Detention Population, broken up by Offense Type")%>%
      hc_add_series_labels_values(JOT.df$OT, JOT2013P, type = "pie", name="Percentage",
                                  colorByPoint = TRUE,dataLabels = list(enabled=TRUE)) 
  })
  
  output$JR<- renderHighchart({
    highchart()%>%
      hc_chart(type="column") %>% 
      hc_xAxis(categories = JR.df$Rtag,tickmarkPlacement = 'on')%>%
      hc_title(text = "Juvenile Detention Population, broken down by Race")%>%
      hc_add_series(data=JB2014,name="African-American Juvenile") %>%
      hc_add_series(data=JW2014,name="White Juvenile") 
  })
  output$JR1<- renderHighchart({
    highchart()%>%
      hc_chart(type="column") %>% 
      hc_xAxis(categories = JR.df$Rtag,tickmarkPlacement = 'on')%>%
      hc_title(text = "Juvenile Detention Population, broken down by Race")%>%
      hc_add_series(data=JB2013,name="African-American Juvenile") %>%
      hc_add_series(data=JW2013,name="White Juvenile") 
  })
  
  
 
})