shinyUI(navbarPage("Racial Disparity Analysis Dashboard",theme = "bootstrap.css",
                   tabPanel("Jail Population",
                            fluidRow(
                              valueBoxOutput("total"),
                              valueBoxOutput("newbooking"),
                              valueBoxOutput("newreleased")
                            ),
                            br(),
                            br(),
                            
                            fluidRow(
                              box(
                                width = 7, status = "info", solidHeader = TRUE,
                                #title = "Total Jail Population",
                                highchartOutput("plot_t") ),
                              box(
                                width = 5, status = "info",
                                #title = "Bond Amount of Jail Population, broken down by Race",
                                highchartOutput("plot_b") ))),
                   
                   tabPanel("Booking",
                            
                            column(width=4,
                                   helpText(tags$b("Bookings by Race")),
                                   dateInput('startdate',
                                             label = 'Start From: yyyy-mm-dd',
                                             #format = "mm/dd/yy",
                                             value="2016-08-01"),
                                   dateInput('enddate',
                                            label = 'To: yyyy-mm-dd',
                                            #format = "mm/dd/yy",
                                            value="2016-11-01"),
                                   br(),
                                   br(),
                                   br(),
                                   br(),
                                   br(),
                                   br(),
                                   helpText(tags$strong("Visualize Arrests By Crime")),
                                   selectInput("crimetype", "Select Crime", 
                                               choices = as.list(sort(as.character(unique(crime$CRIME.CODE.DESCRIPTION)))))
                            ),
                            
                            
                            
                            # Show a plot of the generated distribution
                            column(width=8,
                                   
                                   highchartOutput("plot_m",height = "300px"),
                                   uiOutput("ui")
                            )),
                   
                   
                   tabPanel("Bail",
                            
                            column(width=4,
                                   helpText(tags$b("Bail/Unbail by Race")),
                                   dateInput('startdate2',
                                             label = 'Start From: yyyy-mm-dd',
                                             #format = "mm/dd/yy",
                                             value="2016-08-01"),
                                   dateInput('enddate2',
                                             label = 'To: yyyy-mm-dd',
                                             #format = "mm/dd/yy",
                                             value="2016-11-01")  ),        
                            
                            box(width=8,
                                highchartOutput("plot_d",height = "300px")),
                            br(),
                            box(width=6, 
                                highchartOutput("plot_p",height = "300px")),
                            box(width=6, 
                                highchartOutput("plot_r",height = "300px"))
                            
                   ),
                   
                   tabPanel("Raw Data",
                           numericInput("maxrows", "Rows to show", 25, min=1, max=dim(data)[1]),
                           verbatimTextOutput("rawtable"),
                           downloadButton("downloadCsv", "Download All Data as CSV")
                   )
))



