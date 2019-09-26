#split dataframe into train & validation sets. Returns a list
splitTrainValidation<-function(df){
  set.seed(123)
  
  
  getRandomSampleIndex<-function(df,percent=0.2){
    smp_size <- floor(percent * nrow(df))
    sample(seq_len(nrow(df)), size = smp_size)
  }
  
  randomSampleIndex<-getRandomSampleIndex(df)
  validationSet<-df[randomSampleIndex,]
  trainingSet<-df[-randomSampleIndex,]
  ret<-list(df,validationSet,trainingSet)
  names(ret)<-c("data", "validationSet", "trainingSet")
  return(ret)
}