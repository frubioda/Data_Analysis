# R code to read  pre-test data provided by a video game company
# The company used a SQLite database
#----------------------------------------------------------------------------------------

require(RSQLite)
require(sqldf)
require(MASS)
require(plotrix)

db <- dbConnect(SQLite(),dbname="./tasks.sqlite") #Open a connection to the database

cat("The database has 3 tables: \n") #Print names of the tables into the databases
cat(dbListTables(db),"\n") #names of tables

#Print fields/attributes for each table
for(i in dbListTables(db)){
  cat("For table",i," the fields are: \n")
  print(dbListFields(db,i))
  cat("\n")
}

#Q1: How much revenue was produced on 2013/02/01? 159.64 
#-----------------------------------------------------------------------------------------
res <- dbSendQuery(conn=db,"SELECT sum(cash_amount) FROM transactions WHERE created_time BETWEEN '2013-02-01 00:00:00' AND '2013-02-01 23:59:59.999';")
data <- fetch(res)
cat("Total revenues for 2013/02/01:",data[[1]],"\n")
dbClearResult(res)

#Q2: Which country produces the most revenues? US
#-----------------------------------------------------------------------------------------
res <- dbSendQuery(conn=db,"SELECT account.create_country,sum(cash_amount) FROM account, transactions WHERE account.account_id=transactions.account_id
                   GROUP BY account.create_country ORDER BY sum(cash_amount) DESC;")
data <- fetch(res)
cat("The country producing the most revenues is:",data[[1]][1],"\n")
dbClearResult(res)

#Q3: What is the iPad/iPhone split in Great Britain? 455 iPads, and: 519 iPhones 
#-----------------------------------------------------------------------------------------
res <- dbSendQuery(conn=db,"SELECT count(B.device) FROM account AS A, account_device AS B WHERE 
                   A.account_id = B.account_id AND A.create_country = 'GB' AND B.device LIKE '%iPhone%';")
data1 <- fetch(res)
dbClearResult(res)
res <- dbSendQuery(conn=db,"SELECT count(B.device) FROM account AS A, account_device AS B WHERE 
                   A.account_id = B.account_id AND A.create_country = 'GB' AND B.device LIKE '%iPad%';")
data2 <- fetch(res)
dbClearResult(res)
cat("iPad/iPhone splits in the UK as:",data2[[1]],"iPads, and:",data1[[1]],"iPhones \n")

#Q5: What proportion of lifetime revenue is generated on the player's first week in game? 74.40579 percent
#-----------------------------------------------------------------------------------------
res <- dbSendQuery(conn=db,"WITH AA AS (SELECT A.account_id AS id,A.created_date, sum(B.cash_amount) AS cash FROM account AS A, transactions
                   AS B WHERE A.account_id = B.account_id GROUP BY A.account_id),  BB AS (SELECT A.account_id AS id,A.created_date,
                   sum(B.cash_amount) AS cash FROM account AS A, transactions AS B WHERE A.account_id = B.account_id AND
                   julianday(B.created_time) <= julianday(A.created_date) + 7 GROUP BY A.account_id) SELECT avg(BB.cash/AA.cash)
                   FROM AA,BB WHERE AA.id=BB.id;")
data <- fetch(res)
cat("The proportion of lifetime revenue generated during the first week is:",data[[1]]*100.,"percent\n")
dbClearResult(res)


#Q6: Visualization of the geographic repartition of the players. Pie chart (only countries with count >10% of maximum count)
#-----------------------------------------------------------------------------------------
res <- sqldf("SELECT create_country, count(create_country) AS country_count FROM account GROUP BY create_country;",dbname="./tasks.sqlite")
thresh <- c(0.1)
selected <- res$country_count >= max(res$country_count)*thresh
rejected <- res$country_count < max(res$country_count)*thresh
country_count <- c(res$country_count[selected],sum(res$country_count[rejected]))
labels <- c(res$create_country[selected],"Other")
perct  <- round(country_count/sum(country_count)*100)
labels <- paste(labels,perct)
labels <- paste(labels,"%",sep="")

png('./chart_countries.png',width=4,height=4.5,units="in",res=300)
pie3D(country_count,labels=labels,labelcex=0.5,col=rainbow(length(labels)),explode=0.1,main="Player's country of origin",cex.main=0.8)
dev.off()

#Q7: distribution of in-app purchases as a function of time since user created the profile
#-----------------------------------------------------------------------------------------
res <- sqldf("SELECT A.account_id, A.created_date,julianday(B.created_time)-julianday(A.created_date) AS days_elapsed,B.cash_amount
             FROM account AS A, transactions AS B WHERE A.account_id=B.account_id ORDER BY A.account_id;",dbname="./tasks.sqlite") #join tables and import result as R data frame

png('./hist_purchased_apps.png',width=4,height=5,units="in",res=300)
y <- hist(res$days_elapsed,freq=FALSE,breaks=100,main='Probability density \n days when purchase occurred',col='lightblue',
        xlab="Days since the user profile was created",cex.main=0.8)$density
x <- seq(0.5,length(y)-0.5,1.0) #use the mid-point of the bin
df <- data.frame(x,y)

#Non-linear regression with power law (it is easier to take # log(x) and then do linear regression)
z <- lm(y~log(x))
lines(x,z$fitted,col="darkblue",lwd=3)
SS<-sum((z$fitted-y)^2)

#Use fitdistr() function of the MASS package to fit a lognormal distribution:
z<-fitdistr(res$days_elapsed,densfun="lognormal")$estimate
y2<-dlnorm(x,meanlog=z[1],sdlog=z[2])
lines(x,y2,lwd=2,col="red")
SS2<-sum((y2-y)^2)

legend("topright",c("power-law","lognormal"),fill=c("darkblue","red"))

cat("\nGoodness of the two regressions (sums-of-squares): \n")
cat(SS,SS2,"\n")

dev.off()

#Q8: Involvement of the player (in terms of number of game sessions) and amount of money he/she spends on the game
#i.e.: is involvement a good predictor of spending?
#-----------------------------------------------------------------------------------------
res <- sqldf("SELECT max(session_count) AS max_sessions, sum(cash_amount) AS sum_amount, 
             min(cash_amount) AS min_amount FROM account NATURAL JOIN transactions 
             GROUP BY account_id;",dbname="./tasks.sqlite") #join tables and import result as R data frame

png('./corr_time_money_player.png',width=5,height=4,units="in",res=300)
plot(res$max_sessions,res$sum_amount,xlab="Number of sessions",pch=20,ylab="Total spending (USD)",
     col="darkblue",main="Total spending per user vs \n their number of game sessions",cex.main=0.8)
abline(lm(res$sum_amount ~ res$max_sessions),col="darkred",lwd=3)
print(cor(res$max_sessions,res$sum_amount))
text(3000,400,labels="corr=0.0994")
dev.off()

#Q9: potential relation before the time it takes for a player to invest and the total amount of money he/she spends on the game
#-----------------------------------------------------------------------------------------
res <- sqldf("SELECT account_id AS id, min(delay) AS delay, sum(cash_amount) AS cash FROM (SELECT 
             account_id,(julianday(created_time)-julianday(created_date)) AS delay,
             cash_amount FROM account NATURAL JOIN transactions) GROUP BY account_id ORDER BY account_id;"
             ,dbname="./tasks.sqlite")

png('./hist_first_total_invest.png',width=5,height=4,units="in",res=300)
plot(res$delay,res$cash,pch=20,xlab="days before conversion",ylab="Total spending (USD)",main="Total spending per user vs \n delay to conversion",col="darkred",cex.main=0.8)
print(cor.test(res$delay,res$cash, method="pearson"))
print(cor.test(res$delay,res$cash, method="spearman"))
dev.off()

res2 <- sqldf("SELECT account_id AS id, max(session_count) AS max_sessions, sum(cash_amount) AS cash FROM
             account NATURAL JOIN transactions GROUP BY account_id ORDER BY account_id;",dbname="./tasks.sqlite")

spending <- res$cash
spending[res$cash <=50] = 0
spending[res$cash >50] = 1
print(summary(glm(spending ~ res$delay + res2$max_sessions,family="binomial")))

#rm()
