#getdata
tab<-dbGetQuery(con,statement='SELECT mobile, day(dt) as day, dt
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
#functions
tab<-unique(tab)
tab$dt<-NULL
mode <- function(x) names(table(x))[ which.max(table(x)) ]
tab$comday1 <- ave(tab$day, tab$mobile, FUN=mode)
tab$day<-NULL
tab<-unique(tab)
tab$freqweek1<-NA
tab$freqweek1<-with(tab, ifelse((as.numeric(comday1) < as.numeric(8)),1,ifelse(as.numeric(comday1)<as.numeric(16),2,ifelse(as.numeric(comday1)<as.numeric(24),3,4))))

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
           ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
           inner join temptab t on
           t.mobile = f.mobile
           set f.freqweek1 = t.freqweek1')

#removefrom r
rm(tab)
rm(mode)