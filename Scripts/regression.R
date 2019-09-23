##Ensemble Regression Function

#RANDOM FUNCTIONS
#COMPUTES Root mean squared error for predicted values versus actual values
RMSE = function(predictions, actuals){
  sqrt(mean((predictions - actuals)^2))
}

#TAKES A confusionMatrix and returns an accuracy calcultation for a classifer
accuracy <- function(confusionMatrix){paste0(round(sum(diag(confusionMatrix)/(sum(rowSums(confusionMatrix)))) * 100,2),"%")}

#FUNCTION TAKES A TRAINING, VALIDATION SET, and FIELDNAME
#And performs ensemble regression on it
#Determines which model is the most accurate
ensembleRegression <- function(train,validation,fieldname){
  
  #Set variables
  trainObserved<-train %>% select(fieldname) %>% unlist() %>% as.double()
  validationObserved<-validation %>% select(fieldname) %>% unlist() %>% as.integer()
  
  #Create factor dataset for random forest
  trainFactors<-train %>% mutate_if(is.character, as.factor)
  validationFactors<-validation %>% mutate_if(is.character, as.factor)
  
  #Multiple Linear Regression
  f<- as.formula(paste(fieldname, " ~ ."))
  LM_Model<-lm(formula=f, data = train)
  LM_Predictions<-predict(LM_Model, validation %>% select(-fieldname))
  
  #LASSO REGRESSION
  library(glmnet)
  
  lasso_train_features<-model.matrix(f, train)[,-1]
  lasso_validation_features<-model.matrix(f, validation)[,-1]
  lambda_seq <- 10^seq(2, -2, by = -.1)
  
  cv_output <- cv.glmnet(lasso_train_features,
                         trainObserved,
                         alpha = 1,
                         lambda = lambda_seq)
  
  best_lam <- cv_output$lambda.min
  
  lasso_best <- glmnet(lasso_train_features,
                       trainObserved,
                       alpha = 1,
                       lambda = best_lam)
  
  lasso_predictions <- predict(lasso_best, s = best_lam, newx = lasso_validation_features)
  
  #RANDOM FOREST REGRESSION
  library(randomForest)
  
  rfRegressionModel <- randomForest(f,
                                    data = trainFactors,
                                    ntree = 500,
                                    mtry = 6,
                                    importance = TRUE)
  
  RF_predictions <- predict(rfRegressionModel, validationFactors, type = "class")
  
  #ENSEMBLE PREDICTIONS
  Predictions<-data.frame(
    "actual"=validationObserved,
    "randomforest"=as.numeric(RF_predictions),
    "lasso"=as.numeric(lasso_predictions),
    "linear_regression"=as.numeric(LM_Predictions)
  ) %>%
    rowwise() %>%
    mutate(
      `ensemble min`= min(randomforest, lasso, linear_regression),
      `ensemble max`= max(randomforest, lasso, linear_regression),
      `ensemble median` = median(c(randomforest, lasso, linear_regression)),
      `ensemble mean` = mean(c(randomforest, lasso, linear_regression))
    )
  #Lets track the RMSE for each
  RMSE_results<-apply(Predictions %>% select(-actual),
                      MARGIN=2,
                      FUN=function(x) RMSE(x,validationObserved)
  ) %>%
    round(2)
  
  #MODELS
  Models<-list(
    "randomforest"=rfRegressionModel,
    "lasso"=lasso_best,
    "linear_regression"=LM_Model
  )
  
  #WINNER IS MODEL WITH BEST RMSE
  WINNER_NAME <- names(which(RMSE_results == min(RMSE_results)))
  WINNER_RMSE <- paste0("$",min(RMSE_results))
  WINNER_DESCRIPTION<-paste(str_to_title(WINNER_NAME), "had the best predictive ability with a RMSE of", WINNER_RMSE)
  WINNER_MODEL=get(WINNER_NAME,Models)
  WINNER_IMPORTANCE<- importance(WINNER_MODEL) %>%
    as.data.frame() %>%
    select(1) %>% mutate(Variable=rownames(.)) %>%
    arrange(desc(`%IncMSE`))
  #LOSER IS MODEL WITH WORSE RMSE
  LOSER_NAME <- names(which(RMSE_results == max(RMSE_results)))
  LOSER_RMSE <- paste0("$",max(RMSE_results))
  LOSER_DESCRIPTION<-paste(str_to_title(LOSER_NAME), "had the worst predicitive ability with a RMSE of", LOSER_RMSE)
  
  list("Predictions"=Predictions,
       "Models"=Models,
       "trainFactors"=trainFactors,
       "validationFactors"=validationFactors,
       "RMSE_results"=RMSE_results,
       "WINNER_NAME"=WINNER_NAME,
       "WINNER_RMSE"=WINNER_RMSE,
       "WINNER_DESCRIPTION"=WINNER_DESCRIPTION,
       "WINNER_MODEL"=WINNER_MODEL,
       "WINNER_IMPORTANCE"=WINNER_IMPORTANCE,
       "WINNER_Predictions"=get(WINNER_NAME, Predictions),
       "LOSER_NAME"=LOSER_NAME,
       "LOSER_RMSE"=LOSER_RMSE,
       "LOSER_DESCRIPTION"=LOSER_DESCRIPTION,
       "LOSER_MODEL"=get(LOSER_NAME,Models),
       "LOSER_Predictions"=get(LOSER_NAME, Predictions)
  )
}
