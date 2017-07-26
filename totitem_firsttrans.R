#Getting Data
first_trans_amt<-dbGetQuery(con,statement='select Mobile,Qty,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
first_trans_amt<-data.table(first_trans_amt)
first_trans_amt<-first_trans_amt[order(Mobile,Dt)]

#Function
res<-first_trans_amt[,.(tqty=sum(Qty)),by=list(Mobile,Dt)]
res<-res[, .(Items_first_transaction = head(tqty,1)), by = Mobile]

#write tqble to sql
dbWriteTable(con,"temptab",res,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.first_trans_items = t.Items_first_transaction')

#Cleaning
rm(first_trans_amt)
rm(res)
