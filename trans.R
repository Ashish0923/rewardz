#getdata
mocode<-dbGetQuery(con,statement='SELECT mobile ,transactiontype FROM transaction_data where transactiontype=\'accrual\' or transactiontype=\'redemption\'')

#functions
moco<-data.frame(table(mocode$mobile))
names(moco) <- c("mobile","no_trans_tra")
tab<-moco

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.no_trans_tra = t.no_trans_tra')

#removefrom r
rm(moco)
rm(mocode)
rm(tab)