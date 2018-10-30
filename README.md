# OMLRandomBotv2

The current implementation of the Bot follows the following scheme: 

1. Init Bot with a task.id
1. Draw a learner with probability proportional to its param set dimensions
1. Draw a random hyperparameter config
1. Resample sampled learner/hyperpars on the OML Task


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

# Parameter Spaces

See [learners.R](https://github.com/pfistfl/OMLRandomBotv2/blob/master/R/learners.R)


# Open Questions:

- Can we use batchtools and slurm scheduling?
- Draw a random task inside the bot or obtain it from outside?
- Divide into big / small datasets and fast / slow learners?
- Sample according to algo paramset dimensions?
- Should e.g. `xgboost's` `gbtree` and `gblinear` be sampled with equal probability?
- How should we do logging of failed jobs?


# How do I run the bot?

We currently require a OML `task.id` for the bot to run
```
bot = OMLRandomBot$new(11)
bot$run()
```

## Required packages
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
