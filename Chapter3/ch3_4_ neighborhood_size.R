library(tidyverse)

ch3_4 = read.csv("Chapter3/ch3_4_ neighborhood_size-table.csv",
                 sep = ",", skip = 6) 

ch3_4 %>% group_by(X.run.number.) %>% filter(X.step. == max(X.step.)) %>% 
  ggplot(aes(x = similarity.threshold,
             y = average.similarity,
             color = as.factor(density))) +
  geom_point(position = position_jitter(.01)) +
  facet_grid(~radius) +
  theme_classic()
