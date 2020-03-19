rm(list = ls())
library(tidyverse)
library(reshape2)
library(pdftools)
rawdata <- pdf_data('data-raw/GB2017ToGB2011.pdf')
GB17GB11 <- list()
for (i in 1:length(rawdata)) {
  med <- rawdata[[i]][order(rawdata[[i]]$y),]
  starow <- str_detect(med$text,'明') %>% which() %>% .[1]
  med <- med[(starow + 1):nrow(med),]
  for (j in 2:nrow(med)) {
    if (med$y[j] - med$y[j-1] <= 2) med$y[j] <- med$y[j-1]
  }
  med <- dcast(med[,c('x','y','text')],y ~ x, value.var = 'text')
  if (!('97' %in% names(med))){
    med$`97` <- NA
  }
  # else if(!('140' %in% names(med))){
  #   med$`140` <- NA
  # }
  med <- med[,c('54','97','106','115','240','283')]
  med <- med[-(apply(med,1,is.na) %>% apply(2,all) %>% which()),] # 去掉行全部是NA的观测
  names(med) <- c('GB2017','Des2017','code3Dds','code4Des','GB2011','Des2011')
  GB17GB11[[i]] <- med
}
GB17GB11 <- bind_rows(GB17GB11)
for (i in 1:nrow(GB17GB11)) {
  if (is.na(GB17GB11$Des2017[i])){
    if (is.na(GB17GB11$code3Dds[i])){
      GB17GB11$Des2017[i] <- GB17GB11$code4Des[i]
    }else {
      GB17GB11$Des2017[i] <- GB17GB11$code3Dds[i]
    }
  }
}
GB17GB11 <- GB17GB11[,c('GB2017','Des2017','GB2011','Des2011')]
for (i in 1:nrow(GB17GB11)) {
  if (is.na(GB17GB11$GB2017[i]) & (!is.na(GB17GB11$Des2017[i]))){
    GB17GB11$Des2017[i-1] <- paste(GB17GB11$Des2017[i-1],GB17GB11$Des2017[i],sep = '')
    GB17GB11$Des2017[i] <- NA
  }
}
GB17GB11 <- GB17GB11[-(apply(GB17GB11,1,is.na) %>% apply(2,all) %>% which()),] # 去掉行全部是NA的观测
GB17GB11$GB2017 <- zoo::na.locf(GB17GB11$GB2017)
GB17GB11$Des2017 <- zoo::na.locf(GB17GB11$Des2017)

load('./data-raw/TabC11_17.rdata') # from TabC2011.R
# 组合数据
TransData <- list(TabC = TabC, GB17GB11 = GB17GB11)
usethis::use_data(TransData,overwrite = T,internal = T)
