##### Prediction of 1 Correct exercise and 4 incorrect way of same exercise ####

require(caret)
require(randomForest)
require(ggplot2)
require(grid)
require(gridExtra)
require(matrixStats)



##### Read in the datasets ####

urltrain = 'https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv'
urltest = 'https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv'

train = read.csv(urltrain, stringsAsFactors = F)
train$classe = factor(train$classe)
test = read.csv(urltest, stringsAsFactors = F)



##### Removing empty or almost empty variable ####
ctrain = train[, -c(1,3:7)]
na.share = sapply(ctrain, function(x) { sum(is.na(x))/length(x)})
na.share = as.data.frame(na.share)

table(na.share) # this shows we can drop 67 features straight away
clean.col = which(na.share[ ,1] == 0, arr.ind = T)
ctrain = ctrain[ , clean.col]

char.col = sapply(ctrain, class)
char.col = as.data.frame(char.col)
char.col = which(char.col[,1] == "character", arr.ind = T)

num.train = ctrain
num.train[ ,char.col] = sapply(num.train[ ,char.col], as.numeric)

na.numshare = sapply(num.train, function(x) { sum(is.na(x))/length(x)})
na.numshare = as.data.frame(na.numshare)

table(na.numshare) # this shows we can drop some more features
nafree.col = which(na.numshare[ ,1] == 0, arr.ind = T)

num.train = num.train[ , nafree.col]
num.train = cbind(ctrain$user_name, num.train) # has both "user_name" and "classe"
colnames(num.train)[1] = "user_name"

dim(num.train)
wled.train = num.train[ ,-1] # has only "classe"
feature.matrix = as.matrix(wled.train[ ,-53]) # has only numeric/integer variables




##### Visualize the extracted dataset ####

options(max.print = 1000)

table(num.train$classe, num.train$user_name)

t(apply(feature.matrix, 2, quantile))

nab = min(feature.matrix[feature.matrix != min(feature.matrix)])
mab = max(feature.matrix)
boxplot(feature.matrix, las = 2, ylim = c(nab-1, mab+1))


cols_to_plot = colnames(num.train)
plotvars = c('yaw_belt','accel_dumbbell_y','magnet_belt_y','roll_forearm')
plotset = num.train[ ,c(which(cols_to_plot %in% plotstring), 54)]

narrowwle = plotset %>% 
  mutate(Index = 1:nrow(.)) %>% #add the column of row numbers
  gather(Measure, Value, -(classe:Index))

ggplot(narrowwle, aes(x = Index, y = Value, group = classe, color = classe)) + 
  geom_point() + 
  facet_wrap(~Measure, nrow = 2)




##### Fit the model(s) ####

# model lda
ctrl = trainControl(method = "cv", number = 10)
lda.wle1 = train(classe ~ ., data = num.train, method = "lda") # gives almost equal accuracy
lda.wle2 = train(classe ~ ., data = num.train, method = "lda", trControl = ctrl)


# model rf using out-of-bag
rf.ctrl = trainControl(method = "oob", number = 4, verboseIter = TRUE)
rf.wletrain = train(x = feature.matrix, y = wled.train$classe, method = "rf", trControl = rf.ctrl)
rf.wletrain

##### Try the fitted the model(s) ####

# remove from test dataset the features removed from train dataset
cleantest = test[ ,which(colnames(train) %in% colnames(num.train), arr.ind = T)]
cleantest = cleantest[ ,-54]
cleantest$user_name = factor(cleantest$user_name)
wled.test = cleantest[ ,-1]

# pred lda
wlep.lda = predict(lda.wle1, newdata = wled.test) # the other lda model gives similar performance

# pred rf
wlep.rf = predict(rf.wletrain, newdata = wled.test)
rf.res = as.character(wlep.rf)




##### Visualize the models ####

# Diminishing effect of including more features
plot(varImp(rf.wletrain), col = "red", top = 20)

rf.wletrain # Overall fitting summary
rf.wletrain$finalModel # Fitted model summary

