

#fit a gam with splines contain their best df
library(gam)
  temp_shrinked_split <- na.omit(shrinked_dataset)
  nrow(temp_shrinked_split)
  
  train_assign <- sample(c(TRUE,FALSE), nrow(temp_shrinked_split) , TRUE, prob=c(0.90,0.10))
  train.subset <- data.frame(temp_shrinked_split[train_assign, ])  
  test.subset <- data.frame(temp_shrinked_split[!train_assign, ] )
  testx <- test.subset[,-46]
  
  
  #BEST DF
  #find the best df for every predictor
  df45 <- rep(0,45)
  for(i in 1:45) {
    temp <- smooth.spline((train.subset)[,i],train.subset$house_prices_mean,cv=TRUE)
    df45[i] <- round(temp$df , digits=2)
  }
  
  #assign df=3 for zero values
  for (i in 1:45) {
    if(df45[i]==0) {
    df45[i] = 3
    }
  }
  
  #structure syntax and gam fit
  xnam <- paste("s(",colnames(train.subset)[-46], ",df=",df45[-46],")" )
  fmla <- as.formula(paste("house_prices_mean ~ ", paste(xnam, collapse= "+")))
  gam.big=gam(fmla, data=train.subset , CV=TRUE)

  preds=predict(gam.big, testx)
  sqrt(mean((test.subset$house_prices_mean - preds)^2))
  par(mfrow=c(7,7))
  par(mar=c(1,1,1,1))
  plot.gam(gam.big)