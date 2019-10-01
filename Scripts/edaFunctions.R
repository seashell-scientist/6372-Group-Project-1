library(tidyverse)

#HISTOGRAMS
histAllNumeric <- function(df){
  df%>%keep(is.numeric) %>%
    gather() %>%
    ggplot(aes(value)) +
    facet_wrap(~ key, scales = "free") +
    geom_density()+geom_histogram()
}

#SMOOTHED HISTOGRAMS / DENSITY ESTIMATE

smoothHistAllNumeric<- function(df){
  df%>%keep(is.numeric) %>%
    gather() %>%
    ggplot(aes(value)) +
    facet_wrap(~ key, scales = "free") +
    geom_density()
}

#HEAT MAP
library(RColorBrewer)
library(gplots)
my_palette <- colorRampPalette(c("red", "white", "black"))
heatmapper <- function(df){
  df %>%
    keep(is.numeric) %>%
    tidyr::drop_na() %>%
    cor %>%
    heatmap.2(col = my_palette ,
              density.info = "none", trace = "none",
              dendogram = c("both"), symm = F,
              symkey = T, symbreaks = T, scale = "none",
              key = T)
}

#CORRELATION PLOTS
library(corrplot) 
correlator  <-  function(df){
  df %>%
    keep(is.numeric) %>%
    tidyr::drop_na() %>%
    cor %>%
    corrplot( addCoef.col = "white", number.digits = 2,
              number.cex = 0.5, method="square",
              order="hclust", title="Variable Corr Heatmap",
              tl.srt=45, tl.cex = 0.8)
}

# Categorical variables
# box plots
library(ggplot2)
library(cowplot)
boxplotCats<- function(df, response_var){
  df %>% select_if(is.factor) %>% names -> categories
  plist <- vector("list", length(categories))
  for(category in categories){
    plist[[which(category == categories)]]<-ggplot(data = df, aes_string(x = category, y = response_var, fill = category)) +
      geom_boxplot() + 
      xlab("")
  }
  cowplot::plot_grid(plotlist = plist, ncol = 2, labels = "")
}

#VIOLIN PLOT CATS
violinPlotCats<- function(df, response_var){
  df %>% select_if(is.factor) %>% names -> categories
  plist <- vector("list", length(categories))
  for(category in categories){
    plist[[which(category == categories)]]<-ggplot(data = df, aes_string(x = category, y = response_var, fill = category)) +
      geom_violin() + 
      xlab("")
  }
  cowplot::plot_grid(plotlist = plist, ncol = 2, labels = "")
}

# PLOT CONTINOUS VARIABLES
plot_vs_response <- function(df, responseVar, independentVar){
  plot(df[[responseVar]] ~ df[[independentVar]], xlab = independentVar, ylab=responseVar)
  lw1 <- loess(df[[responseVar]] ~ df[[independentVar]])
  j <- order(df[[independentVar]])
  lines(df[[independentVar]][j],lw1$fitted[j],col="red",lwd=3)
}








