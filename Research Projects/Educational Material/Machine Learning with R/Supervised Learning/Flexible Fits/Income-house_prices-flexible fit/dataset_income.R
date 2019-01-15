library(splines)

dataset <- dataset_income
attach(dataset)

fit=smooth.spline(dataset$fbu_less_800gbp, dataset$house_prices_mean, df=25)
fit2=smooth.spline(dataset$fbu_less_800gbp, dataset$house_prices_mean, cv=TRUE)
plot(fbu_less_800gbp,house_prices_mean,cex=.5,col="darkgrey",  xlim=c(0,100))
title("Smoothing Spline")
fit2$df
lines(fit,col="red",lwd=2)
lines(fit2,col="blue",lwd=2)
df <- round(fit2$df, digits=4)
df <- as.character(df)
df <- paste("CV", df, "DF", collapse = "")
legend("topright",legend=c("25 DF", df ),col=c("red","blue"),lty=1,lwd=2,cex=.8)


train_assign <- sample(c(TRUE,FALSE), nrow(dataset) , TRUE, prob=c(0.75,0.25))
train.subset <- data.frame(dataset[train_assign, ])  
test.subset <- data.frame(dataset[!train_assign, ] )
prices.test=dataset[!train_assign,"house_prices_mean"]

testx <- test.subset[,-46]


data.store <- data.frame(test.subset)
for (i in 1:nrow(test.subset)){
  temp <- predict(fit2, c(test.subset$fbu_less_800gbp[i]))
  data.store$prediction[i] <- temp$y
}
sqrt(mean((data.store$house_prices_mean-data.store$prediction)^2))

dataset_income <- dataset

