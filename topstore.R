#Getting Data
dat<-dbGetQuery(con,statement='select Mobile,Qty,STORE from sku_data where(Mobile!=\'NULL\' and SUB_CATEGORY!=\'CARRY BAG\' and DEPARTMENT!=\'NULL\' and Qty>0)')
dat<-data.table(dat)


#Function
data1<-dat[, .(tqty = sum(Qty)), by = list(Mobile,STORE)]
data2<-data1[,.(top3 = head(STORE,3)),by=Mobile]
data2<-data2[!duplicated(data2)]
tab1<-data2[,.(top_store=head(top3,1)),by=Mobile]
data3<- data2[,.(top2=tail(top3,2)),by=Mobile] 
tab2<-data3[,.(second_top_store=head(top2,1)),by=Mobile]
tab3<-data3[,.(third_top_store=tail(top2,1)),by=Mobile]
tab<-merge(x =tab1, y = tab2, by = "Mobile", all.y=TRUE)
mod_tab<-merge(x = tab, y = tab3, by = "Mobile", all.y=TRUE)


#write tqble to sql
dbWriteTable(con,"temptab",mod_tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab ADD PRIMARY KEY (Mobile(15))')
#alter final
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.top_store = t.top_store')
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.second_top_store = t.second_top_store')
dbGetQuery(con,statement='update supermaster f inner join temptab t on t.mobile = f.mobile set f.third_top_store = t.third_top_store')

#Cleaning
rm(dat)
rm(data1)
rm(data2)
rm(data3)
rm(mod_tab)
rm(tab)
rm(tab1)
rm(tab2)
rm(tab3)

