#getdata
data<-dbGetQuery(con,statement='SELECT mobile ,
                 Pointsspent,transactiontype FROM transaction_data 
                 where transactiontype=\'redemption\'')
#functions
data<-data.table(data)
tab<-data[, .(totalpointsredeem = sum(Pointsspent)), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.totalpointsredeem = t.totalpointsredeem')

#removefrom r
rm(data)
rm(tab)