#getdata
data<-dbGetQuery(con,statement='SELECT mobile ,DATEDIFF(curdate(),Date) as date,
                 transactiontype FROM transaction_data 
                 where transactiontype=\'redemption\' or transactiontype=\'accrual\'')

tab<-data
tab = tab[tab$transactiontype!='Accrual',]
tab<-data.table(tab)
tab1<-tab[,.(lastred = min(date)),by=mobile]
tab<-merge(x = data, y = tab1, by = "mobile", all.y=TRUE)

tab = tab[(tab$date)<(tab$lastred),]

tab<-data.frame(table(tab$mobile))
names(tab) <- c("mobile","notranslastred")
tab<-merge(x = tab, y = tab1, by = "mobile", all.y=TRUE)

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.notranslastred = t.notranslastred, f.lastred=t.lastred')

#removefrom r
rm(tab)
rm(data)
rm(tab1)