#Loading of library 
library(DBI)
library(RMySQL)
library(data.table)
lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
drv=dbDriver("MySQL")
con=dbConnect(drv,user="root",dbname="me_n_moms",password="ntrvpamaspr",host="localhost",port=3306)
