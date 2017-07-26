#getdata
days<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, dt
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')
data1<-dbGetQuery(con,statement='SELECT mobile,comday1
                 FROM final where comday1 is not null')
data2<-dbGetQuery(con,statement='SELECT mobile,comday2
                 FROM final where comday2 is not null')

#functions
tab1<-merge(x=days, y=data1, by = "mobile", all=TRUE)
tab1<-unique(tab1)
tab1 = tab1[tab1$comday1!=tab1$day,]
tab1$comday1<-NULL
tab1$dt<-NULL

tab2<-merge(x=tab1, y=data2, by = "mobile", all=TRUE)
tab2 = tab2[tab2$comday2!=tab2$day,]
tab2$comday2<-NULL
tab<-tab2

mode <- function(x) names(table(x))[ which.max(table(x)) ]
tab$comday3 <- ave(tab$day, tab$mobile, FUN=mode)
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
           set f.comday3 = t.comday3')

#removefrom r
rm(tab)
rm(days)
rm(data1)
rm(data2)
rm(tab1)
rm(tab2)