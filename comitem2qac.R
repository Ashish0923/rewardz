#getdata
data<-dbGetQuery(con,statement='Select mobile,comitem2 from final where comitem2 is not null')
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name, qty, amount
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-merge(x = data, y = mocat, by = "mobile", all.x=TRUE)
tab = tab[tab$comitem2==tab$name,]
tab<-data.table(tab)
tab2<-tab[, .(comitemqty2 = sum(qty)), by = mobile]
tab3<-tab[, .(comitemamt2 = sum(amount)), by = mobile]
tab<-merge(x = tab2, y = tab3, by = "mobile", all=TRUE)
tab$comitemcost2<-NA
tab$comitemcost2[]<-tab$comitemamt2[]/tab$comitemqty2[]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitemqty2 = t.comitemqty2 , f.comitemamt2 = t.comitemamt2 , f.comitemcost2 = t.comitemcost2')

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(tab2)
rm(tab3)