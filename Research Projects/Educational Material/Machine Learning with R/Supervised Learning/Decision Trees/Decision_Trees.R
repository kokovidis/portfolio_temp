# Decision Trees

dataset$cat1 <- as.factor(ifelse(dataset$urbanclass == 1 , 1, 0))
dataset$cat2 <- as.factor(ifelse(dataset$urbanclass == 2 , 1, 0))
dataset$cat3 <- as.factor(ifelse(dataset$urbanclass == 3 , 1, 0))
dataset$cat4 <- as.factor(ifelse(dataset$urbanclass == 4 , 1, 0))
dataset$cat5 <- as.factor(ifelse(dataset$urbanclass == 5 , 1, 0))
dataset$cat6 <- as.factor(ifelse(dataset$urbanclass == 6 , 1, 0))

# Fitting Classification Trees

library(tree)
library(ISLR)
attach(dataset)

dataset <- dataset_tree

par(mfrow=c(1,2))

tree.cat1=tree(cat1 ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011, dataset)
summary(tree.cat1)
plot(tree.cat1)
text(tree.cat1,pretty=0)
title("Category 1 for full dataset")

###########
set.seed(1)
train_assign <- sample(c(TRUE,FALSE), nrow(dataset) , TRUE, prob=c(0.75,0.25))
train.subset <- data.frame(dataset[train_assign, ])  
test.subset <- data.frame(dataset[!train_assign, ])

tree.cat1=tree(cat1 ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011 , train.subset)
plot(tree.cat1)
text(tree.cat1,pretty=0)
title("Category 1 for train subset 75%")
tree.pred=predict(tree.cat1,test.subset, type="class")
res_table <- table(tree.pred,test.subset$cat1)
res_table
(res_table[1,1]+res_table[2,2])/nrow(test.subset)
nrow(test.subset)

set.seed(1)
cv.cat1 = cv.tree(tree.cat1,FUN=prune.misclass)
cv.cat1

par(mfrow=c(1,2))
plot(cv.cat1$size,cv.cat1$dev,type="b")
plot(cv.cat1$k,cv.cat1$dev,type="b")


#two node
prune.cat1=prune.misclass(tree.cat1,best=2)
plot(prune.cat1)
text(prune.cat1,pretty=0)
title("Category 1 tree - pruned; size:2")
tree.pred=predict(prune.cat1,test.subset,type="class")
res_table <- table(tree.pred,test.subset$cat1)
res_table
(res_table[1,1]+res_table[2,2])/nrow(test.subset)
nrow(test.subset)

#three node
prune.cat1=prune.misclass(tree.cat1,best=3)
plot(prune.cat1)
text(prune.cat1,pretty=0)
title("Category 1 tree - pruned; size:3")
tree.pred=predict(prune.cat1,test.subset,type="class")
res_table <- table(tree.pred,test.subset$cat1)
res_table
(res_table[1,1]+res_table[2,2])/nrow(test.subset)
nrow(test.subset)

# Fitting Regression Trees

#data cleansing
dataset <- na.omit(dataset)

tree.prices=tree(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011, data=dataset)
summary(tree.prices)
plot(tree.prices)
text(tree.prices,pretty=0)
title("house prices mean")



#splitting 

set.seed(1)
train_assign <- sample(c(TRUE,FALSE), nrow(dataset) , TRUE, prob=c(0.75,0.25))
train.subset <- dataset[train_assign, ]
test.subset <-  dataset[!train_assign, ]
prices.test <- dataset[!train_assign,"house_prices_mean"]

tree.prices=tree(house_prices_mean ~  immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011 , data=dataset, subset=train_assign)
pred=predict(tree.prices, newdata=test.subset)
sqrt(mean((pred - prices.test)^2))
plot(pred, prices.test)
abline(0,1)

#CV for regression (not mentioned in the slides)
cv.prices=cv.tree(tree.prices)
plot(cv.prices$size,cv.prices$dev,type='b')

prune.prices=prune.tree(tree.prices,best=3)
pred=predict(prune.prices, newdata=test.subset)
sqrt(mean((pred - test.subset$house_prices_mean)^2))
plot(pred,prices.test)
abline(0,1)      


# Bagging and Random Forests

library(randomForest)
par(mfrow=c(1,2))


#Baggging mtry=p
bag.prices=randomForest(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011,data=dataset, subset=train_assign, mtry=6)
bag.prices
plot(bag.prices)
pred.bag = predict(bag.prices,newdata=test.subset)
plot(pred.bag, prices.test, pch=8, cex=.3)
abline(0,1)
sqrt(mean((pred.bag-prices.test)^2))

#Random Forest with m=sqrt(p)
#sqrt(6) = 2.444, so mtry=2 (if omitted) / with ntree=200 (default=500)
ran.prices=randomForest(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011,data=dataset,subset=train_assign, ntree=200, importance=TRUE)
pred.ran = predict(ran.prices,newdata=test.subset)
sqrt(mean((pred.ran-prices.test)^2))
importance(ran.prices)
varImpPlot(ran.prices)

set.seed(1)
#mtry=1 
ran1.prices=randomForest(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011,data=dataset,subset=train_assign, mtry=1, ntree=200, importance=TRUE)
pred.ran1 = predict(ran1.prices,newdata=test.subset)
sqrt(mean((pred.ran1-prices.test)^2))
varImpPlot(ran1.prices)

# Boosting
library(gbm)

set.seed(1)
train_assign <- sample(c(TRUE,FALSE), nrow(dataset) , TRUE, prob=c(0.75,0.25))
train.subset <- dataset[train_assign, ]
test.subset <-  dataset[!train_assign, ]
prices.test <- dataset[!train_assign,"house_prices_mean"]

set.seed(1)
boost.prices=gbm(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011,data=train.subset,distribution="gaussian",n.trees=5000, interaction.depth=4)
summary.gbm(boost.prices)
pred.boost=predict(boost.prices,newdata=test.subset,n.trees=5000)
sqrt(mean((pred.boost-test.subset$house_prices_mean)^2))
plot(boost.prices,i=5)

#lambda=0.020λ
set.seed(1)
boost.prices=gbm(house_prices_mean ~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011,data=train.subset,distribution="gaussian",n.trees=5000,interaction.depth=3, shrinkage = 0.020)
summary.gbm(boost.prices)
pred.boost=predict(boost.prices,newdata=test.subset,n.trees=5000)
sqrt(mean((pred.boost-test.subset$house_prices_mean)^2))

#classification - WITH CARET
install.packages('caret', dependencies = TRUE)
library(caret)

set.seed(1)
fitControl = trainControl(method="cv", number=10, returnResamp = "all")
model.caret = train(cat1~ immun2011+ dwellroom12012+ dwellterraced2012 + breast_2012 + dis2012 + jobs2011, data=train.subset, method="gbm",distribution="bernoulli", trControl=fitControl, verbose=F, tuneGrid=data.frame(.n.trees=2000, .shrinkage=0.01, .interaction.depth=6, .n.minobsinnode=1))

mPred = predict(model.caret, test.subset, type="class")  ####cccc
#postResample(mPred, test.subset$cat1)
confusionMatrix(mPred, test.subset$cat1)

