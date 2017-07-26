#getdata
days<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, dt
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
data<-dbGetQuery(con,statement='SELECT mobile, comday1
                  FROM final
                  where comday1 is not null')
#functions
days<-unique(days)
tab<-merge(x = data, y = days, by = "mobile", all.x=TRUE)
tab$dt<-NULL
tab = tab[tab$comday1==tab$day,]
tab<-data.table(tab)

tab<-data.frame(table(tab$mobile))
names(tab) <- c("mobile","nocomday1trans")

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
           ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
           inner join temptab t on
           t.mobile = f.mobile
           set f.nocomday1trans = t.nocomday1trans')

#removefrom r
rm(tab)
rm(data)
rm(days)