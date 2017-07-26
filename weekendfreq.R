#getdata
tab<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, DATEDIFF(curdate(),dt) as days
                  FROM sku_data
                where mobile is not null and qty>0 and DEPARTMENT is not null')

data<-dbGetQuery(con,statement='SELECT mobile, noweekendtrans
                  FROM final
                where noweekendtrans is not null')
#functions
tab<-unique(tab)
tab = tab[tab$day!='Monday',]
tab = tab[tab$day!='Tuesday',]
tab = tab[tab$day!='Wednesday',]
tab = tab[tab$day!='Thursday',]
tab = tab[tab$day!='Friday',]
tab$day<-NULL
tab<-data.table(tab)
taba<-tab[,.(weekendfb = max(days)),by=mobile]
tabb<-tab[,.(weekendlb = min(days)),by=mobile]
tab<-merge(x=taba, y=tabb, by = "mobile", all=TRUE)
tab<-merge(x=tab, y=data, by = "mobile", all=TRUE)
tab$weekendfreq<-NA
tab$weekendfreq<-with(tab,(tab$weekendfb-tab$weekendlb)/(tab$noweekendtra-1))
tab$noweekendtrans<-NULL

#write table to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.weekendfb = t.weekendfb , f.weekendlb = t.weekendlb , f.weekendfreq = t.weekendfreq') 

#removefrom r
rm(tab)
rm(data)
rm(taba)
rm(tabb)
