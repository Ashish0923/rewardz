#getdata
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name,qty
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
data<-dbGetQuery(con,statement='SELECT mobile,comitem1
                  FROM final where comitem1 is not null')

#functions
tab<-merge(x=mocat, y=data, by = "mobile", all=TRUE)
tab = tab[tab$comitem1!=tab$name,]
tab$comitem1<-NULL

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
set f.comitem2 = t.name')

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(data1)
rm(data2)