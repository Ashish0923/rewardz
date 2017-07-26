#Getting data
most_preferred_time<-dbGetQuery(con,statement="select Mobile,TransactionDate from transaction_data where Mobile is not null and TransactionDate is not null")
most_preferred_time<-data.table(most_preferred_time)


#Processing
most_preferred_time$Date<-NA
most_preferred_time$Date <- format(as.POSIXct(strptime(most_preferred_time$TransactionDate,"%d %b %Y %H:%M:%p",tz="")) ,format = "%d/%m/%Y")
most_preferred_time$TransactionDate<-NULL

#Function
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
tab<-data.table(most_preferred_time$Mobile,most_preferred_time$type)
names(tab)<-c("Mobile","Day")
tab1<-data.frame(table(tab$Mobile))
names(tab1)<-c("Mobile","freq")
tab$num<-1
tab<-tab[,.(count=sum(num)),by=list(Mobile,Day)]
tab2<-merge(x=tab,y=tab1,by="Mobile",all.y=TRUE)
tab2<-tab2[count==freq]
tab2$count<-NULL
tab2$freq<-NULL

#write tqble to sql
dbWriteTable(con,"temptab",tab2,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Most_preferred_day = t.Day')


#Cleaning
rm(most_preferred_time)
rm(tab)
rm(tab1)
rm(tab2)
rm(quan_val)
rm(z)
