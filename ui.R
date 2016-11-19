#ideas: navbar so we can have a separate page for uncommon disease plots and for p&i data

shinyUI(navbarPage("Jail Population Dashboard",theme = "bootstrap.css",
                   tabPanel("Today",
                            titlePanel(h3("Today's Activity in Jail")),
                            fluidRow(  
                              valueBoxOutput("Date")),
                            fluidRow(                             
                              valueBoxOutput("Total"),
                              valueBoxOutput("Newbooking"),
                              valueBoxOutput("Newreleased")
                            ),
                            br(),
                            
                            fluidRow(
                              box(
                                width = 6, status = "info", solidHeader = TRUE,
                                highchartOutput("plot_g") ),
                              box(width=6, 
                                  highchartOutput("plot_kk"),height = "100px"))
                            #box(
                            # width = 6, status = "info",
                            #  title = "Change in Jail Population",
                            # tableOutput("plot_x") ))
                   ),
                   tabPanel("Booking",
                            titlePanel(h3("Arrest Resolutions and Bookings by Race")),
                            column(width=4,
                                   dateInput('startdate',
                                             label = 'Start From: 2016-03-31',
                                             #format = "mm/dd/yy",
                                             value="2016-08-01"),
                                   dateInput('enddate',
                                             label = 'To: Today',
                                             #format = "mm/dd/yy",
                                             value="2016-11-30")),
                            
                            
                            column(width=8,
                                   
                                   highchartOutput("plot_d",height = "300px"),
                                   highchartOutput("plot_m",height = "300px"))
                            
                            
                   ),
                   tabPanel("Bond",
                            titlePanel(h3("Bond Payment by Race")),
                            fluidRow(
                              valueBoxOutput("Date2"),
                              column(8,offset=3,highchartOutput("plot_b",height = "300px" ))),
                            
                            fluidRow(  
                              titlePanel(h3("Race Representation Comparison")),
                              column(width=3,
                                     #helpText(tags$b("Bail/Unbail by Race")),
                                     dateInput('startdate2',
                                               label = 'Start From: 2016-03-31',
                                               #format = "mm/dd/yy",
                                               value="2016-08-01"),
                                     dateInput('enddate2',
                                               label = 'To: Today',
                                               #format = "mm/dd/yy",
                                               value="2016-11-30")  ),    
                              box(width=8, 
                                  highchartOutput("plot_r",height = "300px")))
                   ),
                   tabPanel("JailPopulation",
                            fluidRow(column(
                              7, offset=2,
                              #title = "Total Jail Population",
                              highchartOutput("plot_t") )),
                            fluidRow(   
                              numericInput("maxrows", "Rows to show", 10, min=1, max=dim(data)[1]),
                              verbatimTextOutput("rawtable")
                            )
                   ),
                   tabPanel("Juvenile Detention",
                            titlePanel(h3("2014 Detention Data")),
                            fluidRow(
                              valueBoxOutput("JAD"),
                              valueBoxOutput("JP"),
                              valueBoxOutput("JTB")
                            ),
                            fluidRow(
                              box(width=6, 
                                  highchartOutput("JOT",height = "300px")),
                              br(),
                              box(width=6, 
                                  highchartOutput("JR",height = "300px"))
                            ),
                            
                            titlePanel(h3("2013 Detention Data")),
                            fluidRow(
                              valueBoxOutput("JAD1"),
                              valueBoxOutput("JP1"),
                              valueBoxOutput("JTB1")
                            ),
                            fluidRow(
                              box(width=6, 
                                  highchartOutput("JOT1",height = "300px")),
                              br(),
                              box(width=6, 
                                  highchartOutput("JR1",height = "300px"))
                            )
                   )

                   )
)             


