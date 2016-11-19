
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
library(rvest)
library(stringr)

#Panel1: valueboxes: Total Jail Population - jail.pop.summary
data <- read.csv(url("http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_summary/djlsummary.all.csv"), header = T)  
data<-subset(data,data$popTot!="")
data$Date <- as.Date(data$custDate, format="%m/%d/%Y")
data.sorted <- data[order(-1:(dim(data)[1]*-1)),] 


##: Booking record by race 
bookings<-read.csv(url("http://dart.ncsa.uiuc.edu/stuffed/bpnj/daily_jail_log/djl.all.csv"))
bookings<-subset(bookings,bookings$Race != "")
bookings$BookDate <- as.Date(bookings$BookDate, "%m/%d/%Y")

#=====Guyu's part plot_g in Panel1:representation for today===========
booking.today<-subset(bookings, as.Date(bookings$BookDate, "%m/%d/%Y") ==data.sorted$Date[1])
per.black=sum(bookings$Race=="B")/length(bookings)/100
per.white=sum(bookings$Race=="W")/length(bookings)/100
per.hispanic=sum(bookings$Race =="H")/length(bookings)/100 
per.others=1-per.black-per.white-per.hispanic 
racial <- cbind(per.black, per.white, per.hispanic, per.others) 
racial <- rbind(racial, c(0.13, 0.73, 0.06, 0.08)) 
#racial 
racial.category <-c("Black", "White", "Hispanic", "Others") 
colnames(racial) <- racial.category 
rownames(racial) <- c("Jail", "Champaign County") 
#class(racial) 
#class(list(racial[,1]))
#============================================


#plot_kk:Today Population - Inmate Lookup
jail <- read_html("Champaign County, IL Sheriff_ Inmate Lookup.html")
inmate.records <- jail %>% 
  html_nodes("#accordion") %>%
  html_text()
inmate.records


### 1. Get inmate's name
inmate.names <- jail %>% 
  html_nodes("#accordion a") %>%
  html_text()	   
inmate.names[1]
inmate.names.trim <- gsub("\\s+", " ", inmate.names)
inmate.names.trim <- str_trim(inmate.names.trim)
inmate.names.trim

### 2. Get inmate's race
inmate.race <- jail %>% 
  html_nodes(xpath='//*/div/div[1]/div[1]/p/strong[4]/following-sibling::text()[1]') %>%
  html_text()
inmate.race[1]
inmate.race.trim <- gsub("\\s+", " ", inmate.race)
inmate.race.trim <- str_trim(inmate.race.trim)
inmate.race.trim

### 3. Get inmate's age
inmate.age <- jail %>% 
  html_nodes(xpath='//*/div/div[1]/div[1]/p/strong[3]/following-sibling::text()[1]') %>%
  html_text()
inmate.age[1]
inmate.age.trim <- gsub("\\s+", " ", inmate.age)
inmate.age.trim <- str_trim(inmate.age.trim)
inmate.age.trim


### 4. Get inmate's bond
bond <- regexpr("Bond: [-+]?[0-9]*\\.?[0-9]+", inmate.records)
bondlength <- attr(bond,"match.length")
bond.info <- substr(inmate.records,bond+6,bond+bondlength)
bond.info


### 5. Get inmate's address
inmate.add <- jail %>% 
  html_nodes(xpath='//*/div/div[1]/div[1]/p/strong[6]/following-sibling::text()[1]') %>%
  html_text()
inmate.add[1]
inmate.add.trim <- gsub("\\s+", " ", inmate.add)
inmate.add.trim <- str_trim(inmate.add.trim)
inmate.add.trim

### 6. Get inmate's book date
book.date <- regexpr("Booked on: [-+]?[0-9]*\\/?[0-9]+\\/?[0-9]*", inmate.records)
datelength <- attr(book.date,"match.length")
book.date.trim <- substr(inmate.records,book.date+11,book.date+datelength-1)
book.date.trim

### Combine these vectors into a data frame object
inmate.info <- cbind(inmate.names.trim, inmate.race.trim, inmate.age.trim, bond.info, inmate.add.trim, book.date.trim, deparse.level = 1)
colnames(inmate.info) <- c("Name", "Race", "Age", "Bond", "Address", "Bookdate")
inmate.df <- as.data.frame(inmate.info)

afam <- subset(inmate.df, inmate.df$Race == "B")
white <- subset(inmate.df, inmate.df$Race == "W")
Hispanic <- subset(inmate.df, inmate.df$Race == "H")
Others <- subset(inmate.df, inmate.df$Race != "B" & inmate.df$Race != "W" & inmate.df$Race != "H")
Race.info <- cbind(data.frame(value = c("African American","White","Hispanic","Others")),
                   data.frame(value = c(nrow(afam), nrow(white), nrow(Hispanic), nrow(Others))),
                   data.frame(value = c(round(nrow(afam)/nrow(inmate.df)*100,2), 
                                        round(nrow(white)/nrow(inmate.df)*100,2), 
                                        round(nrow(Hispanic)/nrow(inmate.df)*100,2), 
                                        round(nrow(Others)/nrow(inmate.df)*100,2)),
                   deparse.level = 1))
