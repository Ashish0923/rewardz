#getdata
tab<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, dt
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-unique(tab)
tab = tab[tab$day!='Saturday',]
tab = tab[tab$day!='Sunday',]
tab<-data.frame(table(tab$mobile))
names(tab) <- c("mobile","noweekdaytrans")

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
           ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
           inner join temptab t on
           t.mobile = f.mobile
           set f.noweekdaytrans = t.noweekdaytrans')

#removefrom r
rm(tab)