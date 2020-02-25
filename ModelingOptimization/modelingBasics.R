library(tidyverse)

# Use the motor trend cars data set
df <- as_tibble(mtcars)

# mpg = b0 + b1*hp + b2*wt
est <- lm(mpg ~ hp + wt, data=df)
summary(est)

# plot regression line
ggplot(df,aes(hp,mpg)) +
    geom_point() +
    geom_smooth(method='lm')

## Prediction problem
# what is mpg of a car with 3000 lbs and 160 hp?
mpg_hat <- 37.22727 - 0.03177*160 - 3.87783*3

## Causal inference problem
# what would mpg of car be if I reduced wt by 500 lbs?
mpg_diff <- -3.87783*(-.5)

# New model: V engine or Straight engine?
est <- glm(vs ~ hp + wt, data=df, family = "binomial")
est1<- glm(as.factor(vs) ~ hp + wt, data=df, family = "binomial") # same thing

## Prediction problem: what is Pr(V=1) if hp = 160, wt=3000?
p <- exp(7.41037 - 0.08535*160 + 1.00334*3)/
    (1+exp(7.41037 - 0.08535*160 + 1.00334*3))
## R does it for us
newdf <- df %>% mutate(hp=160,wt=3) # first create a data frame at the values of X that we want
zero.one.r <- predict(est, newdata = newdf) # to output the inside of the sigmoid function
prob.r <- predict(est, newdata = newdf, type = "response") # to output a probability
