library(tidyverse)

ch3_3 = read.csv("Chapter3/ch3_3_make_it_stop-table.csv",
                 sep = ",", skip = 6) 

ch3_3 %>% group_by(X.run.number.) %>% filter(X.step. == max(X.step.)) %>% 
  ggplot(aes(x = similarity.threshold,
             y = X.step.,
             color = as.factor(density))) +
  geom_point(position = position_jitter(.01)) +
  theme_classic()
