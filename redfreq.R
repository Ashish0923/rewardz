#getdata
tab<-dbGetQuery(con,statement='SELECT mobile ,noredemptions, firstred, lastred
                 FROM final 
                 where noredemptions>1')
#functions
tab$redfreq<-NA
tab$redfreq<-(tab$firstred-tab$lastred)/(tab$noredemptions-1)
tab$noredemption<-NULL
tab$firstred<-NULL
tab$lastred<-NULL

#write tqble to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.redfreq = t.redfreq')

#removefrom r
rm(tab)