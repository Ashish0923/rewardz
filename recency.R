#getdata
tab<-dbGetQuery(con,statement='SELECT mobile,DATEDIFF(curdate(),Dt) as recency
                  FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-data.table(tab)
tab<-tab[,.(recency = min(recency)),by=mobile]


#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.recency = t.recency')

#removefrom r
rm(tab)