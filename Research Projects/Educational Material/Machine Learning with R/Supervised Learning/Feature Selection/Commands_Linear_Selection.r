#Libraries for R:
  library(sparql)
#subset selection
  library(leaps)
#shrinkage
  library(glmnet)
#Dimension Reduction
  library(pls)
#disable scientific notation
options(scipen=999)
#enable cientific notation
options(scipen=1)

#Before any attempt we will need to clear out rows that might missing values.

  sum(is.na(dataset))
  dataset=na.omit(dataset)

#Best_subset_selection
install.packages("leaps")
library(leaps)

  #For 5 pre-defined variables

    regfit.full=regsubsets(house_sales_prices_mean ~ ratio_dis_allow + count_house_sales + ratio_fires + count_breastf + count_births , dataset)
    summary(regfit.full)
    reg.summary=summary(regfit.full)
    reg.summary$rsq

    #plot RSS & Rsqr

    par(mfrow=c(2,2))
    plot(reg.summary$rss ,xlab="Number of Variables ",ylab="RSS",type="l")
    plot(reg.summary$adjr2 ,xlab="Number of Variables ", ylab="Adjusted RSq",type="l")

    #variable selection plot
    plot(regfit.full,scale="r2")

  #For all (11) variables
    #remove the character variable of the dataset:
    dataset <- subset( dataset, select = -area )

    regfit.full=regsubsets(house_sales_prices_mean ~ . , dataset, nvmax=11)

#Forward and Backward Stepwise Selection

  #forward with 5 predictors
  regfit.fwd=regsubsets(house_sales_prices_mean ~ ratio_dis_allow + count_house_sales + ratio_fires + count_breastf + count_births , dataset, method ="forward")

  #forward with all predictors
  regfit.fwd=regsubsets(house_sales_prices_mean ~ . , dataset, method ="forward")

  #summary
  summary(regfit.fwd)

  #variable selection plot
  plot(regfit.fwd, scale="r2")

  #backward all
  regfit.bwd=regsubsets(house_sales_prices_mean ~ . , dataset, method ="backward")

#Best Subset Selection Validation Set Approach
  #split train and test
  set.seed(1)
  train=sample(c(TRUE,FALSE), nrow(dataset),rep=TRUE)
  test =(! train )

  #regsubsets to train
  regfit.best=regsubsets(house_sales_prices_mean ~ . , dataset[train, ], nvmax=11)

  #matrix to store errors
  test.mat=model.matrix(house_sales_prices_mean ~ . , dataset[test, ], nvmax=11)

  #loop for validation approach
  coefi=1
  pred=1
  al.errors=1

  val.errors=rep(NA,5)
  for(i in 1:5) {
  coefi=coef(regfit.best,id=i)
  pred=test.mat[,names(coefi)]%*%coefi
  val.errors[i]=mean((dataset$"house_sales_prices_mean"[test]-pred)^2)}

  #get the MSEs the lowest & summary of selected predictors
  val.errors
  which.min(val.errors)
  coef(regfit.best ,3)

#THE FUNCTION FOR LOOP AS predict()
#---------------------------------------------------------#
#--------------------   WARNING !!!  ---------------------#
#---------------------------------------------------------#
# USE THIS FUNCTION ONLY FOR BEST SUBSET SELECTION-FORWARD-BACKWARD METHODS
# TO CONTINUE TO SHRINKAGE & DIMENSION REDUCTION METHODS YOU SHOULD NEED TO ENTER rm(predict) TO REMOVE THE FUNCTION

  #START OF COMMANDS
  predict=function(object,newdata,id,...){
  form=as.formula(object$call[[2]])
  mat=model.matrix(form,newdata)
  coefi=coef(object,id=id)
  xvars=names(coefi)
  mat[,xvars]%*%coefi
  }

#END OF COMMANDS


#Cross-Validation

  #spliting into k folds, and create matrix
  k=10
  set.seed(1)
  folds=sample(1:k,nrow(dataset),replace=TRUE)
  cv.errors=matrix(NA,k,11, dimnames=list(NULL, paste(1:11)))


  #the loop for cross-validation using our pre-created function predict()
  for(j in 1:k){
  best.fit=regsubsets(house_sales_prices_mean ~ . , data=dataset[folds!=j,] , nvmax=11)
  for(i in 1:11){pred=predict(best.fit, dataset[folds==j,], id=i)
  cv.errors[j,i]=mean( (dataset$house_sales_prices_mean [folds==j]-pred)^2)  }}


  #average-get-plot MSEs by number of variables
  mean.cv.errors=apply(cv.errors ,2,mean)
  mean.cv.errors
  par(mfrow=c(1,1))
  plot(mean.cv.errors, type="b")

  #find the lowest MSE, indicate it in the plot
  lMSE.sub.fwd<-which.min(mean.cv.errors)
  points(lMSE.sub.fwd,mean.cv.errors[lMSE.sub.fwd],col="red",cex=2,pch=20)

  #calculate again the best subset and select the best predictors
  reg.best=regsubsets(house_sales_prices_mean ~ . , data=dataset, nvmax=11)
  coef(reg.best,lMSE.sub.fwd)



