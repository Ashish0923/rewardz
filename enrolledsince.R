#getdata
mobiles<-dbGetQuery(con,statement='SELECT mobile FROM final ')
enroll<-dbGetQuery(con,statement='SELECT mobile,DATEDIFF(curdate(),Enrolled_on) as enroll
                  FROM member_report')
trans<-dbGetQuery(con,statement='SELECT mobile,DATEDIFF(curdate(),Date) as trans
                  FROM transaction_data where transactiontype=\'accrual\' or transactiontype=\'redemption\'')
sku<-dbGetQuery(con,statement='SELECT mobile,DATEDIFF(curdate(),Dt) as sku
                  FROM sku_data where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
enroll<-data.table(enroll)
enroll<-enroll[,.(enroll = min(enroll)),by=mobile]
trans<-data.table(trans)
trans<-trans[,.(trans = min(trans)),by=mobile]
sku<-data.table(sku)
sku<-sku[,.(sku = min(sku)),by=mobile]
mobiles<-merge(x = mobiles, y = enroll, by = "mobile", all=TRUE)
mobiles<-merge(x = mobiles, y = trans, by = "mobile", all=TRUE)
mobiles<-merge(x = mobiles, y = sku, by = "mobile", all=TRUE)
tab<-mobiles
tab$enrolledsince<-with(mobiles,pmax(enroll,trans,sku,na.rm=TRUE))
tab$enroll<-NULL
tab$sku<-NULL
tab$trans<-NULL

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.enrolledsince = t.enrolledsince')

#removefrom r
rm(tab)
rm(enroll)
rm(sku)
rm(trans)
rm(mobiles)