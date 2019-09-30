

proc import datafile = "/home/aburnett2/Stat 2 Project File-Movie/movie.csv" out = mv dbms=csv replace;
run;
proc contents data=mv; run;

data new;
set mv;
log_gross = log(Gross);
if Sequel=1 then mt_1=0; else mt_1=1;
log_budget = log(Budget);
log_views = log(Views);
screens_in_ths = Screens/1000;
run;

* Model 1;
proc glm data=new;
class Genre Year;
model log_gross = Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments Aggregate_Followers /solution;
run;
* Model 2 - Final model;
proc glm data=new;
model log_gross = Ratings|mt_1 log_budget log_views screens_in_ths /solution;
title "GLM on final model with the whole data";
run;

***60% for training and 40% for testing; training=1; testing=0;
proc surveyselect data= new samprate=.6 out=new_out outall;
run;

data mv_training;
set new_out;
if selected=1;
run;


data mv_testing;
set new_out;
if selected=0;
run;

* Get prediction and accuracy for the training data;
proc glm data=mv_training;
model log_gross = Ratings|mt_1 log_budget log_views screens_in_ths /solution;
output out=mv_train_result p=pred r=r;
title "GLM on training data";
run;
proc print data=mv_train_result (obs=10);
run;

* Getting prediction only.;
data mv_train_result1;
set mv_train_result;
gross_pred = exp(pred);
train_ressq = (Gross - gross_pred)**2;
run;

* Getting the mean ASE only;
proc means data=mv_train_result1 mean;
var train_ressq;
output out=train_stats mean=ASE_train; 
title "ASE from training data";
run;

*getting the RMSE only.;
data train_stats1;
set train_stats;
RMSE_train = sqrt(ASE_train);
run;

proc print data=train_stats1;
var ASE_train RMSE_train;
title "ASE and RMSE from training data";
run;


* Get prediction and accuracy for the testing data;
proc glm data=mv_testing;
model log_gross = Ratings|mt_1 log_budget log_views screens_in_ths /solution;
output out=mv_test_result p=pred r=r;
title "GLM on testing data";
run;

* get prediction only;
data mv_test_result1;
set mv_test_result;
gross_pred = exp(pred);
test_ressq = (Gross - gross_pred)**2;
run;
* get mean ASE only;
proc means data=mv_test_result1 mean;
var test_ressq;
output out=test_stats mean=ASE_test; 
title "ASE from testing data";
run;
* get RMSE only;
data test_stats1;
set test_stats;
RMSE_test = sqrt(ASE_test);
run;

proc print data=test_stats1;
var ASE_test RMSE_test;
title "ASE and RMSE from testing data";
run;
