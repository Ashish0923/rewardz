#getdata
data<-dbGetQuery(con,statement='Select mobile,comitem2 from final where comitem2 is not null')
mocat<-dbGetQuery(con,statement='SELECT mobile,sub_category as name, DATEDIFF(curdate(),Dt) as datediff
                  FROM sku_data
                  where mobile is not null and qty>0 and DEPARTMENT is not null')

#functions
tab1<-merge(x = data, y = mocat, by = "mobile", all.x=TRUE)
tab1 = tab1[tab1$comitem2==tab1$name,]
tab1<-data.table(tab1)
tab<-tab1
tab$name<-NULL
tab$comitem2<-NULL
taba<-tab[,.(comitemfb2 = max(datediff)),by=mobile]
tabb<-tab[,.(comitemlb2 = min(datediff)),by=mobile]
tab<-merge(x=taba, y=tabb, by = "mobile", all=TRUE)
tab1<-unique(tab1)
tab1<-data.frame(table(tab1$mobile))
names(tab1) <- c("mobile","nocomitemtra2")
tab<-merge(x=tab, y=tab1, by = "mobile", all=TRUE)
tab$comitemfreq2<-NA
tab$comitemfreq2<-with(tab,(tab$comitemfb2-tab$comitemlb2)/(tab$nocomitemtra2-1))

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.comitemfb2 = t.comitemfb2 , f.comitemlb2 = t.comitemlb2 , f.nocomitemtra2 = t.nocomitemtra2 , f.comitemfreq2 = t.comitemfreq2') 

#removefrom r
rm(tab)
rm(mocat)
rm(data)
rm(tab1)
rm(taba)
rm(tabb)