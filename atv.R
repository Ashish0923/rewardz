#getdata
tab<-dbGetQuery(con,statement='SELECT mobile,postraamt/no_trans as atv
                  FROM final ')

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.atv = t.atv')

#removefrom r
rm(tab)