#getdata
days<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, dt
                  FROM sku_data
                where mobile is not null and qty>0 and DEPARTMENT is not null')
data<-dbGetQuery(con,statement='SELECT mobile,comday1
                  FROM final where comitem1 is not null')

#functions
tab<-merge(x=days, y=data, by = "mobile", all=TRUE)
tab<-unique(tab)
tab = tab[tab$comday1!=tab$day,]
tab$comday1<-NULL
tab$dt<-NULL

mode <- function(x) names(table(x))[ which.max(table(x)) ]
tab$comday2 <- ave(tab$day, tab$mobile, FUN=mode)
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
           set f.comday2 = t.comday2')

#removefrom r
rm(tab)
rm(days)
rm(data)