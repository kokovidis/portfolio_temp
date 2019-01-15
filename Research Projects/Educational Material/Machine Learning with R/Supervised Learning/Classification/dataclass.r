dataclass <- read_csv("~/Desktop/dataclass.csv")
attach(dataclass)
dataclass$cat1 <- ifelse(dataclass$class == 1 , 1, 0)
glm.fits=glm(cat1~female_digest_admiss,data=dataclass,family=binomial)
glm.probs=predict(glm.fits,type="response")
glm.pred=rep("NO",6505)
glm.pred[glm.probs>0.4]="YES"
table(glm.pred,cat1)
mean(glm.pred==cat1)


#split train-test 0.75 : 0.25
train_assign <- sample(c(TRUE,FALSE), 6505, TRUE, prob=c(0.75,0.25))
test.subset <- dataclass[!train_assign, ]
glm.fits=glm(cat1~room_9+emerge_admiss + female_digest_admiss + ibsda_benefit, data=dataclass,family=binomial,subset=train_assign)
glm.probs=predict(glm.fits,test.subset,type="response")
numb_of_predictions <- length(glm.probs)
glm.pred=rep("NO", numb_of_predictions)
glm.pred[glm.probs>0.4]="YES"
res <- table(glm.pred,test.subset$cat1)
res


ctable <- as.table(matrix(c(res[1,1], res[1,2], res[2,1], res[2,2]), nrow = 2, byrow = TRUE))
rownames(ctable)= c("Predicted NO", "Predicted YES")
colnames(ctable) = c("True NO", "True YES")
fourfoldplot(ctable, color = c("#CC6666", "#99CC99"),
             conf.level = 0, margin = 1, main = "Confusion Matrix")

dataclass=na.omit(dataclass)

library(MASS)
lda.fit=lda(cat1 ~ room_9 + emerge_admiss + female_digest_admiss + ibsda_benefit,data=dataclass,subset=train)
lda.fit
lda.pred=predict(lda.fit,test.subset)
lda.class=lda.pred$class
table(lda.class,test.subset$cat1)
