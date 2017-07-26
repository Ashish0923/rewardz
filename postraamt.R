#getdata
postraamt<-dbGetQuery(con,statement='SELECT mobile,amount
                    FROM sku_data
                    where mobile is not null and qty>0 and DEPARTMENT is not null')
#functions
postraamt<-data.table(postraamt)
tab<-postraamt[, .(postraamt = sum(amount)), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.postraamt = t.postraamt')

#removefrom r
rm(postraamt)
rm(tab)