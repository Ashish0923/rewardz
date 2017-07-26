#getdata
mobrand<-dbGetQuery(con,statement='SELECT mobile,brand_name as name
                 FROM sku_data
                 where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
mobrand<-data.table(mobrand)
tab<-mobrand[, .(nobrands = length(unique(name))), by = mobile]


#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.nobrands = t.nobrands')

#removefrom r
rm(mobrand)
rm(tab)