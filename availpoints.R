#getdata
data<-dbGetQuery(con,statement='SELECT mobile ,
                 AvailablePoints,transactiontype FROM transaction_data 
                 where transactiontype=\'accrual\' or transactiontype=\'redemption\'')
#functions
data<-data.table(data)
tab<-data[, .(availpoints = sum(AvailablePoints)), by = mobile]

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.availpoints = t.availpoints')

#removefrom r
rm(data)
rm(tab)