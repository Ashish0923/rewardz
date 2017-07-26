#Getting Data
dat<-dbGetQuery(con,statement='select Mobile,SUB_CATEGORY,Dt,Qty from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
dat<-data.table(dat)

#Function
dat<-dat[, .(tqty = sum(Qty)), by = list(Mobile,SUB_CATEGORY,Dt)]
dat<-dat[order(Mobile,-rank(Dt))]
dat<-dat[, .(Date=head(Dt,5)), by = list(Mobile,SUB_CATEGORY)]
dat<-dat[, .(no_items = length(unique(SUB_CATEGORY))), by = Mobile]



#write tqble to sql
dbWriteTable(con,"temptab",dat,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')


#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.Maxtypeofitems = t.no_items')

#Cleaning
rm(dat)
