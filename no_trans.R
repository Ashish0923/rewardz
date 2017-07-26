#getdata
notrans<-dbGetQuery(con,statement='SELECT mobile,Dt
                    FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab<-unique(notrans)
tab<-data.frame(table(tab$mobile))
names(tab) <- c("mobile","no_trans")

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.no_trans = t.no_trans')

#removefrom r
rm(notrans)
rm(tab)