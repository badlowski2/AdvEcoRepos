#' """ Workshop 5: Demographic matrix models
#'     @author: BSC 6926 B53
#'     date: 10/4/2022"""


# This workshop covers population demographic models.


## Matrix projection models
# When modeling populations, not are life stages are equal. There can be drastic differences in survival or reproductive output depending on the life stage. Therefore, it is important to consider the demography when modeling the population. This can be done with matrices to model structured populations. These models use a transition (also called projection) matrix ($A$) that represents mathematically all of the stages and transitions between stages in the population. The population at time $N_{t+1}$ can be found with the following formula that takes advantage of matrix multiplication: $$N_{t+1} = AN_t$$
  
  
  
## Matrices in R
# Another data structure that is useful in ecological uses of R are matrices. A matrix is made with the `matrix()` function with the basic syntax `matrix(data = , nrow = , ncol = , byrow = , dimnames = )`. 
# 
# `data =` the input vector which becomes the data elements of the matrix.
# 
# `nrow =` the number of rows to be created.
# 
# `ncol =` the number of columns to be created.
# 
# `byrow = FALSE` if `TRUE` then the input vector elements are arranged by row.
# 
# `dimname =` the names assigned to the rows and columns.

# make a matrix using nrow
m1 = matrix(c(1,2,3,4,5,6), nrow = 2)
m1 

# make a matrix using ncol
m2 = matrix(c(1,2,3,4,5,6), ncol = 2)
m2 

# make a matrix using nrow and by row
m3 = matrix(c(1,2,3,4,5,6), ncol = 2, byrow = T)
m3


### Indexing
# Matrices can be indexed in 2 ways

# make a matrix using ncol
m2 = matrix(c(1,2,3,4,5,6), ncol = 2)
m2 

m2[1,2]
m2[4]
# make a matrix using nrow and by row
m3 = matrix(c(1,2,3,4,5,6), ncol = 2, byrow = T)
m3

m3[1,2]
m3[4]

### Matrix algebra
# Matrix algebra can be done on matrices. There are specific matrix opperation like `%*%`, and  functions like `sum()`,`mean()`, `rowSums()`, `colSums()`, `rowMeans()`, and `colMeans()` can be used to sum up entire matrices or specific rows or columns. 


m2 = matrix(c(1,2,3,4,5,6), ncol = 3)
m2 

m2 + 1 
m2/3

m3 = matrix(c(1,2,3,4,5,6), ncol = 3, byrow = T)
m3

m2 + m3 
m3 - m2

# multply matrix with vector
v = c(1,2,3)

m2*v

# matrix multiplication 
m4 = matrix(c(1,2,3), ncol = 1)
m2 %*% m4

# functions with matrices
m2
sum(m2)
mean(m2)
rowSums(m2)
rowMeans(m2)
colSums(m2)
colMeans(m2)


### Random sampling of matrices
# sample matrices from list 
m1 = matrix(c(4,3,2,1), ncol = 2)
m2 = matrix(c(1,2,3,4), ncol = 2)
m3 = matrix(c(1,2,3,4), ncol = 2, byrow = T)

m = list(m1, m2, m3)

sample(m, size = 4, replace = T)

sample(m, size = 4, replace = T, prob = c(0.8, 0.1, 0.1))

## 2 stage matrix model
# The transition matrix ($A$) represents the growth, survival, and fecundity of each life stage. Here we use a simple two stage demographic model for a population with a distinct juvenile and adult stage (this can also represent seed and adult plant). The transition matrix can be represented as $$ A = \begin{bmatrix}
# p_{11}&F_{12} \\
# p_{21}&p_{22} \\
# \end{bmatrix}$$
#   where from time $t$ to $t + 1$  
# - $p_{11}$ is the probability juveniles survives and stays as a juvenile\
# - $p_{21}$ is the probability juveniles survives and transitions to an adult\
# - $p_{22}$ is the probability adults survives\
# - $F_{12}$ is contribution of adults to juveniles (e.g. reproduction)\

# setting up initial conditions 
p11 = 0
p21 = 0.2
p22 = 0.8
F12 = 1.5

# set up transition matrix 
A = matrix(c(p11, F12, p21, p22), byrow = T, ncol = 2)
A

# initial population conditions
juv = 50
ad = 100

#matrix of populations
p = matrix(c(juv, ad), ncol = 1)
p

# We can use `for` loops to simulate population dynamics 
library(tidyverse)
# set conditions
years = 50

# place to store data
pop = tibble(time = 0:years,
             Nt = NA, 
             juvs = NA,
             adults = NA)

pop$Nt[pop$time == 0] = sum(p)
pop$juvs[pop$time == 0] = p[1]
pop$adults[pop$time == 0] = p[2]

pop

for(i in 1:years){
  p = A %*% p
  pop$Nt[pop$time == i] = sum(p)
  pop$juvs[pop$time == i] = p[1]
  pop$adults[pop$time == i] = p[2]
}

df = pop %>% 
  pivot_longer(Nt:adults, names_to = 'stage', values_to = 'n') %>% 
  mutate(stage = factor(stage, levels = c('Nt','juvs','adults')))

