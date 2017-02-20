
shinyUI(

  fluidPage(
    
    list(tags$head(HTML('<link rel="icon", href="logo.png",
                        type="image/png" />'))),
    
    div(style="padding: 1px 0px; width: '100%'",
        titlePanel(
          title="", windowTitle="Window Tab title"
        )
    ),
    
    navbarPage(title="Jail Population Management Dashboard of Champaign County",
               inverse = F, # for diff color view
               theme = shinytheme("flatly"),
  
               
               tabPanel("Welcome", icon = icon("home"),
                        
                        jumbotron("Jail Population Management Dashboard of Champaign County", "This dashboard visualizes racial distribution of population in correctional facilities in Champaign County.  It provides real-time numbers and interactive charts that allows users to 1) have easier access to legal data on inmates who were held in one of the county facilities and 2) get more insights on racial disparity in criminal justice system. This dashboard has five panels: Today's Activity in Jail, Bookings, Bond Payment, Historical Data and Juvenile Detention, each reflecting racial distributions on interested topics. Data used in this dashboard are from daily open data released by Champaign County Sheriff.",button = FALSE)
               ),
               
#-------------------------Panel1----------------------------             
               tabPanel("Today's Activity in Jail", icon = icon("calendar"),
                          fluidRow(
                            hr(),
                            box(width = 12,
                                valueBoxOutput("Date"),
                            box(width=8,panel_div(class_type="primary",panel_title = "Dashboard Overview and Instructions",
                              content = "This panel is a snapshot of demographic information of today's activity in jail. Figure 1 provides of today's total in-jail population and its racial breakdown. Figure 2 is the racial breakdown of newly booked population, contrasted with the racial structure in Champaign County. Move your mouse on each part of the charts to view the numbers.")
                              ))
                            ),
                          hr(),
                            
                          fluidRow(class="middle",
                            column(6,
                                  valueBoxOutput("Total"),br(),br(),br(),br(),br(),br(),br(),
                                  highchartOutput("plot_kk")
                                  ),
                            column(6,
                                  valueBoxOutput("Newbooking"),br(),br(),br(),br(),br(),br(),br(),
                                  highchartOutput("plot_g")
                                  ),
                          tags$head(tags$style(".middle{height:550px;background-color:#f5f6f7;}"))),

                          hr(),
                          fluidRow(class="bottom",
                            column(6,"    Notes:",
                                   p("1. Figure 1 shows only Total Housed Population in downtown and satellite jails, not including EHD (electronic home detention) and other housing."),
                                   p("2. Data in Figure1 is from Champaign Sheriff's Inmate Lookup Webpage on Dec. 5. Due to the CAPTCHA setup of this website, this data is not automatically updated."),
                                   p("3. Bars show the number of people held in jail and the pie chart shows the percentage. Check the figures by moving your mouse on each part of the chart.")
                                   ),
                            column(6,"    Notes:",
                                   p("1. Racial data of new bookings is Stuart Levy's parsing results of Champaign County daily jail logs, retrived from http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log"),
                                   p("2. Source of Champaign County's racial data:U.S. Census Bureau. (2014). American Community Survey 1-year estimate. Retrieved November 13, 2016, from http://factfinder.census.gov")
                                   ),
                            tags$head(tags$style(".bottom{height:200px;}"))
                            )
               ) ,

#-------------------------Panel2----------------------------
               tabPanel("Bookings",icon = icon("book"),
                        wellPanel(
                               helpText(a("Select a Start and End date to view the results")),
                               dateInput('startdate',
                                         label = 'Start From: 2016-03-31',
                                         value="2016-08-01"),
                               dateInput('enddate',
                                         label = 'To: Today',
                                         value="2016-11-30")),
                        hr(),

                        fluidRow(class="up",
                                 br(),
                                 box(width=5,panel_div(class_type="primary",panel_title = "Instructions",
                                                                content = "Booking creates administrative records for arrested suspects. Figure 3 shows the total number of people, and number of people in different race categories being booked on each day in the selected time period, allowing users to observe longitudinal trends of potential racial disparity that exists in correctional facilities."),
                                     p("    Notes:"),
                                     p("Data in Figure 3 is from Champaign County daily jail logs, retrived from http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log")),
                                 column(7,highchartOutput("plot_m")),
                                 tags$head(tags$style(".up{height:400px;background-color:#f5f6f7;}"))),
                        hr(),
                        
                        fluidRow(class="down",
                                 column(7,
                                        highchartOutput("plot_d")),
                                 box(width=5,panel_div(class_type="primary",panel_title = "Instructions",
                                                       content = "Suspects can post bail, or being released on Book-and-Release (BnR), or Release-on-Recognizance (RoR) in lieu of being taken to jail. Figure 4 shows the pre-trial status for people in different racial groups - How many were released and how many ended up in jail.")),
                                 br(),br(),br(),br(),br(),br(),br(),
                                 p("    Notes:"),
                                 p("1. Data in Figure 4 is from Champaign County daily jail logs, retrived from http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log"),
                                 p("2. The category 'Still in Jail at End of Day of Booking' mean those who were not released by RoR, Bail, or BNR on each Daily Jail Log. They might have been released after the 24-hour period that those logs represent."),       
                                 tags$head(tags$style(".down{height:400px;background-color:#f5f6f7;}"))
                        )
                                 
                   ),

#-------------------------Panel3----------------------------------
              tabPanel("Bond Payment",icon = icon("dollar"),

                       hr(),
                       fluidRow(class="bond",
                                br(),
                                box(width=5,panel_div(class_type="primary",panel_title = "Instructions",
                                                      content = "Illinois law typically allows a person to secure their release by paying 10% of the bond set by the court. When the official bond is set at $1000 or less, $10,000 or less, or $25,000 or less, people in pretrial detention are those unable to pay bail of $100, $1000, and $2500. Figure 5 indicates what percent of incarcerated pretrial population, broken down by race, could not pay relatively small sums of money."),
                                    p("    Notes:"),
                                    p("1. Data in Figure 5 is from Champaign Sheriff's Inmate Lookup Webpage on Dec. 5. Due to the CAPTCHA setup of this website, this data is not automatically updated."),
                                    p("2. For each column, the denominator is the total number of people in each bond amount category, the nominator is the number of people of each race in this category.")
                                    ),
                                column(7,highchartOutput("plot_b")),
                                tags$head(tags$style(".bond{height:480px;background-color:#f5f6f7;}"))),
                       hr(),
         
                       fluidRow( 
                         box(width=12, panel_div(class_type="primary",panel_title = "Instructions",
                                               content = "Racial disparity may exist if the percentage of one racial group who cannot pay the bond is very different from the percentage of that group in overall population. Figure 6 makes it visually easier to get an insight of racial disparity by comparing the percentage of each racial group in total population, in booking population and incarcerated population unable to pay bail. The chart can be viewed in selected period of time."))
                         ),
                       br(),
                       fluidRow( 
                         column(width=5,
                                helpText(a("Select a Start and End date to view the results")),
                                dateInput('startdate2',
                                          label = 'Start From: 2016-03-31',
                                          value="2016-08-01"),
                                dateInput('enddate2',
                                          label = 'To: Today',
                                          value="2016-11-30"),
                                p("    Notes:"),
                                p("1. Booking recordes is from Champaign County daily jail logs, retrived from http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log"),
                                p("2. Source of Champaign County's racial data:U.S. Census Bureau. (2015). American Community Survey 1-year estimate. Retrieved November 13, 2016, from http://factfinder.census.gov")
                                ),    
                         box( 
                             highchartOutput("plot_r",height = "400px")),
                         tags$head(tags$style(".up{height:400px;background-color:#f5f6f7;}"))
                         )
              ),


#-------------------------Panel4----------------------------------
              tabPanel("Historical Data",icon = icon("line-chart"),
                        
                       fluidRow( 
                         box(width=8, panel_div(class_type="primary",panel_title = "Instructions",
                                                content = "Our work group collected legal data on inmates who were held Champaign County's criminal facilities beginning January 1, 2010 until November 2, 2016 through a formal FOIA request. This page shows the historical trends of racial distribution based on each year's booking records."))
                       ),
                       
                        fluidRow(
                         column(
                         7, offset=2,
                         highchartOutput("plot_t") )),
                       
                       fluidRow(
                         p("    Notes:"),
                         p("1. Historic Data is provided by Champaign County Sheriff through a formal FOIA request."),
                         p("2. Data in 2016 only include records from the January 1 to November 2."),
                         p("3. Percentage in Figure 7 is the proportation of the number of people of each race in the total number of booking records of this year.")
                       )
              ),



#-------------------------Panel5----------------------------------                 
                   tabPanel("Juvenile Detention",icon = icon("user"),
                            fluidRow( 
                              box(width=8, panel_div(class_type="primary",panel_title = "Instructions",
                                                      content = "This page is a prototype of our next step of work on Juvenile Detention. Due to time limit we were unable to collect more data on this topic. Data on this page is from Illinois Juvenile Detention Data Report (2014)."))
                            ),
                            
                            titlePanel(h3("2014 Juvenile Detention Data in Champaign County")),
                            
                            br(),
                            fluidRow(class="fourteen",
                              valueBoxOutput("JAD"),
                              valueBoxOutput("JP"),
                              valueBoxOutput("JTB"),
                              br(),br(),br(),br(),br(),br(),br(),
                              box(width=6, 
                                  highchartOutput("JOT",height = "300px")),
                              br(),
                              box(width=6, 
                                  highchartOutput("JR",height = "300px")),
                              tags$head(tags$style(".fourteen{height:460px;background-color:#f5f6f7;}"))
                            ),
                            
                            fluidRow(
                                     p("    Notes:"),
                                     p("1. Source: IJJC & CPRD. (2016). Illinois Juvenile Detention Data Report. IJJC. http://ijjc.illinois.gov/sites/ijjc.illinois.gov/files/assets/IJJC%202014%20Detention%20Data%20Report%20-%20January%202016.pdf"),
                                     p("2. Description of Offense Type refers to Appendix 2 in Illinois Juvenile Detention Data Report.")
                            ),
                            
                            hr(),
                            br(),
                            
                            titlePanel(h3("2013 Juvenile Detention Data in Champaign County")),
                            br(),
                            
                            fluidRow(class="thirteen",
                              valueBoxOutput("JAD1"),
                              valueBoxOutput("JP1"),
                              valueBoxOutput("JTB1"),
                              br(),br(),br(),br(),br(),br(),br(),
                              box(width=6, 
                                  highchartOutput("JOT1",height = "300px")),
                              br(),
                              box(width=6, 
                                  highchartOutput("JR1",height = "300px")),
                              tags$head(tags$style(".thirteen{height:460px;background-color:#f5f6f7;}"))
                            ),
                            
                            fluidRow(
                                            p("    Notes:"),
                                            p("1. Source: IJJC & CPRD. (2016). Illinois Juvenile Detention Data Report. IJJC. http://ijjc.illinois.gov/sites/ijjc.illinois.gov/files/assets/IJJC%202014%20Detention%20Data%20Report%20-%20January%202016.pdf"),
                                            p("2. Description of Offense Type refers to Appendix 2 in Illinois Juvenile Detention Data Report.")
                            )
                   )

                   )
)    )         


