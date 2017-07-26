#getdata
tab<-dbGetQuery(con,statement='SELECT mobile, dayname(dt) as day, DATEDIFF(curdate(),dt) as days
                  FROM sku_data
                where mobile is not null and qty>0 and DEPARTMENT is not null')

data<-dbGetQuery(con,statement='SELECT mobile, noweekdaytrans
                 FROM final
                 where noweekdaytrans is not null')
#functions
tab<-unique(tab)
tab = tab[tab$day!='Saturday',]
tab = tab[tab$day!='Sunday',]
tab$day<-NULL
tab<-data.table(tab)
taba<-tab[,.(weekdayfb = max(days)),by=mobile]
tabb<-tab[,.(weekdaylb = min(days)),by=mobile]
tab<-merge(x=taba, y=tabb, by = "mobile", all=TRUE)
tab<-merge(x=tab, y=data, by = "mobile", all=TRUE)
tab$weekdayfreq<-NA
tab$weekdayfreq<-with(tab,(tab$weekdayfb-tab$weekdaylb)/(tab$noweekdaytra-1))
tab$noweekdaytrans<-NULL

#write table to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.weekdayfb = t.weekdayfb , f.weekdaylb = t.weekdaylb , f.weekdayfreq = t.weekdayfreq') 

#removefrom r
rm(tab)
rm(data)
rm(taba)
rm(tabb)
