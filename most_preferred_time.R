#Getting data
most_preferred_time<-dbGetQuery(con,statement="select Mobile,TransactionDate from transaction_data where Mobile is not null and TransactionDate is not null")
most_preferred_time<-data.table(most_preferred_time)


#Processing
most_preferred_time$Hour<-NA
most_preferred_time$Hour <- format(as.POSIXct(strptime(most_preferred_time$TransactionDate,"%d %b %Y %H:%M:%p",tz="")) ,format = "%H:%M")
most_preferred_time$TransactionDate<-NULL
most_preferred_time$Time<-NA
most_preferred_time$Time<-sapply(strsplit(most_preferred_time$Hour,":"),
       function(x) {
         x <- as.numeric(x)
         x[1]+x[2]/60
       }
)
tab<-data.table(most_preferred_time$Mobile,most_preferred_time$Time)
names(tab)<-c("Mobile","Time")
tab<-tab[,.(Avg_time=mean(Time,na.rm=TRUE)),by=Mobile]
z = quantile(as.numeric(tab$Avg_time),c(0.2,0.6),na.rm=TRUE)
y <- data.frame(id = c(0.2,0.6), values = z) 
quan_val<-y[,2]
tab$Type<-NA
#Function
tab<-data.frame(tab)
tab$Type<-sapply(is.numeric(tab$Avg_time),exp)
exp<-function(y)
{
  if(y<quan_val[1])
    return("Day Customer")
  else if (y>quan_val && y<quan_val[2])
    return("Evening Customer")
  else
    return("Night Customer")
}

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Most_preferred_time = t.Type')

#Cleaning
rm(most_preferred_time)
rm(tab)
rm(tab1)
rm(tab2)
rm(quan_val)
rm(z)
