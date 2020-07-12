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
# 列填缺
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
GB17GB11$GB2011[GB17GB11$Des2017 %in% '气压动力机械及元件制造'] <- '3444'
GB17GB11$GB2011[which(GB17GB11$Des2017 %in% '气压动力机械及元件制造')+1] <- NA
GB17GB11 <- GB17GB11[-(apply(GB17GB11,1,is.na) %>% apply(2,all) %>% which()),] # 去掉行全部是NA的观测
GB17GB11$GB2017 <- zoo::na.locf(GB17GB11$GB2017)
GB17GB11$Des2017 <- zoo::na.locf(GB17GB11$Des2017)

# GB2011 and GB2002
GB11GB02 <- xlsx::read.xlsx('./data-raw/GB2011ToGB2002.xls',2,
                            startRow = 3,header = FALSE,
                            encoding = 'UTF-8',stringsAsFactors = FALSE) %>%
  .[,1:4]
names(GB11GB02) <- c('GB2011','Des2011','GB2002','Des2002')
GB11GB02 <- GB11GB02[-(apply(GB11GB02,1,is.na) %>% apply(2,all) %>% which()),] # 去掉行全部是NA的观测
GB11GB02$GB2011 <- zoo::na.locf(GB11GB02$GB2011)
GB11GB02$Des2011 <- zoo::na.locf(GB11GB02$Des2011)
# only retain 4 digits
GB17GB11 <- GB17GB11[nchar(GB17GB11$GB2017) == 4,]
GB11GB02 <- GB11GB02[nchar(GB11GB02$GB2011) == 4,]

GB171102 <- merge(GB17GB11,GB11GB02[,c('GB2011','GB2002','Des2002')], by = 'GB2011', all = T)
load('./data-raw/TabC11_17.rdata') # from TabC2011.R

# 组合数据
TransData <- list(TabC = TabC, GB171102 = GB171102)
usethis::use_data(TransData,overwrite = T,internal = T)

GB171102 <- TransData$GB171102
usethis::use_data(GB171102,overwrite = T)
