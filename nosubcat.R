#getdata
mosubcat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
mosubcat<-data.table(mosubcat)
tab<-mosubcat[, .(nosubcategories = length(unique(name))), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.nosubcategories = t.nosubcategories')

#removefrom r
rm(mosubcat)
rm(tab)