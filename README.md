# OMLRandomBotv2
For now, this is a design Document for the new OpenML Bot

# Learners

**From the old bot**
- xgboost
- svm
- kernel knn
- random forest
- rpart
- glmnet

**New learners**
- Multinomial Logit (from mxnet?)
- Cubist
- fully connected neural networks (mxnet?) up to depth 3 or 4

**Worthy Candidates (From Kaggle etc.)**
- ExtraTrees (we can enable this in ranger)
- Lightgbm / Catboost (Probably to similar to xgboost)
- LibFM (Factorization Machines)[https://github.com/dselivanov/rsparse]
- LiquidSVM
- Adaboost



# Datasets
- OpenML - CC18
- AutoML Datensätze von Janek's Projekt

# Open Questions:
- Can we use batchtools and slurm scheduling?
- Divide into big / small datasets and fast / slow learners?
- Sample according to algo paramset dimensions?


# How do I run it?

We currently require a OML `task.id` for the bot to run
```
bot = OMLRandomBot$new(11)
bot$run()
```

# Required packages
```
# Benchmark
library(mlr)
library(batchtools)
library(R6)
library(callr)
library(data.table)
library(ParamHelpers)

# Learners
library(rpart)
library(glmnet)
library(e1071)
library(ranger)
library(xgboost)
```
