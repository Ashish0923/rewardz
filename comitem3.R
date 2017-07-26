#getdata
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name,qty
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
data1<-dbGetQuery(con,statement='SELECT mobile,comitem1
                 FROM final where comitem1 is not null')
data2<-dbGetQuery(con,statement='SELECT mobile,comitem2
                 FROM final where comitem2 is not null')

#functions
tab1<-merge(x=mocat, y=data1, by = "mobile", all=TRUE)
tab1 = tab1[tab1$comitem1!=tab1$name,]
tab1$comitem1<-NULL

tab2<-merge(x=tab1, y=data2, by = "mobile", all=TRUE)
tab2 = tab2[tab2$comitem2!=tab2$name,]
tab2$comitem2<-NULL
tab<-tab2

data<-tab
data<-data.table(data)
data1<-data[, .(tqty = sum(qty)), by = list(mobile,name)]
data2<-data1[,.(nomo = max(tqty)),by=mobile]
tab<-merge(x = data1, y = data2, by = "mobile", all.y=TRUE)
tab = tab[tab$tqty==tab$nomo,]
tab<-unique(tab)
tab$tqty<-NULL
tab$nomo<-NULL

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitem3 = t.name')

#removefrom r
rm(tab)
rm(mocat)
rm(data1)
rm(data2)
rm(tab1)
rm(tab2)
rm(data)