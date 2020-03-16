# GB2ISIC

## 动机

近来做一些产业、贸易相关研究，发现产品编码之间的转换很麻烦，特别是国家产业的标准编码与国际编码之间转换。找到《中华人民共和国国家标准GB/T 4754-2011》(该文中的行业编码以下称GB2011)和《中华人民共和国国家标准GB/T 4754-2017》（该文的行业编码下称GB2017），该文件的附录C有GB2011和GB2017与国际标准行业分类(International Standard Industiral Classification, 以下称isic4)第4版的一个对应，本包即根据该对应，做了一个代码转换的函数。

## 安装

安装很简单，在Ｒ语言控制台输入，

```R
devtools::install_github('common2016/GB2ISIC')
```

其间会问你要不要更新你已有的一些包。想更新就更新，包多的话时间较长。不更新的话，直接回车。

## 使用

```R
library(GB2ISIC)
concordanceGB(c('0142','2411'),origin = "GB2011", destination = "isic4")
```

这就把0142和2411两个GB2011编码的行业转换成了isic4编码。

## 注意的几个地方