#---------------------------------------------------------#
#--------------------   WARNING !!!  ---------------------#
#---------------------------------------------------------#
#TO CONTINUE TO SHRINKAGE WE WILL REMOVE OUR predict FUNCTION THAT WE HAVE CREATED

rm(predict)



#Shrinkage Methods
install.packages("glmnet")
library(glmnet)


  #assign x & y
  x=model.matrix(house_sales_prices_mean ~ . ,dataset)[,-1]
  y=dataset$house_sales_prices_mean

  #Ridge Regression
  library(glmnet)
  grid=10^seq(10,-2,length=100)
  ridge.mod=glmnet(x,y,alpha=0,lambda=grid)

  #coeff for the 50th lambda value:
  ridge.mod$lambda [50]
  coef(ridge.mod)[,50]

  # ridge - lambda - coefficients plot
  plot(ridge.mod, xvar="lambda", label=TRUE)

  # ridge- cross-valid
  set.seed (1)
  train=sample(1:nrow(x), nrow(x)/2)
  test=(-train)
  y.test=y[test]
  cv.out=cv.glmnet(x[train ,],y[train],alpha=0)
  plot(cv.out)


    #best lambda with its lowest test MSE
    bestlam=cv.out$lambda.min
    bestlam
    ridge.pred=predict(ridge.mod,s=bestlam ,newx=x[test,])
    mean((ridge.pred-y.test)^2)

    #one-standard-error-rule with its lowest test MSE
    oneselam=cv.out$lambda.1se
    oneselam
    ridge.pred=predict(ridge.mod,s=oneselam ,newx=x[test,])
    mean((ridge.pred-y.test)^2)

    #refitted ridge regression model
    out=glmnet(x,y, alpha=0)
    predict(out, type="coefficients", s=bestlam)[1:12,]

  # The Lasso

    #assign a range of lambda values into a grid
    grid=10^seq(10,-2,length=100)

  lasso.mod=glmnet(x[train ,],y[train],alpha=1,lambda=grid)
  plot(lasso.mod, xvar="lambda", label=TRUE)

  # The lasso - cross-valid -minimum MSE
  set.seed (1)
  cv.out=cv.glmnet(x[train ,],y[train],alpha=1)
  plot(cv.out)
  bestlam=cv.out$lambda.min
  bestlam
  lasso.pred=predict(lasso.mod,s=bestlam ,newx=x[test,])
  mean((lasso.pred-y.test)^2)

    #coeff for every variable
    out=glmnet(x,y,alpha=1,lambda=grid)
    lasso.coef=predict(out,type="coefficients",s=bestlam)[1:12,]
    lasso.coef

    #exclude all zero coeff variables
    lasso.coef[lasso.coef!=0]


    # The lasso - cross-valid - ONE STANDARD ERROR
    set.seed (1)
    cv.out=cv.glmnet(x[train ,],y[train],alpha=1)
    plot(cv.out)
    oneselam=cv.out$lambda.1se
    oneselam
    lasso.pred=predict(lasso.mod,s=oneselam ,newx=x[test,])
    mean((lasso.pred-y.test)^2)

      #coeff for every variable
      out=glmnet(x,y,alpha=1,lambda=grid)
      lasso.coef=predict(out,type="coefficients",s=oneselam)[1:12,]
      lasso.coef

      #exclude all zero coeff variables
      lasso.coef[lasso.coef!=0]

#Dimension Reduction Methods
library(pls)

  #Principal Componenets Regression
  set.seed(1)
  pcr.fit=pcr(house_sales_prices_mean ~ . , data=dataset, scale=TRUE, validation="CV" )
  summary(pcr.fit)
  validationplot(pcr.fit,val.type="MSEP")

  #PCR & Train Data
  set.seed(1)
  pcr.fit=pcr(house_sales_prices_mean ~ . , data=dataset, subset=train, scale=TRUE, validation="CV" )
  validationplot(pcr.fit,val.type="MSEP")

    #Find the lowest MSEP - PCR
    MSEP_object <- MSEP(pcr.fit)
    MSEP_object$val[1,1, ][ which.min(MSEP_object$val[1,1, ] )]

    #Compute test MSE - PCR
    pcr.pred=predict(pcr.fit, data=dataset, subset=test , ncomp=7)
    mean((pcr.pred- y.test)^2)

    #Get the final PCR fit (7 components)
    pcr.fit=pcr(house_sales_prices_mean ~ . , data=dataset, , scale=TRUE, ncomp=7)
    summary(pcr.fit)

    #Partial Least Squares
    set.seed(1)
    pls.fit=plsr(house_sales_prices_mean ~ . , data=dataset, subset=train, scale=TRUE, validation="CV")
    summary(pls.fit)
    validationplot(pls.fit,val.type="MSEP")

    #Find the lowest MSEP - PLS
    MSEP_object <- MSEP(pls.fit)
    MSEP_object$val[1,1, ][ which.min(MSEP_object$val[1,1, ] )]

    #Compute test MSE - PCR
    pls.pred=predict(pls.fit, data=dataset, subset=test , ncomp=5)
    mean((pls.pred- y.test)^2)

    #Get the final PLS fit (5 components)
    pls.fit=plsr(house_sales_prices_mean ~ . , data=dataset, , scale=TRUE, ncomp=5)
    summary(pls.fit)
