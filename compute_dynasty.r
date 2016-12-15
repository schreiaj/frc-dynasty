require(dplyr)
read.csv("match_data.csv") -> all_data


c("qm" = 0.0000,
                "ef" = 0.0625,
                "qf" = 0.1250,
                "sf" = 0.2500,
                "f" = 0.5000)-> lookup

lookup = as.data.frame(lookup)
rownames(lookup) -> lookup$level
inner_join(all_data, lookup, 'level') -> all_data


# Lower bound points for now, todo compute event winner points
all_data %>% group_by(year, event, team, level) %>% summarise(wins = max(sum(win), 1), points = max(lookup)) -> earnings
earnings$total_points = earnings$points * earnings$wins
earnings  %>% group_by(year, event, team) %>% summarise(dynasty = max(total_points)) -> dynasty
dynasty %>% group_by(year, team) %>% summarise(dynasty_score = mean(dynasty), dev=sd(dynasty, na.rm = T)) -> year_dynasty

team_dynasty <- year_dynasty %>% group_by(team) %>% summarise(score = mean(dynasty_score), var=min(sd(dev), score/2.0, na.rm=T))
write.csv(team_dynasty, "dynasty_scores.csv", row.names = F)
