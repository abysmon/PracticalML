---
title: "Weight Lifting Exercise Classifier"
author: "Kay Dee"
date: "Friday, January 23, 2015"
output: html_document
---

### About the data

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement – a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. 
In this project, data is taken from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to **perform barbell lifts correctly and incorrectly in 5 different ways**. More information is available from the website here: `http://groupware.les.inf.puc-rio.br/har#weight_lifting_exercises`

### Objective

The goal of this project is to predict the manner in which the subjects did the exercise. This is the **classe** variable in the training set. 


### Actions performed in broad strokes

  1. Read in the datasets
  2. Prune unnecessary features
  3. Explore the data
  4. Visually inspect the extracted dataset
  5. Fit the model(s)
  6. Evaluate the fitted the model(s)
  7. Visualize the prediction
  8. Select the final model


### Exploring the data

```{r, echo=FALSE, message=FALSE}
require(caret)
require(randomForest)
require(ggplot2)
load('~/R/DataScToolboxCEra/project/projectallobj.RData')
```

Total cases of exercise types against for each subject is given in table below
```{r}
table(num.train$classe, num.train$user_name)
```


**Summary statistics for the extracted feature**
```{r, echo=FALSE}
t(apply(feature.matrix, 2, quantile))
```


**Distribution of each feature, limiting the y-axis to ignore the minimum outlier**
```{r, echo=FALSE, dpi=200, dev.args=list(pointsize=8)}
nab = min(feature.matrix[feature.matrix != min(feature.matrix)])
mab = max(feature.matrix)
boxplot(feature.matrix, las = 2, ylim = c(nab-1, mab+1), )
```


**Snapshot of 4 feature spread:**  
```{r, echo=FALSE}
ggplot(narrowwle, aes(x = Index, y = Value, group = classe, color = classe)) + 
  geom_point() + 
  facet_wrap(~Measure, nrow = 2)
```


### Summary of the final model

**Model accuracy and tuning parameters**  
```{r, echo=FALSE}
rf.wletrain$results
```

So the best tuning is done for the **number of variable per level (mtry) =** `r rf.wletrain$bestTune[[1]]`


**Importance of the top 20 features in the fitted random forest:**
```{r, echo=FALSE}
plot(varImp(rf.wletrain), col = "red", top = 20)
```