ggplot(df, aes(time, n, color = stage)) +
  geom_point() +
  geom_line(size = 1) +
  labs(x = 'Time', y = 'Population size', color = 'Stage') +
  scale_color_manual(values = c('black', 'red', 'blue'))+
  theme_bw()

## `popbio`
# The package [`popbio`](https://www.researchgate.net/publication/5143026_Estimating_and_Analyzing_Demographic_Models_Using_the_popbio_Package_in_R) was developed for estimating and analyzing demographic models. This package can be useful as these models become more complex with more life stages.

### `pop.projection()`
# `popbio::pop.projection()` can be used to project population change and returns list of information about the model. \
# - `lambda` - estimate of lambda using change between the last two population counts\
# - `stable.stage` - estimate of stable stage distribution using proportions in last stage vector\
# - `stage.vector` - A matrix with the number of projected individuals in each stage class\
# - `pop.sizes` - total number of projected individuals \
# - `pop.changes` - proportional change in populations size \
# 
# For more information about calculating $\lambda$ and stable stage you can refer to [Chapter 4 of Steven Primer of Ecology using R](https://hankstevens.github.io/Primer-of-Ecology/DID.html) or Chapter 3 of Gotelli A primer of Ecology. 
# 

#install.packages('popbio')
library(popbio)
stages = c("seedling", "vegetative", "flowering")

# create projection matrix
A = matrix(c(0, 0, 5.905, 0.368, 0.639, 0.025, 0.001, 0.152, 0.051), 
           nrow = 3, byrow = TRUE, dimnames = list(stages, stages))

# vector of population sizes 
n = c(5, 5, 5)

# run model
p = pop.projection(A = A, n = n, iterations = 15)
p

stage.vector.plot(p$stage.vectors)

# Plot using ggplot

pp = tibble(time = as.numeric(colnames(p$stage.vectors)),
            seedling = p$stage.vectors[1,],
            vegetative = p$stage.vectors[2,],
            flowering = p$stage.vectors[3,],
            total = p$pop.sizes) %>% 
  pivot_longer(seedling:total, names_to = 'stage', values_to = 'n') %>% 
  mutate(stage = factor(stage, 
                        levels =c('total','seedling','vegetative','flowering')))

ggplot(pp, aes(time, n, color = stage)) +
  geom_point() +
  geom_line(size = 1) +
  labs(x = 'Time', y = 'Population size', color = 'Stage') +
  scale_color_manual(values = c('black', 'brown', 'green', 'pink'))+
  theme_bw()

### population variability and stochastic growth
# The `stoch.projection()` function came be used to project stochastic growth using whole matrix selection techniques in an independently and identically distributed (iid) environment from a set of two or more projection matrices. Returns a matrix listing final population sizes by stage class. 

#install.packages(popdemo)
library(popdemo)

data("hudsonia")
hudsonia

# starting population size
n = c(4264, 3, 30, 16, 25, 5)
names(n) = c("seed", "seedlings", "tiny", "small", "medium","large")

# projection with equal probabilities 
x.eq = stoch.projection(matrices = hudsonia, n0 = n, nreps = 100) %>% 
  as_tibble() %>% 
  mutate(time = row_number(),
         total = seed + seedlings + tiny + small + medium + large,
         type = 'equal')

x.eq

# unequal probabilities for projection matrices
x.uneq = stoch.projection(matrices = hudsonia, n0 = n, nreps = 100, prob = c(0.2, 0.2, 0.2, 0.4))%>% 
  as_tibble() %>% 
  mutate(time = row_number(),
         total = seed + seedlings + tiny + small + medium + large,
         type = 'unequal')

x.uneq

pop2 = bind_rows(x.eq,x.uneq)

ggplot(pop2, aes(time, total, color = type)) +
  geom_point() +
  geom_line(size = 1) +
  labs(x = 'Time', y = 'Population size', color = NULL) +
  theme_bw()


## Exercises 
# 1. Create a transition matrix for a 2 stage population where the the probability of stage 1 survival and stays in stage 1 = 0, the probability of survival of stage 1 and transition to stage 2 = 0.1, the survival of stage 2 = 0.8, and contribution of stage 2 to stage 1 = 2. 
# 
# 2. Use the transition matrix from exercise 1 to simulate 50 years of a population with a starting population of 50 individuals in stage 1 and 25 individuals in stage 2. Plot the results. 
# 
# 3. _Challenge_: Using the 3 matrices below. Simulate the same population above. Use a probability of 0.5 for average year, 0.3 for poor year, and 0.2 for good year. Plot your results\
# $$ average = \begin{bmatrix}
# 0&2 \\
# 0.1&0.8 
# \end{bmatrix}$$
#   $$
#   poor = \begin{bmatrix}
# 0&1 \\
# 0.1&0.6
# \end{bmatrix}$$
#   
#   $$ 
#   good = \begin{bmatrix}
# 0&3 \\
# 0.1&0.8
# \end{bmatrix}$$
