#Getting data
Year<-dbGetQuery(con,statement='select distinct(Mobile),DATEDIFF(curdate(),Enrolled_on) as DIFF from member_report where Mobile is not null')

#Data Processing
z = quantile(Year$DIFF,c(0.2,0.6),na.rm=TRUE)
y <- data.frame(id = c(0.2,0.6), values = z) 
quan_val<-y[,2]
Year$Type<-NA
Year<-Year[!duplicated(Year$Mobile),]

#Function
Year$Type<-sapply(Year$DIFF,exp)
exp<-function(y)
{
  if(y<quan_val[1])
    return("New")
  else if (y>quan_val && y<quan_val[2])
    return("Medival")
  else 
    return("Old")
}
Year$Type<-sapply(Year$DIFF,exp)
Year$DIFF<-NULL


#write tqble to sql
dbWriteTable(con,"temptab",Year,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')
dbGetQuery(con,statement='alter table supermaster add column Exp varchar(10)')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Exp = t.Type')

#Cleaning
rm(Year)
rm(y)
rm(quan_val)
rm(z)
