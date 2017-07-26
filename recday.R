#getdata
tab<-dbGetQuery(con,statement='SELECT mobile,DATEDIFF(curdate(),Dt) as date,dayname(Dt) as recday
                  FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-data.table(tab)
tab1<-tab[,.(recency = min(date)),by=mobile]
tab<-merge(x = tab, y = tab1, by = "mobile", all=TRUE)
tab = tab[tab$date==tab$recency,]
tab<-unique(tab)

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.recday = t.recday')

#removefrom r
rm(tab)
rm(tab1)