#NOTES
# the use of as.formula in regsubsets help us a determine only once the predictors and response in the beginning


###################################################
#####           DATASET PREPARATION       #########
###################################################


        #BLOCK 1 -DATA IMPORT - CLEANSING
            #Import

            dataset <- read_csv("~/Documents/dataset.csv")


            #Data Cleansing - area variable removal - converting to data.frame
            dataset=na.omit(dataset)
            dataset <- subset( dataset, select = -area )
            dataset <- as.data.frame(dataset)



###################################################
#####           MODEL SPECIFICATION     #########
###################################################

      #lIBRARIES
      library(leaps)
      library(glmnet)

      #USER ENTRY
      #SELECT A RESPONSE AND PREDICTORS FROM THE LIST:
      colnames(dataset)

      #set seed number
      SNUM=1
      set.seed(SNUM)

      #set number of folds for Shrinkage methods
      NFOLDS=10

      #variable count
      NUM<- ncol(dataset)-1

      #create an expression of response-predictor - in case of all use dot (.)
      EXP =  house_prices_mean ~ .
      RES = dataset$house_prices_mean

      #VARIABLEs

      #[1] count_births              count_deaths              count_pop
      #[4] count_breastf              count_job_seekers        ratio_low_birthweight
      #[7] ratio_hosp__acc_adm      ratio_hosp_planned_adm    ratio_fires
      #[10]  ratio_dis_allow         count_house_sales       house_sales_prices_mean
      #[13] count_room_1room        count_room_2room        count_room_3room
      #[16] ESA_16_24               ESA_25_49               ΕSA_50_59
      #[19] ESA_60_over             ESA_all

      #MATRIX TO STORE OUR PLOTS
      par(mfrow=c(2,2))



#######################################
# ---- NOW THE CODE IS AUTOMATED ---- #
######################################


###################################################
##### SUBSET SELECTION METHODS (FWD & BWD)#########
###################################################

  #BLOCK 1
    #predict_temporary_function - MANDATORY FOR CV ON FWD - BWD
          predict.sub=function(object,newdata,id,...){
          form=as.formula(object$call[[2]])
          mat=model.matrix(form,newdata)
          coefi=coef(object,id=id)
          xvars=names(coefi)
          mat[,xvars]%*%coefi
          }

  #BLOCK 2
    #Cross-Validation - FWD

        #spliting into k folds, and create matrix
        k=10
        set.seed(SNUM)
        folds=sample(1:k,nrow(dataset),replace=TRUE)
        cv.errors.fwd=matrix(NA,k,NUM, dimnames=list(NULL, paste(1:NUM)))


        #the loop for cross-validation using our pre-created function predict()
        for(j in 1:k){
        best.fit=regsubsets(as.formula(EXP), data=dataset[folds!=j,] , nvmax=NUM ,method ="forward")
        for(i in 1:NUM){pred=predict.sub(best.fit, dataset[folds==j,], id=i)
        cv.errors.fwd[j,i]=mean( (RES[folds==j]-pred)^2)  }
        }

        #average-get-plot MSEs by number of variables
        mean.cv.errors.fwd=apply(cv.errors.fwd ,2,mean)
        format(mean.cv.errors.fwd, big.mark=".", decimal.mark="," , scientific=FALSE) #we use format() to seperate numbers by dot
        plot(mean.cv.errors.fwd, type="b", main="Forward Subset - Cross-Validation", xlab="Number of Predictors")

        #find the lowest MSE, indicate it in the plot
        lMSE.feat.fwd.num.var<-which.min(mean.cv.errors.fwd)
        lMSE.fwd<-mean.cv.errors.fwd[lMSE.feat.fwd]
        format(lMSE.fwd, big.mark=".", decimal.mark="," , scientific=FALSE)      #we use format() to seperate numbers by dot
        points(lMSE.feat.fwd.num.var, mean.cv.errors.fwd[lMSE.feat.fwd],col="red",cex=2,pch=20)

        #calculate again the best subset and select the best predictors
        reg.best=regsubsets(as.formula(EXP) , data=dataset, nvmax=NUM ,method ="forward")
        coef(reg.best,lMSE.feat.fwd)

    #BLOCK 3
      #Cross-Validation - BWD

        #spliting into k folds, and create matrix
        k=10
        set.seed(SNUM)
        folds=sample(1:k,nrow(dataset),replace=TRUE)
        cv.errors.bwd=matrix(NA,k,NUM, dimnames=list(NULL, paste(1:NUM)))


        #the loop for cross-validation using our pre-created function predict()
        for(j in 1:k){
        best.fit=regsubsets(as.formula(EXP), data=dataset[folds!=j,] , nvmax=NUM ,method ="backward")
        for(i in 1:NUM){pred=predict.sub(best.fit, dataset[folds==j,], id=i)
        cv.errors.bwd[j,i]=mean( (RES[folds==j]-pred)^2)  }
        }

        #average-get-plot MSEs by number of variables
        mean.cv.errors.bwd=apply(cv.errors.bwd ,2,mean)
        format(mean.cv.errors.bwd, big.mark=".", decimal.mark="," , scientific=FALSE)
        plot(mean.cv.errors.bwd, type="b", main="Backward Subset - Cross-Validation", xlab="Number of Predictors")

        #find the lowest MSE, indicate it in the plot
        lMSE.feat.bwd.num.var<-which.min(mean.cv.errors.bwd)
        lMSE.bwd<-mean.cv.errors.bwd[lMSE.feat.bwd]
        format(lMSE.bwd, big.mark=".", decimal.mark="," , scientific=FALSE)      #we use format() to seperate numbers by dot
        points(lMSE.feat.bwd,mean.cv.errors.bwd[lMSE.feat.fwd],col="red",cex=2,pch=20)

        #calculate again the best subset and select the best predictors
        reg.best=regsubsets(as.formula(EXP) , data=dataset, nvmax=NUM ,method ="backward")
        coef(reg.best,lMSE.feat.bwd)

                          ###################################################
                          ##### optional remove of predict.sub function #####
                                        rm(predict.sub)
                          ###################################################





