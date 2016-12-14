require(dplyr)
read.csv("match_data.csv") -> all_data


c("qm" = 0.0000,
                "ef" = 0.0625,
                "qf" = 0.1250,
                "sf" = 0.2500,
                "f" = 0.5000)-> lookup

all_data$points = lookup[all_data$level]

# Lower bound points for now, todo compute event winner points
all_data %>% filter(win==T) %>% group_by(year, event, team) %>% summarise(points = max(points)) -> earnings
