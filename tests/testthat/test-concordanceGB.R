test_that('GB2011 to isic4',{
  expect_equal(concordanceGB(c('0123','0133')),c('0113','0114'))
  expect_equal(concordanceGB(c('0111','0113'), origin = 'isic4',destination = 'GB2017'),
               c( "0112","0113","0119","0121","0122","0123","0133","0141","0142","0159"))
})