##########################################
########### S H R I N K A G E #############
##########################################
#SHRINKAGE - Lasso

  #BLOCK 1
        #DATA - LAMBDA MODIFICATIONS
        #EXTENDED LAMBDA VALUES
        grid=10^seq(10,-2,length=100)

        #DATA PREPARATION
        #assign x & y
        x= model.matrix(as.formula(EXP) ,dataset)[,-1]
        y= RES
          # CV - DATA PREPARATION
          train=sample(1:nrow(x), nrow(x)/2)
          test=(-train)
          y.test=y[test]

  #BLOCK 2
        #CV ON TRAIN DATA - MSE ESTIMATION
        lasso.mod=glmnet(x[train ,],y[train],alpha=1,lambda=grid)
        plot(lasso.mod, xvar="lambda", label=TRUE, ,main="Lambda-Coefficients plot - TRAIN DATA")

        set.seed (SNUM)
        cv.out=cv.glmnet(x[train ,],y[train],alpha=1, , nfolds=NFOLDS)
        plot(cv.out, main="Lambda - MSE Error - TRAIN DATA")

      #BLOCK 2.1
            # LOWEST MSE
            bestlam=cv.out$lambda.min
            bestlam
            lasso.pred=predict(lasso.mod,s=bestlam ,newx=x[test,])
            TestMseWithLambaOfLowTrainMse=mean((lasso.pred-y.test)^2)
            format(TestMseWithLambaOfLowTrainMse, big.mark=".", decimal.mark="," , scientific=FALSE)
            #coeff for every variable
            out=glmnet(x,y,alpha=1,lambda=grid)
            lasso.coef.lmse=predict(out,type="coefficients",s=bestlam)[1:NUM+2,]

            #exclude all zero coeff variables
            lasso.coef.lmse[lasso.coef.lmse!=0]

            #number of total selected variables
            sum(!lasso.coef.lmse == 0)


        #BLOCK 2.2
            #ONE STANDARD ERROR RULE
            oneselam=cv.out$lambda.1se
            oneselam
            lasso.pred=predict(lasso.mod,s=oneselam ,newx=x[test,])
            TestMseWithLambaOfOneStandardErrorTrainMse=mean((lasso.pred-y.test)^2)
            format(TestMseWithLambaOfOneStandardErrorTrainMse, big.mark=".", decimal.mark="," , scientific=FALSE)
            #coeff for every variable
            out=glmnet(x,y,alpha=1,lambda=grid)
            lasso.coef.1se=predict(out,type="coefficients",s=oneselam)[1:NUM+2,]

            #exclude all zero coeff variables
            lasso.coef.1se[lasso.coef.1se!=0]

            #number of total selected variables
            sum(!lasso.coef.1se == 0)



##########################################
################ RESULTS #################
##########################################

##########################################
########### FORWARD-BACKWARD #############
##########################################
#FWD MSE
lMSE.fwd
format(lMSE.fwd, big.mark=".", decimal.mark="," , scientific=FALSE) #we use format() to seperate numbers by dot
#BWD MSE
lMSE.bwd
format(lMSE.bwd, big.mark=".", decimal.mark="," , scientific=FALSE)      #we use format() to seperate numbers by dot

##########################################
############### LASSO ####################
##########################################
TestMseWithLambaOfLowTrainMse
format(TestMseWithLambaOfLowTrainMse, big.mark=".", decimal.mark="," , scientific=FALSE)      #we use format() to seperate numbers by dot
#number of total selected variables
sum(!lasso.coef.lmse == 0)

TestMseWithLambaOfOneStandardErrorTrainMse
format(TestMseWithLambaOfOneStandardErrorTrainMse, big.mark=".", decimal.mark="," , scientific=FALSE)      #we use format() to seperate numbers by dot
#Coefficients for 1 st error rule
lasso.coef.1se[lasso.coef.1se!=0]
#number of total selected variables
sum(!lasso.coef.1se == 0)




###################################################
#####         RETRIEVE THE BASIC PLOTS    #########
###################################################

plot(mean.cv.errors.fwd, type="b", main="Forward Subset - Cross-Validation", xlab="Number of Predictors")

#find the lowest MSE, indicate it in the plot
lMSE.feat.fwd<-which.min(mean.cv.errors.fwd)
lMSE.feat.fwd <-as.integer(lMSE.feat.fwd)
points(lMSE.feat.fwd, mean.cv.errors.fwd[lMSE.feat.fwd],col="red",cex=2,pch=20)


plot(mean.cv.errors.bwd, type="b", main="Backward Subset - Cross-Validation", xlab="Number of Predictors")

#find the lowest MSE, indicate it in the plot
lMSE.feat.bwd<-which.min(mean.cv.errors.bwd)
lMSE.feat.bwd <-as.integer(lMSE.feat.bwd)
points(lMSE.feat.bwd,mean.cv.errors.bwd[lMSE.feat.fwd],col="red",cex=2,pch=20)


plot(lasso.mod, xvar="lambda", label=TRUE, ,main="Lambda-Coefficients plot - TRAIN DATA")

plot(cv.out, main="Lambda - MSE Error - TRAIN DATA")
