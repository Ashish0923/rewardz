#Getting Data
no_days<-dbGetQuery(con,statement='select Mobile,Dt from sku_data (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
no_days<-data.table(no_days)

#Processing Data
no_days<-no_days[!duplicated(no_days), ]
no_daya<-no_days[order(Mobile,-rank(Dt))]
no_days<-no_days[, .(Date=head(Dt,5)), by = list(Mobile)]
tab<-no_days[, .(last = head(Date,1)), by =Mobile]
tab1<-no_days[, .(first = tail(Date,1)), by =Mobile]
data<-merge(x =tab, y =tab1, by = "Mobile", all.y=TRUE)
data$No_days<-NA
data$No_days<- as.Date(data$last)-as.Date(data$first)


#write tqble to sql
dbWriteTable(con,"temptab",data,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')


#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.diff_last5 = t.No_days')

#Cleaning
rm(data)
rm(no_days)
rm(tab)
rm(tab1)
