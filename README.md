# JailPopulationManagementDashboard

##Project Name: 
Jail Population Management Dashboard of Champaign County

##Description: 
This dashboard uses compiled data from several data sources regarding jailed population and uses Shiny to visualize the racial disparity within correctional facilities in the criminal justice system in Champaign County, IL. 

##Data Sources:
Champaign County Sheriff’s Office Inmate Lookup, extracted from http://www1.co.champaign.il.us/SHERIFF/InmateLookUp.php on 12/14/2016

Champaign County Daily Jail Log (http://www1.co.champaign.il.us/SHERIFF/DailyReports.php). This dashboard uses Stuart Levy's parsing results of jail logs, retrived from http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log on 12/14/2016

FOIA request on inmates held Champaign County's criminal facilities beginning January 1, 2010 until November 2, 2016. Received on 11/17/2016 from Champaign County Sheriff’s Office

Illinois Juvenile Detention Data Report (2014). Retrieved on 12/06/2016 from http://ijjc.illinois.gov/sites/ijjc.illinois.gov/files/assets/IJJC%202014%20Detention%20Data%20Report%20-%20January%202016.pdf

U.S. Census Bureau. (2014). American Community Survey 1-year estimate. Retrieved November 13, 2016, from http://factfinder.census.gov

##Brief Data Description:
###Inmate Lookup:
- Data is a snapshot of information on jailed population on the day of extraction.
- Extractable data points include name, race age, bond, address and book date.
- Data is not automatically updated due to the Captcha system of the website. Currently we overcome the Captcha through the following steps: 
  1.Get in the website http://www1.co.champaign.il.us/SHERIFF/InmateLookUp.php 
  2.Enter the CAPTCHA phrase shown on the Sheriff's website into your web browser and click the 'Submit' button to the right.
  3.Right click on the web page that contains detailed inmate information, choose 'Save as', then select 'Webpage, Complete' as the save type. Save the html file in the working directory.
- The html file “Champaign County, IL Sheriff_ Inmate Lookup.html” in this folder is the retrieved on 12/14/2016. In order to keep the dashboard components that use this data up to date, we need to download the most recent html page and run our script every time.

###Champaign County Daily Jail Log:
- Description of data fields refers to http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log/.
- This dashboard reads the most recent jail log and update the charts (Figure 2,3,4 and 6) accordingly.

###FOIA Data:
- The work group collected legal data on inmates who were held Champaign County's criminal facilities in the past seven years through a formal FOIA request.
- The file “FOIAdata.csv” aggregates the total number of offenders of each race by year (used in Figure 7)
- Column headings of the aggregated data table are the year of their booking, and race (Black, White, Hispanic and Others)

###Juvenile Justice Data
- Juvenile Justice Data was directly read from Illinois Juvenile Detention Data Report (2014).
