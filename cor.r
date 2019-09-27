library(tidyr)
library(dplyr)
library(corrplot)
library(readr)

#
# profits format
#   2019-01-01,EURGBP,100
#   2019-01-02,EURGBP,104
# 
profits <- read_csv('profits.csv', col_names=F)
rows <- profits %>% tidyr::spread(key = X2, value=X3)
rows_ <- rows[-1]
cr <- cor(rows_)

#
# write csv
#
cr_ <- cr %>% round(., 2)
write.csv(cr_, 'cor.csv')

#
# output png
#
png('cor.png', height=800, width=800)
corrplot::corrplot(cr)
dev.off()
