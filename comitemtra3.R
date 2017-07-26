#getdata
data<-dbGetQuery(con,statement='Select mobile,comitem3 from final where comitem3 is not null')
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name, DATEDIFF(curdate(),Dt) as datediff
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab1<-merge(x = data, y = mocat, by = "mobile", all.x=TRUE)
tab1 = tab1[tab1$comitem3==tab1$name,]
tab1<-data.table(tab1)
tab<-tab1
tab$name<-NULL
tab$comitem3<-NULL
taba<-tab[,.(comitemfb3 = max(datediff)),by=mobile]
tabb<-tab[,.(comitemlb3 = min(datediff)),by=mobile]
tab<-merge(x=taba, y=tabb, by = "mobile", all=TRUE)
tab1<-unique(tab1)
tab1<-data.frame(table(tab1$mobile))
names(tab1) <- c("mobile","nocomitemtra3")
tab<-merge(x=tab, y=tab1, by = "mobile", all=TRUE)
tab$comitemfreq3<-NA
tab$comitemfreq3<-with(tab,(tab$comitemfb3-tab$comitemlb3)/(tab$nocomitemtra3-1))

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitemfb3 = t.comitemfb3 , f.comitemlb3 = t.comitemlb3 , f.nocomitemtra3 = t.nocomitemtra3 , f.comitemfreq3 = t.comitemfreq3') 

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(tab1)
rm(taba)
rm(tabb)
