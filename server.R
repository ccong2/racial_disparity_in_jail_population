shinyServer(function(input, output) {
  
#-------------Panel1----------------
#Figure 1
      output$plot_kk <- renderHighchart({
    highchart() %>% 
      hc_title(text = "Figure 1: Today's In-Jail Population Numbers and Percentages, Broken down by Race") %>%
      hc_add_series_labels_values(Race.info$Race, Race.info$Count, name = "TodayColumn",
                                  colors = c("#434348","#3185d3","#67da4f","#e9ed6b"),
                                  colorByPoint = TRUE, type = "column") %>% 
      hc_add_series_labels_values(Race.info$Race, Race.info$Percent,
                                  colors = c("#434348","#3185d3","#67da4f","#e9ed6b"), 
                                  type = "pie",
                                  name = "TodayBar", colorByPoint = TRUE, center = c('35%', '10%'),
                                  size = 100, dataLabels = list(enabled = FALSE)) %>% 
      hc_yAxis(title = list(text = "Number of People"),
               labels = list(format = "{value}")) %>% 
      hc_xAxis(categories = Race.info$Race) %>% 
      hc_legend(enabled = FALSE) %>% 
      hc_tooltip(pointFormat = "{point.y}")
  })    

#Figure 2  
    output$plot_g <- renderHighchart({ 
      highchart() %>%  
        hc_title(text = "Figure 2: Percentage of Races in Today's New Bookings, Compared with Racial Structures in Champaign County") %>%  
        hc_yAxis(title = list(text = "Percentage"),min=0.00, max=100.00)%>% 
        hc_xAxis(categories = racial.category) %>% 
        hc_add_series(name = "Percentage in Total Jail Population", data = c(racial[1,1], racial[1,2], racial[1,3], racial[1,4]), type = "column",color="#434348") %>%  
        hc_add_series(name = "Percentage in Champaign County Population", data = c(13, 73, 6, 8), type = "column",color="#3185d3")  
    }) 
    
  output$Date <- renderValueBox({
    valueBox(
      value = data.sorted$Date[1],
      subtitle = "Today's Date",
      icon = icon("date"),color="blue"
    )
  })
  
  output$Total <- renderValueBox({
    valueBox(
      value = data.sorted$popHoused[1],
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
  
  #output$Newreleased <- renderValueBox({
    #valueBox(
     # value = data.sorted$releases[1],
      #subtitle = "New Releases Today",
      #icon = icon("sign-out"),color = "purple"
    #)
 # })

#----------------------Panel2----------------------

#Figure 3:
    output$plot_m <- renderHighchart({
    race.data<-subset(race,race$BookDate>=input$startdate & race$BookDate<=input$enddate)
    highchart() %>% 
      hc_title(text = "Figure 3: Booking Records in Selected Time Period, Broken Down by Race") %>% 
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Afam, 
                                 name = "Black", color="#434348") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$White, 
                                 name = "White", color="#3185d3") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Hisp, 
                                 name = "Hispanic", color="#67da4f") %>%
      hc_add_series_times_values(as.Date(race.data$BookDate, "%m/%d/%Y"), race.data$Others, 
                               name = "Others", color="#e9ed6b")
    #hc_add_theme(hc_theme_sandsignika())
  })

#Figure 4
    output$plot_d <- renderHighchart({
      bail2<-subset(bail,bail$BookDate>=input$startdate & bail$BookDate<=input$enddate)
      bail.data<- table(bail2$result, as.character(bail2$racetype))
      bail.data.category <-c("Black", "White", "Hispanic", "Others") 
      
      highchart() %>%  
        hc_title(text = "Figure 4: Number of People Released and In Custody after Booking, Broken Down by Race") %>%  
        hc_yAxis(title = list(text = "Number of People"))%>% 
        hc_xAxis(categories = bail.data.category) %>% 
        hc_add_series(name = "Bail Paid", data = c(bail.data[1,1],bail.data[1,4],bail.data[1,2],bail.data[1,3]), type = "column",color="#434348") %>%  
        hc_add_series(name = "Book and Release", data = c(bail.data[2,1],bail.data[2,4],bail.data[2,2],bail.data[2,3]), type = "column",color="#3185d3")%>%
        hc_add_series(name = "Release on Recognizance", data = c(bail.data[3,1],bail.data[3,4],bail.data[3,2],bail.data[3,3]), type = "column",color="#67da4f")%>%
        hc_add_series(name = "Still in Jail at End of Day of Booking", data = c(bail.data[4,1],bail.data[4,4],bail.data[4,2],bail.data[4,3]),type = "column",color="#e9ed6b")
      
    })     
    
#-------------------------Panel3----------------------------------- 
#Figure 5
    output$plot_b<- renderHighchart({
      highchart()%>%
        hc_chart(type="column") %>% 
        hc_xAxis(categories = c("<=$1000","$1001-5000","$5001-10000","$10001-25000",">=$25001"),tickmarkPlacement = 'on')%>%
        hc_yAxis(title = list(text = "Percentage",min=0,max=105)) %>%
        hc_title(text = "Figure 5: Percentage of Pretrial Population of Different Races, Broken Down by Bond Amount")%>%
        hc_add_series(data=table.bond.t$Black,name="Black",color="#434348") %>%
        hc_add_series(data=table.bond.t$White,name="White",color="#3185d3") %>%
        hc_add_series(data=table.bond.t$Hispanic,name="Hispanic",color="#67da4f") %>%
        hc_add_series(data=table.bond.t$Other,name="Other",color="#e9ed6b") 
    }) 
    

    
#Figure 6
    output$plot_r<-renderHighchart({
    #percentage in jail
      unbail2<-subset(unbail,unbail$BookDate>=input$startdate2 & unbail$BookDate<=input$enddate2)
      ub <- table(unbail2$racetype, as.character(unbail2$result))
      ub.pct<-c(round(ub[1,1]/sum(ub[,1])*100,2),round(ub[4,1]/sum(ub[,1])*100,2),round(ub[2,1]/sum(ub[,1])*100,2),round(ub[3,1]/sum(ub[,1])*100,2))
    #percentage in booking 
      bail3<-subset(bail,bail$BookDate>=input$startdate2 & bail$BookDate<=input$enddate2)
      rep0<-table((bail3$BookDate), as.character(bail3$racetype))
      bk<-c(sum(rep0[,1]),sum(rep0[,4]),sum(rep0[,2]),sum(rep0[,3]))
      bk.pct<-c(round(bk[1]/sum(bk)*100,2),round(bk[2]/sum(bk)*100,2),round(bk[3]/sum(bk)*100,2),round(bk[4]/sum(bk)*100,2))
    #percentage in population 
      pop.pct<-as.numeric(list("12.47","74.16","5.73","7.64"))
      
      rep.category <-c("Black", "White", "Hispanic", "Others")
      
      highchart() %>%  
        hc_title(text = "Figure 6: Comparison of Racial Distribution in Champaign County and in Correctional Facilities, in Selected Time Period") %>%  
        hc_yAxis(title = list(text = "Percentage"))%>% 
        hc_xAxis(categories = rep.category) %>% 
        hc_add_series(name = "Percentage in Champaign County's Total Population", data = pop.pct, type = "column",color="#434348") %>%  
        hc_add_series(name = "Percentage in Total Booking", data = bk.pct, type = "column",color="#3185d3")%>%
        hc_add_series(name = "Percentage in People in Jail", data = ub.pct, type = "column",color="#67da4f")
        
    })
    
#--------------------------Panel4-----------------------------------
#Figure 7
    output$plot_t <- renderHighchart({
      highchart() %>%  
        hc_title(text = "Figure 7: Racial Distribution in Booking Records From 2010 to 2016") %>%  
        hc_yAxis(title = list(text = "Percentage"))%>% 
        hc_xAxis(categories=FOIA$year)%>%
        hc_add_series(name = "Black", data = as.numeric(paste(FOIA$black)), type = "line",color="#434348") %>%  
        hc_add_series(name = "White", data = as.numeric(paste(FOIA$white)), type = "line",color="#3185d3") %>%
        hc_add_series(name = "Hispanic", data = as.numeric(paste(FOIA$hisp)), type = "line",color="#67da4f") %>%
        hc_add_series(name = "Others", data = as.numeric(paste(FOIA$others)), type = "line",color="#e9ed6b") 
    })
    

#--------------------------Panel5-----------------------------------
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
    subtitle = "Total Black Juvenile Detention Population",
    icon = icon("group"),
    color = "light-blue"
  )
})
output$JP1 <- renderValueBox({
  valueBox(
    value = JR.df$JB2013[1],
    subtitle = "Total Black Juvenile Detention Population",
    icon = icon("group"),
    color = "light-blue"
  )
})

