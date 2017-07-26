#getdata
tab<-dbGetQuery(con,statement='SELECT mobile,(enrolledsince-recency)/(no_trans-1) as frequency FROM final where no_trans > 1 ')

#function

#write table to sql
dbWriteTable(con,"temptab",tab,overwrite=T)
dbGetQuery(con,statement='ALTER TABLE temptab
ADD PRIMARY KEY (mobile(15))')

#alter final
dbGetQuery(con,statement='update final f
inner join temptab t on
t.mobile = f.mobile
set f.frequency = t.frequency')

#removefrom r
rm(tab)