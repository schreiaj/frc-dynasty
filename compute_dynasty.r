require(dplyr)
require(jsonlite)
require(httr)

read.csv("match_data.csv") -> all_data


c("qm" = 0.0000,
                "ef" = 0.0625,
                "qf" = 0.1250,
                "sf" = 0.2500,
                "f" = 0.5000)-> lookup

lookup = as.data.frame(lookup)
rownames(lookup) -> lookup$level
inner_join(all_data, lookup, 'level') -> all_data

all_data %>% group_by(year, event, team, level) %>% summarise(wins = max(sum(win), 1), points = max(lookup)) -> earnings
earnings$total_points = earnings$points * earnings$wins
earnings  %>% group_by(year, event, team) %>% summarise(dynasty = max(total_points)) -> dynasty

dynasty$key = paste(dynasty$year, dynasty$event, sep="")
years <- seq(2010, 2016)

lapply(seq(2013, 2015), function(i){
  GET(paste("http://thebluealliance.com/api/v2/events/", i, sep=""), add_headers("X-TBA-App-Id" = "schreiaj:dynasty:v3")) %>% content("text") %>% fromJSON()
}) %>% bind_rows -> events

columns <- c("year", "event", "team", "dynasty", "key", "official", "week", "event_type", "event_type_string", "short_name" )

inner_join(dynasty, events)[columns] -> dynasty

dynasty %>% filter(official==T) %>% group_by(year, team) %>% summarise(dynasty_score = mean(dynasty), dev=sd(dynasty, na.rm = T)) -> year_dynasty



team_dynasty <- year_dynasty %>% group_by(team) %>% summarise(score = mean(dynasty_score), var=min(sd(dev), score/2.0, na.rm=T))
write.csv(team_dynasty, "dynasty_scores.csv", row.names = F)
