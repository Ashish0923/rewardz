#getdata
days<-dbGetQuery(con,statement='SELECT mobile, day(dt) as day, dt
                  FROM sku_data
                 where mobile is not null and qty>0 and DEPARTMENT is not null')
data<-dbGetQuery(con,statement='SELECT mobile, freqweek1
                 FROM final
                 where freqweek1 is not null')
#functions
days<-unique(days)
days$dt<-NULL
days$week<-NA
days$week<-with(days, ifelse((as.numeric(day) < as.numeric(8)),1,ifelse(as.numeric(day)<as.numeric(16),2,ifelse(as.numeric(day)<as.numeric(24),3,4))))
days$day<-NULL
tab<-merge(x = data, y = days, by = "mobile", all=TRUE)
tab = tab[tab$freqweek1==tab$week,]
tab<-data.table(tab)

tab<-data.frame(table(tab$mobile))
names(tab) <- c("mobile","nofreqweek1trans")

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
           ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
           inner join temptab t on
           t.mobile = f.mobile
           set f.nofreqweek1trans = t.nofreqweek1trans')

#removefrom r
rm(tab)
rm(data)
rm(days)