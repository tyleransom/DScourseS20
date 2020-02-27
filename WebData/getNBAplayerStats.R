library(tidyverse, warn.conflict=FALSE)
library(magrittr)
library(nbastatR)

players <- seasons_players(2020, nest_data = F, return_message=T)

salaries <- hoopshype_salaries()

stats <- metrics_leaders(seasons=2020, metric = "pts", modes = "PerGame")

final <- left_join(salaries,stats, by=("namePlayer")) %>% drop_na(amountContract,fgm) %>% filter(slugSeason.x=="2019-20")

final %>% distinct(namePlayer, .keep_all=T) %>% select(namePlayer,slugTeam,amountContract,minutes,ftm,fta,fgm,fga,fg3m,pts,treb,ast,tov,eff) %>% write.csv("playerSalaryStats.csv")
