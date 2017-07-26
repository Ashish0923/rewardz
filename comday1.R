#getdata
tab<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, dt
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
#functions
tab<-unique(tab)
tab$dt<-NULL
mode <- function(x) names(table(x))[ which.max(table(x)) ]
tab$comday1 <- ave(tab$day, tab$mobile, FUN=mode)
tab$day<-NULL
tab<-unique(tab)

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
           ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
           inner join temptab t on
           t.mobile = f.mobile
           set f.comday1 = t.comday1')

#removefrom r
rm(tab)