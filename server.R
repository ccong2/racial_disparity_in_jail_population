shinyServer(function(input, output) {
  
#-----------Panel1-----------------------
  
  output$DateBox <- renderValueBox({
    valueBox(most.recent1$date.list, "Date", icon=icon("date"), color = "blue")
  })
  
  output$BookingBox <- renderValueBox({
    valueBox(most.recent1$bookings,"New Bookings", icon=icon("list"),color = "purple"
      
    )
  })
  
  output$ReleaseBox <- renderValueBox({
    valueBox(
      most.recent1$releases,"New Releases", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  output$plot <- renderHighchart({
   
    
    highchart() %>% 
    
    hc_title(text = "New Bookings by Race") %>% 
    hc_yAxis(min=0.00, max=1.00)%>%
    hc_xAxis(categories = racial.category) %>%
    hc_add_series(name = "Jail", data = c(racial[1,1], racial[1,2], racial[1,3], racial[1,4]), type = "column") %>% 
    hc_add_series(name = "Champaign County", data = c(0.13, 0.73, 0.06, 0.08), type = "column") 
   
  })
#--------------------------------------------------------------------------
  
  output$plot_t <- renderHighchart({
    highchart() %>% 
      hc_title(text = "Total Jail Population by Date") %>% 
      hc_add_series_times_values(as.Date(data$Date, "%m/%d/%Y"), data$Tot.Pop, 
                                 name = "In Jail") %>%
      hc_add_theme(hc_theme_sandsignika())
  })
  
  output$plot_b<- renderHighchart({
    highchart()%>%
      hc_chart(type="column") %>% 
      hc_xAxis(categories = data.bond$BondPayment,tickmarkPlacement = 'on')%>%
      hc_title(text = "Bond Amount of Jail Population, broken down by Race")%>%
      hc_add_series(data=data.bond$`African-American`,name="African-American") %>%
      hc_add_series(data=data.bond$White,name="White") %>%
      hc_add_series(data=data.bond$Hispanic,name="Hispanic") %>%
      hc_add_series(data=data.bond$Other,name="Others") 
  })
  
  output$total <- renderValueBox({
    valueBox(
      value = data.sorted$Tot.Pop[1],
      subtitle = "Total Jail Population Today",
      icon = icon("group"),
      color = "light-blue"
    )
  })
  
  output$newbooking <- renderValueBox({
    valueBox(
      value = data.sorted$Bookings[1],
      subtitle = "New Booking Today",
      icon = icon("sign-in"),
      color = "light-blue"
    )
  })
  
  output$newreleased <- renderValueBox({
    valueBox(
      value = data.sorted$Releases[1],
      subtitle = "New Release Today",
      icon = icon("sign-out"),
      color = "aqua"
    )
  })
  
#---------Panel2----------------------------
  output$plot_m <- renderHighchart({
    
    race.data<-subset(race,race$BookDate>input$startdate & race$BookDate<input$enddate)
    
    highchart() %>% 
      hc_title(text = "Bookings by Race and Date") %>% 
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Afam, 
                                 name = "African-American") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$White, 
                                 name = "White") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Hisp, 
                                 name = "Hispanic") %>%
      hc_add_theme(hc_theme_sandsignika())
  })
  
  output$ui <- renderUI({
    tabsetPanel(type = "tabs", 
                tabPanel("Plot", highchartOutput("ui_p",height = "300px")), 
                tabPanel("Table", tableOutput("ui_t")))
  })
  
  
  output$ui_p<- renderHighchart({
    crime.plot<-subset(crime.sub,crime.sub$CrimeType==input$crimetype)
    hchart(crime.plot, "column", x=CrimeType, y=Persons, group=Race) %>%     
      hc_title(text = paste0("Arrests by Race and Resolution for ", as.character(input$crimetype)))
  })
  
  output$ui_t <- renderTable({
    crime.table<-subset(crime.sub,crime.sub$CrimeType==as.character(input$crimetype))
    print.table(crime.table)
  })
  
#---------Panel3--------------------
  #plot_d:Arrest Result by Race
  output$plot_d <- renderHighchart({
    bail2<-subset(bail,bail$BookDate>input$startdate2 & bail$BookDate<input$enddate2)
    bail.data <- as.data.frame(table(bail2$result, as.character(bail2$racetype)))
    colnames(bail.data) <- c("Result", "Race", "Freq")
    
    hchart(bail.data, "column", x=Race, y=Freq, group=Result) %>%     
      hc_title(text = "Arrest Result by Race")
  })
  
  
  #plot_p:pie chart unable to bail out
  output$plot_p<-renderHighchart({
    bail2<-subset(bail,bail$BookDate>input$startdate2 & bail$BookDate<input$enddate2)
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
    
    highchart() %>%   
      hc_title(text = "Unable to bail out, broken up by Race")%>%
      hc_add_series_labels_values(unbail.data$Race, unbail.data$UBPerct, type = "pie", name="Percentage",
                                  colorByPoint = TRUE,dataLabels = list(enabled=TRUE)) 
  })
  
  
  
  #plot_r:representation
  output$plot_r<-renderHighchart({
    
    #rep0<-subset(bkrep,bkrep$BookDate>=format(input$startdate2) & bkrep$BookDate<=format(input$startdate2) )
    bail2<-subset(bail,bail$BookDate>input$startdate2 & bail$BookDate<input$enddate2)
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
      hc_title(text = "Racial representation in Champaign County and correctional facilities")%>%
      hc_add_series(data=final.data$PopPerct, name="Percentage in Total Population") %>%
      hc_add_series(data=final.data$BKPerct,name="Percentage in Booking") %>%
      hc_add_series(data=final.data$UBPerct,name="Percentage in Unable to bail out") 
    
  })
  
  #-----------Panel4
  output$downloadCsv <- downloadHandler(
    filename = "jail_pop_summary.csv",
    content = function(file) {
      write.csv(data, file)
    },
    contentType = "text/csv"
  )
  
  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print((tail(data, input$maxrows)),row.names=FALSE)
    options(orig)
    
  })
  
})




#=========END OF SCRIPT==========





#output$table_c <- renderTable({
 # lval <- dim(change.data)[1]
  #lval <- lval * -1
  #change.data.display <- change.data[order(-1:lval),] 
  #change.data.display <- head(change.data.display, 11)
#}, digits = 1, include.rownames=FALSE)



