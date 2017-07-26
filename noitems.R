#getdata
moit<-dbGetQuery(con,statement='SELECT mobile,qty as CNT
FROM sku_data
where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
moit<-data.table(moit)
tab<-moit[,.(noitems = sum(CNT)),by=mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.noitems = t.noitems')

#removefrom r
rm(moit)
rm(tab)