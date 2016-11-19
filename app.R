library(shinydashboard)
library(ECharts2Shiny)
library(shiny)
library(highcharter)


ui <- dashboardPage(
  dashboardHeader(title = "In Jail Population"),
  dashboardSidebar(),
  dashboardBody(
    fluidRow(
      # Dynamic valueBoxes
      valueBoxOutput("DateBox"),
      
      valueBoxOutput("BookingBox"),
      
      valueBoxOutput("ReleaseBox"),
      highchartOutput("plot")
      
    )
  )
)

jail.sum <- read.csv(url("http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_summary/djlsummary.all.csv"))
jail.sum <- subset(jail.sum, bookings!="NA")

bookdate <- factor(jail.sum$bookDate)
jail.sum$date.list <- as.Date(bookdate, format = "%m/%d/%Y")
most.recent1 <-subset(jail.sum, date.list==max(date.list))



bookings <- read.csv(url("http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log/djl.all.csv"))
bookings <- subset(bookings, as.Date(bookings$BookDate, "%m/%d/%Y") ==max(jail.sum$date.list))
#View(bookings)



per.black=sum(bookings$Race=="B")/length(bookings)
per.black
per.white=sum(bookings$Race=="W")/length(bookings)
per.hispanic=sum(bookings$Race =="H")/length(bookings)
per.others=1-per.black-per.white-per.hispanic

racial <- cbind(per.black, per.white, per.hispanic, per.others)
racial <- rbind(racial, c(0.13, 0.73, 0.06, 0.08))
#racial
racial.category <-c("Black", "White", "Hispanic", "Others")
colnames(racial) <- racial.category
rownames(racial) <- c("Jail", "Champaign County")
class(racial)
class(list(racial[,1]))

server <- function(input, output) {
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
}

shinyApp(ui, server)

