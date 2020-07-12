#' concordGB
#'
#' @description Product Concordance
#' @param sourcevar Vector which contains the codes to be converted.
#' @param origin	Coding scheme of origin (name enclosed in quotes "").
#' @param destination	Coding scheme of destination (name enclosed in quotes "").
#' @details Now \code{GB2011} / \code{GB2017} can be translated to
#'   \code{isic4}, and vice varsa. The transition among \code{GB2002},
#'   \code{GB2011} and \code{GB2017} is also available. A product code is 4 digits.
#'
#'   R package \code{concordance} provides a concordance among HS, HS0, HS1, HS2, HS3, HS4, ISIC2,
#'    ISIC3, SITC1, SITC2, SITC3, SITC4, BEC, NAICS and SIC.
#' @return Returns a vector of concorded codes.
#' @examples
#' # translate GB2011 codes to isic4 codes
#' concordGB(c('0142','2411'))
#' # translate GB2011 codes to GB2002 codes with 2 digits
#' concordGB('37','GB2011','GB2002')
#' @import magrittr
#' @export

concordGB <- function(sourcevar, origin = 'GB2011',
                          destination = 'isic4'){
  if ('isic4' %in% c(origin, destination)){
    TabC <- TransData[['TabC']]
    if (origin %in% c('GB2011','GB2017')){
      yr <- stringr::str_sub(origin,3,6) %>% as.numeric()
      TabC <- TabC[TabC$yr == yr,]
      origin <- stringr::str_sub(origin,1,2)
    }else if (destination %in% c('GB2011','GB2017')){
      yr <- stringr::str_sub(destination,3,6) %>% as.numeric()
      TabC <- TabC[TabC$yr == yr,]
      destination <- stringr::str_sub(destination,1,2)
    }

    # 2 digit for GB code?
    if (nchar(sourcevar[1]) == 2){
      TabC[,c('GB','isic4')] <- apply(TabC[,c('GB','isic4')],2, stringr::str_sub, start = 1, end = 2)
    }
  }else if (all(c(origin,destination) %in% c('GB2017','GB2011','GB2002'))){
    TabC <- TransData[['GB171102']]
    # 2 digit for GB code?
    if (nchar(sourcevar[1]) == 2) TabC[,c('GB2011','GB2017','GB2002')] <-
      apply(TabC[,c('GB2011','GB2017','GB2002')],2, stringr::str_sub, start = 1, end = 2)
  }

  # delete NA
  ans <- TabC[(TabC[,origin] %in% sourcevar),destination] %>% unique()
  ans <- ans[!is.na(ans)]
  return(ans)
}

