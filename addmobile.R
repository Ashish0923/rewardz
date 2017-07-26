dbGetQuery(con,statement='update sku_data
set department=null
where DEPARTMENT=\'GIFTVOUCHER\'')


mob1<-dbGetQuery(con,statement='SELECT mobile
                  FROM member_report
                where mobile is not null')
mob2<-dbGetQuery(con,statement='SELECT mobile
                  FROM sku_data
                where mobile is not null')
mob3<-dbGetQuery(con,statement='SELECT mobile
                  FROM transaction_data
                where mobile is not null')

mob1<-unique(mob1)
mob2<-unique(mob2)
mob3<-unique(mob3)
tab1 <- rbind(mob1, mob2) 
tab<-rbind(tab1,mob3)
tab<-unique(tab)

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)

#alter final
dbGetQuery(con,statement='insert into final(mobile) select mobile from temptab')

dbGetQuery(con,statement='create unique index MOB on final(mobile)')

#removefromr
rm(mob1)
rm(mob2)
rm(mob3)
rm(tab)
rm(tab1)