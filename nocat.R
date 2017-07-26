#getdata
mocat<-dbGetQuery(con,statement='SELECT mobile,category as name
                    FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
mocat<-data.table(mocat)
tab<-mocat[, .(nocategories = length(unique(name))), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.nocategories = t.nocategories')

#removefrom r
rm(mocat)
rm(tab)