output$JTB <- renderValueBox({
  valueBox(
    value = JTP[1],
    subtitle = "Total Black Juvenile Population",
    icon = icon("list"),
    color = "light-blue"
  )
})
output$JTB1 <- renderValueBox({
  valueBox(
    value = JTP[2],
    subtitle = "Total Black Juvenile Population",
    icon = icon("list"),
    color = "light-blue"
  )
})

output$JOT<-renderHighchart({
  highchart() %>%   
    hc_title(text = "Figure 8: Percentage of Juvenile Detention Population, broken up by Offense Type")%>%
    hc_add_series_labels_values(JOT.df$OT, JOT2014P, type = "pie", name="Percentage",
                                colorByPoint = TRUE,dataLabels = list(enabled=TRUE)) 
})
output$JOT1<-renderHighchart({
  highchart() %>%   
    hc_title(text = "Figure 10: Percentage of Juvenile Detention Population, broken up by Offense Type")%>%
    hc_add_series_labels_values(JOT.df$OT, JOT2013P, type = "pie", name="Percentage",
                                colorByPoint = TRUE,dataLabels = list(enabled=TRUE)) 
})

output$JR<- renderHighchart({
  highchart()%>%
    hc_chart(type="column") %>% 
    hc_xAxis(categories = JR.df$Rtag,tickmarkPlacement = 'on')%>%
    hc_yAxis(title = list(text = "Number of People"))%>%
    hc_title(text = "Figure 9: Juvenile Detention Population, broken down by Race")%>%
    hc_add_series(data=JB2014,name="Black Juvenile") %>%
    hc_add_series(data=JW2014,name="White Juvenile") 
})
output$JR1<- renderHighchart({
  highchart()%>%
    hc_chart(type="column") %>% 
    hc_xAxis(categories = JR.df$Rtag,tickmarkPlacement = 'on')%>%
    hc_yAxis(title = list(text = "Number of People"))%>%
    hc_title(text = "Figure 11: Juvenile Detention Population, broken down by Race")%>%
    hc_add_series(data=JB2013,name="Black Juvenile") %>%
    hc_add_series(data=JW2013,name="White Juvenile") 
})



})