#Getting data
tot_items_3trans<-dbGetQuery(con,statement="select Mobile,Qty,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)")
tot_items_3trans<-data.table(tot_items_3trans)

res<-tot_items_3trans[,.(tqty=sum(Qty)),by=list(Mobile,Dt)]
res<-res[order(Mobile,-rank(Dt))]
res<-res[,.(Total_Quantity=sum(head(tqty,5))),by=Mobile]

#write tqble to sql
dbWriteTable(con,"temptab",res,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile
           set f.totalitems_last5 = t.Total_Quantity')

#Cleaning
rm(res)
rm(tot_items_3trans)