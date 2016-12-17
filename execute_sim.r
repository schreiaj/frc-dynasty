require(parallel)
require(dplyr)
require(reshape2)
read.csv("dynasty_scores.csv") -> team_dynasty

rnorm2 <- function(n,mean,sd) { mean+sd*scale(rnorm(n)) }


team_performance <- function(team, n = 5000) {
  team_data = team_dynasty[team_dynasty$team == team, ]
  score = team_data$score[1]
  if(is.na(score)) {
     score = mean(team_dynasty$score)
  }
  var = team_data$var[1]
  if(is.na(var) ){
        var = mean(team_dynasty$var)
  }
  rnorm2(n, score, var) 
}

run_event<- function (teams = c(), n=5) {
  team_scores <- sapply(teams, function(t) team_performance(as.character(t), n)) %>% t %>% data.frame
  team_scores$team = teams
  event_rankings <- sapply(head(colnames(team_scores), n=-1), function(x) arrange_(team_scores, paste('desc(', x, ')', sep=""))$team)
  melt(event_rankings, measure.vars = head(colnames(team_scores), n=-1)) -> melted
  melted$captain = as.numeric(melted$Var1 < 8)
  melted$eliminations = as.numeric(melted$Var1 < 24)
  group_by(melted, value) %>% summarise(
    avg = mean(Var1), 
    var = sd(Var1), 
    min=min(Var1), 
    max=max(Var1),
    captain = mean(captain),
    eliminations = mean(eliminations),
    runs = n()
  ) %>% arrange(avg)
  
}


parallel_run_event = function(teams = c(), groups = 1, perGroup = 2) {
  mclapply(seq(1:groups), function(i){run_event(teams, n=perGroup)}) %>%
    bind_rows %>% 
    group_by(value) %>% summarise(avg = mean(avg), var=mean(var), max=max(max), min=min(min), captain=mean(captain), eliminations=mean(eliminations), runs=sum(runs)) %>% arrange(avg)
}

get_teams_from_tba <- function(eventCode){
  endpoint <- paste("http://thebluealliance.com/api/v2/event/", eventCode ,"/teams", sep="")
  GET(endpoint, add_headers("X-TBA-App-Id" = "schreiaj:dynasty:v3")) %>% content("text") %>% fromJSON() -> event_data
  event_data$key
}