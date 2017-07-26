#Getting Data
no_trans<-dbGetQuery(con,statement='select Mobile,Qty,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
no_trans<-data.table(no_trans)

#Function
data<-no_trans[,.(tqty=sum(Qty)),by=list(Mobile,Dt)]
data<-data[order(Mobile,-rank(Dt))]
data<-data[, .( last5= head(tqty,5)), by = Mobile]
data<-data[,.(avg_no_items=mean(head(last5,5))),by=Mobile]


#write tqble to sql
dbWriteTable(con,"temptab",data,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')
#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.itemspertrans_last5 = t.avg_no_items')

#cleaning
rm(data)
rm(no_trans)