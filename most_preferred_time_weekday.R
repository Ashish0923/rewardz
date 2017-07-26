#Getting Data
most_preferred_time<-dbGetQuery(con,statement="select Mobile,TransactionDate from transaction_data where Mobile is not null and TransactionDate is not null")
most_preferred_time<-data.table(most_preferred_time)

#Creating column for extraction of data
most_preferred_time$Date<-NA
most_preferred_time$Hour<-NA

#Processing Data
most_preferred_time$Date <- format(as.POSIXct(strptime(most_preferred_time$TransactionDate,"%d %b %Y %H:%M:%p",tz="")) ,format = "%d/%m/%Y")
most_preferred_time$Hour <- format(as.POSIXct(strptime(most_preferred_time$TransactionDate,"%d %b %Y %H:%M:%p",tz="")) ,format = "%H:%M")
most_preferred_time$TransactionDate<-NULL
most_preferred_time$day<-NA
most_preferred_time$day<-as.POSIXlt(most_preferred_time$Date)$wday
most_preferred_time$type<-NA
fun<-function(y)
{
  if(y==0 || y==6)
    return("weekend customer")
  else
    return("weekday customer")
}
most_preferred_time$type<-sapply(most_preferred_time$day,fun)
most_preferred_time$Date<-NULL
most_preferred_time$day<-NULL


tab<-most_preferred_time[type=="weekday customer"]

tab$Time<-NA
tab$Time<-sapply(strsplit(tab$Hour,":"),
                                 function(x) {
                                   x <- as.numeric(x)
                                   x[1]+x[2]/60
                                 }
)
tab<-tab[,.(WeekdayAvg_time=mean(Time,na.rm=TRUE)),by=Mobile]
z = quantile(as.numeric(tab$WeekdayAvg_time),c(0.2,0.6),na.rm=TRUE)
y <- data.frame(id = c(0.2,0.6), values = z) 
quan_val<-y[,2]
tab$Type<-NA
tab<-data.frame(tab)
exp<-function(y)
{
  if(y<quan_val[1])
    return("Day Customer")
  else if (y>quan_val && y<quan_val[2])
    return("Evening Customer")
  else
    return("Night Customer")
}
tab$Type<-sapply(is.numeric(tab$WeekdayAvg_time),exp)


#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Most_preferred_time_Weekday = t.Type')


#Cleaning
rm(most_preferred_time)
rm(tab)
rm(tab1)
rm(y)
rm(quan_val)
rm(z)

