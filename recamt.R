#getdata
amt<-dbGetQuery(con,statement='SELECT mobile,amount,DATEDIFF(curdate(),Dt) as date
                    FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-data.table(amt)
tab<-tab[,.(recency = min(date)),by=mobile]
tab<-merge(x = amt, y = tab, by = "mobile", all.x=TRUE)
tab = tab[tab$date==tab$recency,]
tab<-data.table(tab)
tab<-tab[, .(recamt = sum(amount)), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.recamt = t.recamt')

#removefrom r
rm(amt)
rm(tab)
