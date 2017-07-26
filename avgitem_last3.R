#Getting Data
no_trans<-dbGetQuery(con,statement='select Mobile,Qty,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
no_trans<-data.table(no_trans)
no_trans<-no_trans[order(Mobile,-rank(Dt))]

#Function
data<-no_trans[,.(tqty=sum(Qty)),by=list(Mobile,Dt)]
data<-data[, .( last3= head(tqty,3)), by = Mobile]
data<-data[,.(avg_no_items=mean(head(last3,3))),by=Mobile]


#write tqble to sql
dbWriteTable(con,"temptab",data,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.itemspertrans_last3 = t.avg_no_items')

#Cleaning
rm(no_trans)
rm(data)
