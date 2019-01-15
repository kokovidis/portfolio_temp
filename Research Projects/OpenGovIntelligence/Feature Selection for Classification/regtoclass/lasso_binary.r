#TURNING A REGRESSION PROBLEM INTO LOGISTIC

#we merge the house prices mean of 2011 & 2012

MEAN_UP_DOWN <- merge(x = MEAN, y = MEAN2011, by = "Area.Name", all = TRUE)



#we compare the mean prices of two years (2011 -  2012),
# if the price in the second year rises for a given area, then will be marked as "UP"
#by this we create a model that predicts if the prices will go up or down for a given year.

MEAN_UP_DOWN$move <- ifelse(MEAN_UP_DOWN$house_prices_mean_2011 < MEAN_UP_DOWN$House.Prices..Reference.Period...2012..measure.type...Mean, "UP", "DOWN")
MEAN_UP_DOWN$binary <- ifelse(MEAN_UP_DOWN$move == "UP", 1 , 0 )
dataset_prices_moves <- merge(x = dataset_full_2009_2012_ratio, y = MEAN_UP_DOWN, by = "Area.Name", all = TRUE)
        #we remove the columns with prices and we keep only the last column, "bin"
        dataset_prices_moves[,c(452,453,454,455)] <- NULL
#we keep the dataset_prices_moves dataframe and we create a copy of it.
#With this way will keep the area names and all the NA in the first dataframe, in case we want to combine it with other datasets

dataset <- dataset_prices_moves


#and now we remove all the observations with NA from the dataset dataframe

dataset <- data.frame(dataset)
dataset$Area.Name<- NULL
dataset=na.omit(dataset)




#################################
library(glmnet)
library(caret)

#set seed number
SNUM=1
set.seed(SNUM)

#set number of folds for Shrinkage methods
NFOLDS=5

#variable count
NUM<- ncol(dataset)-2
#create an expression of response-predictor - in case of all use dot (.)
EXP =  cat1 ~ .
RES = dataset$cat
  #MATRIX TO STORE OUR PLOTS
  par(mfrow=c(2,1))


    #BLOCK 1
          #DATA - LAMBDA MODIFICATIONS
          #EXTENDED LAMBDA VALUES
          grid=10^seq(10,-2,length=100)

          #DATA PREPARATION
          #assign x & y
          x= model.matrix(as.formula(EXP) ,dataset)[,-1]
          y= dataset[,ncol(dataset)]
            # CV - DATA PREPARATION
            train=sample(c(TRUE,FALSE), nrow(x) , TRUE, prob=c(0.75,0.25))
            test=(!train)
            y.test=y[test]

    #BLOCK 2
          #CV ON TRAIN DATA - MSE ESTIMATION
          range=10^seq(-1,-3,length=100)
          lasso.mod=glmnet(x[train ,],y[train],alpha=1,lambda=range , family="binomial")
          plot(lasso.mod, xvar="lambda", label=TRUE, ,main="Lambda-Coefficients plot - TRAIN DATA")

          set.seed (SNUM)
          cv.out=cv.glmnet(x[train ,], y[train],alpha=1, , nfolds=NFOLDS, family = "binomial", type.measure="class")
          plot(cv.out, main="Lambda - MSE Error - TRAIN DATA")

        #BLOCK 2.1
              # LOWEST MSE
              bestlam=cv.out$lambda.min
              bestlam
              lasso.pred=predict(lasso.mod,s=bestlam ,newx=x[test,], type="class")

              confusionMatrix(lasso.pred, y.test)
              
              #coeff for every variable
              out=glmnet(x,y,alpha=1,lambda=grid)
              lasso.coef.lmse=predict(out,type="coefficients",s=bestlam)[1:NUM+2,]

              #exclude all zero coeff variables
              lasso.coef.lmse[lasso.coef.lmse!=0]


          #BLOCK 2.2
              #ONE STANDARD ERROR RULE
              oneselam=cv.out$lambda.1se
              oneselam
              lasso.pred=predict(lasso.mod,s=oneselam ,newx=x[test,], type="class")
              
              confusionMatrix(lasso.pred, y.test)
              
              #coeff for every variable
              out=glmnet(x,y,alpha=1,lambda=grid)
              lasso.coef.1se=predict(out,type="coefficients",s=oneselam)[1:NUM+2,]

         
          #Coeeficients for 1 st error rule
          lasso.coef.1se[lasso.coef.1se!=0]
