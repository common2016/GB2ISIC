# GB2ISIC

## 动机

最近做一些产业、贸易相关研究，发现产品编码之间的转换很麻烦，特别是国家产业的标准编码与国际编码之间转换。找到《中华人民共和国国家标准GB/T 4754-2011》(该文中的行业编码以下称GB2011)和《中华人民共和国国家标准GB/T 4754-2017》（该文的行业编码下称GB2017），该文件的附录C有GB2011和GB2017与国际标准行业分类(International Standard Industiral Classification, 以下称isic4)第4版的一个对应，本包即根据该对应，写了一个代码转换的函数。

这两个文件我放在了百度网盘里面：

链接: https://pan.baidu.com/s/1OYd-LaoINHiT2N0SVYqmxg  

提取码: y3f4 

## 安装

安装很简单，在Ｒ语言控制台输入，

```R
devtools::install_github('common2016/GB2ISIC')
```

其间会问你要不要更新你已有的一些包，如果旧包过多的话，更新时间较长。不更新的话，直接回车。

## 使用

```R
library(GB2ISIC)
concordanceGB(c('0142','2411'),origin = "GB2011", destination = "isic4")
```

这就把0142和2411两个GB2011编码的行业转换成了isic4编码。目前只能将GB2011和GB2017转成isic4，或者将isic4转成GB2011和GB2017。

感兴趣在国际行业编码HS, HS0, HS1, HS2, HS3, HS4, ISIC2, ISIC3, SITC1, SITC2, SITC3, SITC4, BEC, NAICS和 SIC间进行转换的，可以参考`concordance`包。

## 注意的几个地方

- 行业编码是4位的，少于这个会报错。
- GB2011的文件中也提到，这种编码的对应并不是一一完全对应。

## 其他
- 一直没有找到《中华人民共和国国家标准GB/T 4754-2002》文件，要是哪位朋友有，不妨发一份给我，谢先，chenyangx@ecjtu.edu.cn。
- 使用过程中，有任何问题和建议也可以联系chenyangx@ecjtu.edu.cn。