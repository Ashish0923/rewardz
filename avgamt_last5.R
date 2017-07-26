#Getting Data
data<-dbGetQuery(con,statement='select Mobile,Amount,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
data<-data.table(data)
data<-data[order(Mobile,-rank(Dt))]
res<-data[,.(Amount=sum(Amount)),by=list(Mobile,Dt)]
tab<-res[,.(Avg_amount_last5=mean(head(Amount,5))),by=Mobile]
z = quantile(tab$Avg_amount_last5,c(0.2,0.6),na.rm=TRUE)
y <- data.frame(id = c(0.2,0.6), values = z) 
quan_val<-y[,2]
#Function
tab$Type<-NA
fun<-function(y)
{
  if(y<quan_val[1])
    return("Bad")
  else if (y>quan_val && y<quan_val[2])
    return("Moderate")
  else 
    return("Good")
}
tab$Type<-sapply(tab$Avg_amount_last5,fun)

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')
#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Avg_amount_last5 = t.Type')

#Cleaning
rm(data)
rm(res)
rm(tab)
rm(y)
rm(z)
rm(quan_val)
