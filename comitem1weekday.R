#getdata
tab<-dbGetQuery(con,statement='SELECT mobile,qty, dayname(dt) as day, sub_category as name
                  FROM sku_data
                where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab = tab[tab$day!='Saturday',]
tab = tab[tab$day!='Sunday',]
tab$day<-NULL
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
           set f.comitem1weekday = t.name')

#removefrom r
rm(tab)
rm(data2)
rm(data)
rm(data1)