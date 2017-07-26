#Getting Data
no_days_lapsed<-dbGetQuery(con,statement='select Mobile,Dt from sku_data where (Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
no_days_lapsed<-data.table(no_days_lapsed)

#Processing Data
no_days_lapsed<-no_days_lapsed[!duplicated(no_days_lapsed), ]

#Function
tab<-no_days_lapsed[, .(last = head(Dt,1)), by =Mobile]
tab1<-no_days_lapsed[, .(first = tail(Dt,1)), by =Mobile]
data<-merge(x =tab, y =tab1, by = "Mobile", all.y=TRUE)
data$No_days_lapsed<-NA
data$No_days_lapsed <- as.Date(data$last)-as.Date(data$first)

#write tqble to sql
dbWriteTable(con,"temptab",data,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')

#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.no_days_lapsed = t.No_days_lapsed')

#Cleaning
rm(data)
rm(no_days_lapsed)
rm(tab)
rm(tab1)