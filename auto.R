library(readr)
library(rpart)
library(ROCR)
library(gplots)
library(rpart.plot)
library(stringr)

autodf <- read.csv("~/Hult International Business School/DS_R/Auto/auto_mpg.csv", header = TRUE)

#Rename some  col names
colnames(autodf)[1] <- "mpg"
colnames(autodf)[8] <- "origin"


#Replace NA with (blank)
autodf$mpg <- gsub("NA", "", autodf$mpg)

#Checking missing values
is.na(autodf)
sum(is.na(autodf))
mean(is.na(autodf))
which(is.na(autodf), arr.ind=TRUE)

#Removing missing values
autodf <- na.omit(autodf)

#Calculating total displacement(volume in CC) and adding litres of engine
autodf$displacement <- autodf$cylinders * autodf$displacement

############################################################################
########################DONT RUN THIS MORE THAN ONCE########################
############################################################################
# Converting to litres                                                     #
autodf$litres <- autodf$displacement / 1000                                #
#Moving litres to index 4 - DONT RUN THIS MORE THAN ONCE                   #
autodf <- autodf[, colnames(autodf)[c(1:3, 10, 4:9)]]                      #
                                                                           #
#Convert weight from pound to kg - DONT RUN THIS MORE THAN ONCE            #
#autodf$weight <- autodf$weight * 0.45359237                               #
                                                                           #
#Change year 1970 to year 0 - DONT RUN THIS MORE THAN ONCE                 #
autodf$model_year <- autodf$model_year - 70                                #
############################################################################
############################################################################
############################################################################

autodf$mpg <- as.numeric(autodf$mpg)

mean(autodf$mpg, na.rm = TRUE)
median(autodf$mpg, na.rm = TRUE)



# Replacing mpg with 1 or 0 - Above 23 is 1
autodf$mpg_good <- c()

for(i in 1:nrow(autodf)){
  if(autodf$mpg[i] >= 23){
    autodf$mpg_good[i] <- 1
  }
  else if(autodf$mpg[i] < 23){
    autodf$mpg_good[i] <- 0
  }
  else{
    print("Error")
  }
}


mpg_logit <- glm(mpg_good ~ cylinders + displacement + horsepower + weight + acceleration + model_year + origin, data = autodf, family = "binomial")
summary(mpg_logit)

mpg_logit <- glm(mpg_good ~ cylinders + displacement + horsepower + weight + model_year + origin, data = autodf, family = "binomial")
summary(mpg_logit)

mpg_logit <- glm(mpg_good ~ cylinders + horsepower + weight + model_year + origin, data = autodf, family = "binomial")
summary(mpg_logit)

mpg_logit <- glm(mpg_good ~  horsepower + weight + model_year + origin, data = autodf, family = "binomial")
summary(mpg_logit)


mpg_tree <- rpart(mpg_good ~  horsepower + weight + model_year + origin, data = autodf, method="class", cp = 0.01)
rpart.plot::rpart.plot(mpg_tree, type = 1, extra=1, box.palette =c("pink", "green"), branch.lty=3, shadow.col = "gray")

plotcp(mpg_tree)





pred_tree <- predict(mpg_tree, autodf, type = "prob")
pred_logit <- predict(mpg_logit, autodf, type = "response") # Predict probability of 1

pred_val_t <- prediction(pred_tree[,2], autodf$mpg_good)
pred_val_logi <- prediction(pred_logit, autodf$mpg_good)

perf_t <- performance(pred_val_t, "tpr", "fpr")
perf_logi <- performance(pred_val_logi, "tpr", "fpr")

plot(perf_t, lwd=2,col = "black")
plot(perf_logi, lwd=3,col = "red", add= TRUE)




exp(0.0005889)-1 #According to the logistic regression, the weight of a car is statistically significant to tell if the car is a station wagon or not.
exp(-0.2406578)-1 # The same goes with model year. Throughout the period between 

#Creating function to calculate mpg based on data
mpg <- function(dis, hp, w, year, or){
  mpg1 <- 37.5878712 + 0.0018855*dis - 0.0315836*hp - 0.0147049*w + 0.7559688*(year-1970) + 1.3781806*or
  return(mpg1)
}

mpg(2456, 130, 	1589.3877, 1970, 1)


mean((autodf$mpg))
