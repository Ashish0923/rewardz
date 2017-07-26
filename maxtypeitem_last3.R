#Getting Data
dat<-dbGetQuery(con,statement='select Mobile,SUB_CATEGORY,Dt,Qty from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
dat<-data.table(dat)
dat<-dat[order(Mobile,-rank(Dt))]

#function
data1<-dat[, .(tqty = sum(Qty)), by = list(Mobile,SUB_CATEGORY,Dt)]
data1<-data1[, .(Date=head(Dt,3)), by = list(Mobile,SUB_CATEGORY)]
data1<-data1[, .(no_items = length(unique(SUB_CATEGORY))), by = Mobile]



#write tqble to sql
dbWriteTable(con,"temptab",data1,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')


#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Maxtypeitem_last3  = t.no_items')

rm(dat)
rm(data1)