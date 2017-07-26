#getdata
data<-dbGetQuery(con,statement='Select mobile,comitem1 from final where comitem1 is not null')
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name, DATEDIFF(curdate(),Dt) as datediff
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab1<-merge(x = data, y = mocat, by = "mobile", all=TRUE)
tab1 = tab1[tab1$comitem1==tab1$name,]
tab1<-data.table(tab1)
tab<-tab1
tab$name<-NULL
tab$comitem1<-NULL
taba<-tab[,.(comitemfb1 = max(datediff)),by=mobile]
tabb<-tab[,.(comitemlb1 = min(datediff)),by=mobile]
tab<-merge(x=taba, y=tabb, by = "mobile", all=TRUE)
tab1<-unique(tab1)
tab1<-data.frame(table(tab1$mobile))
names(tab1) <- c("mobile","nocomitemtra1")
tab<-merge(x=tab, y=tab1, by = "mobile", all=TRUE)
tab$comitemfreq1<-NA
tab$comitemfreq1<-with(tab,(tab$comitemfb-tab$comitemlb)/(tab$nocomitemtra1-1))

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitemfb1 = t.comitemfb1 , f.comitemlb1 = t.comitemlb1 , f.nocomitemtra1 = t.nocomitemtra1 , f.comitemfreq1 = t.comitemfreq1') 

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(tab1)
rm(taba)
rm(tabb)