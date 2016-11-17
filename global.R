
#install.packages("rdrop2")
#install.packages("RCurl")

library(shiny)
library(shinydashboard)
library(highcharter)
library(dplyr)
library(tidyr)
library(rdrop2)
library(lubridate)

#library(RCurl)

#----------Guyu's Part----------Values Boxes for Real-Time Data
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

#----------------------------------------------------------------------------------------------------
#----------Panel1-------------
#plot_t: Total Jail Population - jail.pop.summary
data <- read.csv("jail_pop_summary.csv", header = T)  
data$Date <- as.Date(data$Date, format="%m/%d/%Y")
data.sorted <- data[order(-1:(dim(data)[1]*-1)),] 


#plot_b:Bond Payment by Race - Inmate Lookup

library(rvest)
library(stringr)

jail <- read_html("C:\\00Cong Files\\MUP2016FALL\\494\\Test_Shiny\\Final\\Inmate Lookup.html")

inmate.records <- jail %>% 
  html_nodes("#accordion") %>%
  html_text()	   

inmate.names <- jail %>% 
  html_nodes("#accordion a") %>%
  html_text()	   
inmate.names
inmate.names.trim <- gsub("\\s+", " ", inmate.names)
inmate.names.trim <- str_trim(inmate.names.trim)

inmate.race <- jail %>% 
  html_nodes(xpath='//*/div/div[1]/div[1]/p/strong[4]/following-sibling::text()[1]') %>%
  html_text()
inmate.race
inmate.race.trim <- gsub("\\s+", " ", inmate.race)
inmate.race.trim <- str_trim(inmate.race.trim)

inmate.bond <- jail %>% 
  html_nodes(xpath='//*/div/div[3]/div[1]/p/strong/following-sibling::text()[1]') %>%
  html_text()
inmate.bond
inmate.bond.trim <- gsub("\\s+", " ", inmate.bond)
inmate.bond.trim <- str_trim(inmate.bond.trim)

table<-data.frame(replicate(4,sample(0:1,188,rep=TRUE)))
colnames(table) <- c("Name","Race","Bond","Condition")
for (i in (1:188)){
  table$Name[i] <- inmate.names.trim[i]  
  table$Race[i]<-inmate.race.trim[i]
  a.record <- inmate.records[i]
  table$Condition[i]<- gsub(".*Bed:|Charges.*", "",a.record)
  table$Bond[i]<-substr(table$Condition[i], 12, 18)
}
#View(table)

data1<-subset(table,table$Bond!="" & table$Bond!=" Schedu" & table$Race!="")
data1<-subset(data1,select=c("Race", "Bond","Condition"))
#View(data1)

data1$Bond<-as.double(data1$Bond)
data1$Condition<-ifelse(data1$Bond<=5000,"<=5000",
                       ifelse(data1$Bond>5000 & data1$Bond<=10000,"5000-10000",
                              ifelse(data1$Bond>10000 & data1$Bond<=25000,"10000-25000",">25000")))


data.bond<-data.frame(as.matrix(aggregate(data1$Race,list(data1$Condition),table)))
#dim(data.bond)
colnames(data.bond)<-c("BondPayment","Other","African-American","Hispanic","White")
data.bond$`African-American`<-as.double(data.bond$`African-American`)
data.bond$Other<-as.double(data.bond$Other)
data.bond$White<-as.double(data.bond$White)
data.bond$Hispanic<-as.double(data.bond$Hispanic)



#------------Panel2-------------------
#plot_m: Booking record by race 
bookings<-read.csv("djl.all.csv")
bookings<-subset(bookings,bookings$Race != "")
bookings$BookDate <- as.Date(bookings$BookDate, "%m/%d/%Y")
afam <- aggregate(bookings$Race == "B", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
white <- aggregate(bookings$Race == "W", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
hisp <- aggregate(bookings$Race == "H", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
race.0<-merge(afam, white, by="Group.1")
race<-merge(race.0, hisp, by="Group.1")
colnames(race) <- c("BookDate", "Afam","White","Hisp")


#plot_c: Crime Type by race - Police Arrest Data
crime<-read.csv("RJTF-Request1-Arrests-10_14_16.csv")
crime<-subset(crime,crime$RACE.DESCRIPTION != ".")
crime<-subset(crime,crime$RACE.DESCRIPTION != "UNKNOWN")
crime<-subset(crime,crime$RACE.DESCRIPTION != "")
crime.sub <- as.data.frame(table(crime$CRIME.CODE.DESCRIPTION, as.character(crime$RACE.DESCRIPTION)))
colnames(crime.sub) <- c("CrimeType", "Race","Persons")

#-----------Panel3--------------------
#plot_d:result
bail<-bookings
bail$result<-ifelse(bail$BnR=="BNR","BNR",
                    ifelse(bail$RoR=="RoR", "RoR",
                           ifelse(bail$RBail=="Bail","BailOut","Jail")))
bail$racetype<-ifelse(bail$Race=="B","African-American",
                      ifelse(bail$Race=="W","White",
                             ifelse(bail$Race=="H","Hispanic","Other")))

