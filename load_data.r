require(reshape2)
require(stringr)


headers <- c("match", "r1", "r2", "r3", "b1", "b2", "b3", "rscore", "bscore")
red <- c("r1", "r2", "r3")
blue <- c("b1", "b2", "b3")
fileNames <- grep('201[0-6][a-z]*_matches.csv',list.files(path = "./data/tba/events", all.files = TRUE, 
                                                                      full.names = TRUE, recursive = TRUE),value=TRUE) 
match_data <- do.call("rbind", lapply(fileNames, read.csv2, header = FALSE, sep=","))
colnames(match_data) <- headers

match_data['bWin'] <- match_data$rscore < match_data$bscore
match_data['rWin'] <- match_data$rscore > match_data$bscore

melt(match_data, measure.vars = c("b1", "b2", "b3") ) -> blue
melt(match_data, measure.vars = c("r1", "r2", "r3") ) -> red
blue[c('value', 'bWin', 'match')] -> blue
red[c('value', 'rWin', 'match')] -> red
c('team', 'win', 'match') -> colnames(red)
c('team', 'win', 'match') -> colnames(blue)

rbind(red, blue) -> all

tba_pattern <- "([0-9]{4})([a-z]+)_(.*)"
match_info <- str_match(all$match, tba_pattern)
all$year = as.numeric(match_info[,2])
all$event = match_info[,3]
match_pattern <- "^([a-z]+)[0-9]*?m*([0-9]+)"
match_number <- str_match(match_info[,4], match_pattern)
all$level = match_number[, 2]
all$match_no = match_number[,3]

write.csv(all, "match_data.csv", row.names = F)
