#getdata
data<-dbGetQuery(con,statement='SELECT mobile,sub_category as name,qty,DATEDIFF(curdate(),Dt) as date
                    FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')
com<-dbGetQuery(con,statement='SELECT mobile, reccomitem
                 FROM final
                 where reccomitem is not null')
  
#functions
tab<-data.table(data)
tab<-tab[,.(recency = min(date)),by=mobile]
tab<-merge(x = data, y = tab, by = "mobile", all.x=TRUE)
tab = tab[tab$date==tab$recency,]
tab<-data.table(tab)
tab<-merge(x = tab, y = com, by = "mobile", all.x=TRUE)
tab = tab[tab$name==tab$reccomitem,]
tab<-tab[, .(noreccomitem = sum(qty)), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.noreccomitem = t.noreccomitem')

#removefrom r
rm(tab)
rm(data)
rm(com)