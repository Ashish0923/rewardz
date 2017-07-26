library(DBI)
library(RMySQL)
library(data.table)

lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)

drv=dbDriver("MySQL")
con=dbConnect(drv,user="root",dbname="test",password="lappy",host="localhost",port=3306)