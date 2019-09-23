#split dataframe into train & validation sets. Returns a list
splitTrainValidation<-function(df){
  
  getRandomSampleIndex<-function(df,percent=0.2){
    sample.int(n = nrow(df), size = floor(percent*nrow(df)), replace = F)
  }
  
  randomSampleIndex<-getRandomSampleIndex(df)
  validationSet<-df[randomSampleIndex,]
  trainingSet<-df[-randomSampleIndex,]
  ret<-list(df,validationSet,trainingSet)
  names(ret)<-c("data", "validationSet", "trainingSet")
  return(ret)
}