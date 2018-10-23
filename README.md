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
-
