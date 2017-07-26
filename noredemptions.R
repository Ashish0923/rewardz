#getdata
data<-dbGetQuery(con,statement='SELECT mobile ,
                 transactiontype FROM transaction_data 
                 where transactiontype=\'redemption\'')

#functions
tab<-data.frame(table(data$mobile))
names(tab) <- c("mobile","noredemptions")

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.noredemptions = t.noredemptions')

#removefrom r
rm(data)
rm(tab)