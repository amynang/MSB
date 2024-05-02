library(tidyverse)

ch3_2 = read.csv("Chapter3/ch3_2_comparing_metrics-table.csv",
                 sep = ",", skip = 6) 

ch3_2 %>% group_by(X.run.number.) %>% filter(X.step. == max(X.step.)) %>% 
  ggplot(aes(x = similarity.threshold,
             y = average.similarity,
             color = as.factor(density))) +
  geom_point(position = position_jitter(.01)) +
  theme_classic()
ch3_2 %>% group_by(X.run.number.) %>% filter(X.step. == max(X.step.)) %>% 
  ggplot(aes(x = similarity.threshold,
             y = prop.uniform,
             color = as.factor(density))) +
  geom_point(position = position_jitter(.01)) +
  theme_classic()

ch3_2 %>% filter(X.run.number. == 294) %>% 
  ggplot(aes(x = X.step.,
             y = average.similarity)) +
  geom_line()
