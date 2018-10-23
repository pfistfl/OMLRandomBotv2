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
- Cubist
- fully connected neural networks (mxnet?)

**Worthy Candidates (From Kaggle etc.)**
- ExtraTrees
- Lightgbm / Catboost
- LibFM (Factorization Machines)


# Datasets
- OpenML - CC18
- AutoML Datensätze von Janek's Projekt

# Open Questions:
- Can we use batchtools and slurm scheduling?
- Divide into big / small datasets and fast / slow learners?
- Sample according to algo paramset dimensions?
- 