colnames(Race.info) <- c("Race", "Count", "Percent")


#-----------------Panel2----------------------
afam.b <- aggregate(bookings$Race == "B", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
white.b <- aggregate(bookings$Race == "W", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
hisp.b <- aggregate(bookings$Race == "H", list(as.Date(bookings$BookDate, "%m/%d/%Y")), sum)
race.0<-merge(afam.b, white.b, by="Group.1")
race<-merge(race.0, hisp.b, by="Group.1")
colnames(race) <- c("BookDate", "Afam","White","Hisp")


#plot_d:result
bail<-bookings
bail$result<-ifelse(bail$BnR=="BNR","BNR",
                    ifelse(bail$RoR=="RoR", "RoR",
                           ifelse(bail$RBail=="Bail","BailOut","Jail")))
bail$racetype<-ifelse(bail$Race=="B","African-American",
                      ifelse(bail$Race=="W","White",
                             ifelse(bail$Race=="H","Hispanic","Other")))

#-----------------Panel3----------------------
inmate.df.2<-subset(inmate.df,inmate.df$Race!="")
inmate.df.2$Bond<-as.numeric(paste(inmate.df.2$Bond))
inmate.df.2$Condition<-ifelse(inmate.df.2$Bond<=5000,"<=5000",
                            ifelse(inmate.df.2$Bond>5000 & inmate.df.2$Bond<=10000,"5000-10000",
                                   ifelse(inmate.df.2$Bond>10000 & inmate.df.2$Bond<=25000,"10000-25000",">25000")))


data.bond<-data.frame(as.matrix(aggregate(inmate.df.2$Condition,list(inmate.df.2$Race),table)))
#dim(data.bond)
colnames(data.bond)<-c("Race","<=5000","5000-10000","10000-25000",">25000")
table.bond<-data.frame(replicate(4,sample(0:1,4,rep=TRUE)))
colnames(table.bond) <- c("<=5000","5000-10000","10000-25000",">25000")
for (i in (1:4)){
  #table.bond$Race<-c("Other","African-American","Hispanic","White")
  table.bond$`<=5000`[i] <- round(as.numeric(paste(data.bond$`<=5000`[i]))/sum(as.numeric(paste(data.bond$`<=5000`)))*100,2)
  table.bond$`5000-10000`[i] <- round(as.numeric(paste(data.bond$`5000-10000`[i]))/sum(as.numeric(paste(data.bond$`5000-10000`)))*100,2)
  table.bond$`10000-25000`[i] <- round(as.numeric(paste(data.bond$`10000-25000`[i]))/sum(as.numeric(paste(data.bond$`10000-25000`)))*100,2)
  table.bond$`>25000`[i] <- round(as.numeric(paste(data.bond$`>25000`[i]))/sum(as.numeric(paste(data.bond$`>25000`)))*100,2)
}
table.bond.t<-as.data.frame(t(table.bond))
colnames(table.bond.t) <- c("Other","African-American","Hispanic","White")

#-----------------Panel4--------------------

#read in csv
data.t<-subset(data,data$Date>="2016-08-01")

#-----------------Panel5--------------------
JAD2013 <- c(373, 16803,22.2)
JAD2014 <- c(406, 17107,23.7)
AD <- c("Admissions", "IL Population Age 10-17", "Rate per 1000")
JAD <- cbind(AD,JAD2013,JAD2014)
JAD.df <- as.data.frame(JAD)

JOT2013 <- c(5,13,40, 96, 9, 22, 1, 116, 71)
JOT2014 <- c(17,5,45,128,3,17,1,126,64)
JOT2013P <- JOT2013/sum(JOT2013)*100
JOT2014P <- JOT2014/sum(JOT2014)*100
OT <-c("Contempt","Drug","Other","Property","Sex","Status Offense","Violations","Violent","Warrant")
JOT <- cbind(OT,JOT2013,JOT2013P,JOT2014,JOT2014P)
JOT.df <- as.data.frame(JOT)

Rtag <- c("Admissions","Rate per 1000")
JB2013 <- c(305,NA)
JW2013 <- c(84,NA)

JTP <- c(3756,NA,11718,NA)
JB2014 <- c(330,87.9)
#3756
JB2014 <- as.numeric(JB2014)
JW2014 <- c(74,6.3)
#11718
JW2014 <- as.numeric(JW2014)
JR <- cbind(Rtag,JB2013, JW2013, JB2014,JW2014)
JR.df <- as.data.frame(JR)
