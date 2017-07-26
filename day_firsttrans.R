#Getting Data
first_trans_day<-dbGetQuery(con,statement='select Mobile,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
first_trans_day<-data.table(first_trans_day)
first_trans_day<-first_trans_day[order(Mobile,Dt)]

res<-first_trans_day[, head(.SD, 1), by=Mobile]
res$day<-NA  
res$day<-as.POSIXlt(res$Dt)$wday

res$type<-NA
fun<-function(y)
{
  if(y==0 || y==6)
    return("weekend customer")
  else
    return("weekday customer")
}
res$type<-sapply(res$day,fun)

#write tqble to sql
dbWriteTable(con,"temptab",res,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')


#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.First_day = t.type')

#Cleaning
rm(res)
rm(first_trans_day)