proc import datafile="/home/aburnett2/Stat 2 Project File-Movie/movie.csv" out=mdata dbms=csv replace;
run;
proc contents data=mdata;
run;

****Budget, Screens, AggregateFollowers have missing data;


proc freq data=mdata;
tables Genre;
run;

data new;
set mdata;
log_gross=log(Gross);
if Sequel=1 then mt_1=0;
else mt_1=1;
Screens_in_thousands=Screens/1000;
Dislikes_in_thousands=Dislikes/1000;
if Sentiment>0 then positive=1;
else positive=0;
if Sentiment>0 then sentiment_rank=3;
else if Sentiment=0 then sentiment_rank=2;
else sentiment_rank=1;
if Views>10000000 then mt_tenm_views=1;
else mt_tenm_views=0;
run;

proc freq data=new;
tables positive;
run;
proc freq data=new;
tables sentiment_rank;
run;



* Model 1;
proc glm data=new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/solution;
run; 

* Model 2;
proc glm data=new;
model log_gross=Ratings Screens mt_1/solution;
run; 




*Backward Selection;
proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = backward (select = sl stop=sl sls=0.1);
run;

proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = backward (choose=CV stop=cv) CVDETAILS;
run;

*Forward selection;
proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = forward;
run;

proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = forward (choose=CV stop=cv) CVDETAILS;
run;


*Step-Wise selection;
proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = stepwise;
run;

proc glmselect data= new;
class Genre Year;
model log_gross=Genre Year Ratings Budget Screens mt_1 Sentiment Views Likes Dislikes Comments AggregateFollowers/selection = stepwise (choose=CV stop=cv) CVDETAILS;
run;

*Model 3;
proc glm data=new;
model log_gross=Ratings Screens_in_thousands mt_1 Dislikes_in_thousands positive/solution;
run; 

*Model 4-I tried the model with sentiments in ranks and positive and negative sentiment groups but wasn't as significant as dislikes.  It seemed to be more correlated with likes and dislikes.
proc glm data=new;
model log_gross=Ratings Screens_in_thousands mt_1 Dislikes_in_thousands/solution;
run; 

proc means data=new;
var Views;
run;
*model 5-
proc glm data=new;
model log_gross=Ratings Screens_in_thousands mt_1 Dislikes_in_thousands mt_tenm_views/solution;
run; 
