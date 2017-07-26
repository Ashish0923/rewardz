#getdata
data<-dbGetQuery(con,statement='Select mobile,comitem1 from final where comitem1 is not null')
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name, qty, amount
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-merge(x = data, y = mocat, by = "mobile", all=TRUE)
tab = tab[tab$comitem1==tab$name,]
tab<-data.table(tab)
tab2<-tab[, .(comitemqty1 = sum(qty)), by = mobile]
tab3<-tab[, .(comitemamt1 = sum(amount)), by = mobile]
tab<-merge(x = tab2, y = tab3, by = "mobile", all=TRUE)
tab$comitemcost1<-NA
tab$comitemcost1[]<-tab$comitemamt1[]/tab$comitemqty1[]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitemqty1 = t.comitemqty1 , f.comitemamt1 = t.comitemamt1 , f.comitemcost1 = t.comitemcost1')

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(tab2)
rm(tab3)