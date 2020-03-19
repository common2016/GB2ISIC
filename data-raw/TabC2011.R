# pdf_subset('GB2011.pdf',118:154)
rm(list = ls())
library(tidyverse)
library(reshape2)
library(pdftools)
rawdata <- pdf_data('data-raw/GB2017_output.pdf')
TabC2017 <- list()
for (i in 1:length(rawdata)) {
  med <- rawdata[[i]][order(rawdata[[i]]$y),]
  starow <- str_detect(med$text,'Rev.4）') %>% which()
  med <- med[(starow + 1):nrow(med),]
  med <- dcast(med[,c('x','y','text')],y ~ x, value.var = 'text')
  if (!('121' %in% names(med))){
    med$`121` <- NA
  }else if(!('140' %in% names(med))){
    med$`140` <- NA
  }
  med <- med[,c('82','121','131','140','296','327')]
  med <- med[-(apply(med,1,is.na) %>% apply(2,all) %>% which()),]
  names(med) <- c('GB','code2Des','code3Dds','code4Des','ISIC','ISICDes')
  TabC2017[[i]] <- med
}
TabC2017 <- bind_rows(TabC2017)
for (i in 1:nrow(TabC2017)) {
  if (is.na(TabC2017$code2Des[i])){
    if (is.na(TabC2017$code3Dds[i])){
      TabC2017$code2Des[i] <- TabC2017$code4Des[i]
    }else {
      TabC2017$code2Des[i] <- TabC2017$code3Dds[i]
    }
  }
}
TabC2017 <- dplyr::rename(TabC2017, isic4 = ISIC, isic4Des = ISICDes, GB2017 = GB)
TabC2017 <- TabC2017[,c('GB2017','code2Des','isic4','isic4Des')]
names(TabC2017)[2] <- 'GBDes'
TabC2017$GB2017 <- zoo::na.locf(TabC2017$GB2017)
TabC2017$GBDes <- zoo::na.locf(TabC2017$GBDes)

# 搞定2011行业分类
# 去除杂乱编码
TabC2011 <- readLines('data-raw/GB2011.txt',encoding = 'UTF-8')
TabC2011 <- TabC2011[!str_detect(TabC2011,'国民经济行业分类|GB／T|表C|表c|Ga')]
TabC2011 <- str_remove_all(TabC2011,' ')
TabC2011 <- str_replace_all(TabC2011,'】|l|i|I|]|J','1')
TabC2011 <- str_replace_all(TabC2011,'O|o|\\(\\)','0')

TabC2011 <- data.frame(nid = 1:length(TabC2011), TabC2011 = TabC2011)
TabC2011 <- TabC2011[str_detect(TabC2011$TabC2011,
                                '^[A-Z][\\u4E00-\\u9FA5]+|^\\d{2}[\\u4E00-\\u9FA5]+|^\\d{3}[\\u4E00-\\u9FA5]+'),] %>%
  merge(TabC2011,., by = 'nid', all.x = T)
TabC2011 <- TabC2011[!str_detect(TabC2011$TabC2011.x,'\\d{3}$'),]
TabC2011$TabC2011.x <- as.character(TabC2011$TabC2011.x)
TabC2011$TabC2011.y <- as.character(TabC2011$TabC2011.y)
TabC2011$ISIC <- NA
for (i in 1:nrow(TabC2011)) {
  if (is.na(TabC2011$TabC2011.y[i])){
    loc <- str_locate_all(TabC2011$TabC2011.x[i],'\\d{4}[\\u4E00-\\u9FA5]+') %>% .[[1]]
    if (nrow(loc) == 2){
      TabC2011$ISIC[i] <- str_sub(TabC2011$TabC2011.x[i],loc[2,1],nchar(TabC2011$TabC2011.x[i]))
      TabC2011$TabC2011.y[i] <- str_sub(TabC2011$TabC2011.x[i],1,loc[2,1]-1)
    } else if (nrow(loc) == 1){
      TabC2011$ISIC[i] <- TabC2011$TabC2011.x[i]
    }
  }
}
TabC2011$TabC2011.y[str_detect(TabC2011$TabC2011.x,'信息传输、软件和信息技术服务业')] <-
  'I信息传输、软件和信息技术服务业'
TabC2011$TabC2011.y[str_detect(TabC2011$TabC2011.x,'1金融业')] <-
  'J金融业'
TabC2011$TabC2011.y[str_detect(TabC2011$TabC2011.x,'0居民服务、修理和其他服务业')] <-
  'O居民服务、修理和其他服务业'
TabC2011$TabC2011.y <- zoo::na.locf(TabC2011$TabC2011.y)

TabC2011$GB <- NA
TabC2011$GB <- str_extract_all(TabC2011$TabC2011.y,'\\d|[A-Z]',simplify = T) %>% apply(1,paste,collapse = '')
TabC2011$GBDes <- str_extract_all(TabC2011$TabC2011.y,'[^\\d+]',simplify = T) %>%
  apply(1,paste,collapse = '')
TabC2011$ISICDes <- str_extract_all(TabC2011$ISIC,'[^\\d+]',simplify = T) %>%
  apply(1,paste,collapse = '')
TabC2011$ISIC <- str_extract_all(TabC2011$ISIC,'\\d',simplify = T) %>% apply(1,paste,collapse = '')
TabC2011$ISIC[TabC2011$ISIC %in% 'NA'] <- NA
TabC2011$ISICDes[TabC2011$ISICDes %in% 'NA'] <- NA
TabC2011 <- dplyr::rename(TabC2011,GB2011 = GB, isic4 = ISIC, isic4Des = ISICDes)
TabC2011 <- TabC2011[,c('GB2011','GBDes','isic4','isic4Des')]

TabC2011 <- rename(TabC2011, GB = GB2011)
TabC2011$yr <- 2011
TabC2017 <- rename(TabC2017, GB = GB2017)
TabC2017$yr <- 2017
TabC <- rbind(TabC2011,TabC2017)

# save(TabC, file = './data-raw/TabC11_17.rdata')


