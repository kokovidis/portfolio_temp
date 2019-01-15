#TRANSFORMATIONS
################################################

#DATA CLEANSING FOR BIG DATASET
#combine datasets
dataset <-merge(x = dataset, y = MEAN, by = "Area.Name", all = TRUE)

#on the final test dataset
#dataset$`Area Name` <- NULL
dataset <- data.frame(dataset)
dataset$Area.Name<- NULL
dataset=na.omit(dataset)

colnames(dataset)[452] <- "house_prices_mean"
#rename the last column
colnames(dataset)[ncol(dataset)] <- "house_prices_mean"


#REALLY IMPORTANT TO TRANSFORM IT INTO DATA.FRAME
dataset = data.frame(dataset)

as.data.frame
dataset=na.omit(dataset)


#FIND N/A COLUMMNS
na.test <-  function (x) {
  w <- sapply(x, function(x)all(is.na(x)))
  if (any(w)) {
    stop(paste("All NA in columns", paste(which(w), collapse=", ")))
  }
}

na.test(dataset)


#loop delete multiple columns
for(i in 40:61) {
  dataset[40] <- NULL
}


#### make new dataset from a previous list (output from Lasso)
varnames <- names(dataset)
lassoselect<-names(lasso.coef.1se[lasso.coef.1se!=0])
shrinked_dataset<- dataset[ ,which(varnames %in% lassoselect | varnames == "Area.Name" | varnames == "house_prices_mean" )]

shrinked_dataset$Area.Name <- NULL
shrinked_dataset=na.omit(shrinked_dataset)

#loop seed - perform an experiment multiple times.
for(i in 1:100) {
  set.seed(i)
  
  frame[i,"X1"] <- sqrt(TestMseWithLambaOfOneStandardErrorTrainMse)
  frame[i,"X2"] <- sum(!lasso.coef.1se == 0)
  frame[i,"X3"] <- oneselam
}


#CALCULATE test MSE with percentage allocation on train and test 
train_assign <- sample(c(TRUE,FALSE), 6505, TRUE, prob=c(0.75,0.25))
test.subset <- dataset[!train_assign, ]
preds=predict(fit,newdata=dataset[train_assign])
mean((preds- (test.subset$house_prices_mean))^2)


#FIND TYPE OF VARIABLES IN A DATA frame
sapply(dataset,class)

#CONVERT EVERY COLUMN IN A DATA.FRAME CHARACTER TO NUMERIC TYPE
dataset<- lapply(dataset, function(x) as.numeric(as.character(x)))

#GET THE NAME OF THE LAST COLUMN IN A DATASET
colnames(dataset[ncol(dataset)])

#EXPORT DATA FRAME TO CSV
write.table(dataset_tree, file="export.csv", sep=",", row.names=FALSE)

