library(plumber)
library(ggplot2)
library(dplyr)
library(farver)
library(jsonlite)

#* @apiTitle Plumber Example API
# Variável global
#ra <- 185416 #Insira o RA de um dos membros do grupo aqui
  #set.seed(ra)
#b0 <- runif(1, -2, 2); b1 <- runif(1, -2, 2)
#bB <- 2; bC <- 3
#n <- 25
#x <- rpois(n, lambda = 4) + runif(n, -3, 3)
#grupo <- sample(LETTERS[1:3], size = n, replace = TRUE)
#y <- rnorm(n, mean = b0 + b1*x + bB*(grupo=="B") + bC*(grupo=="C"), sd = 2)
#df <- data.frame(x = x, grupo = grupo, y = y, momento_registro = lubridate::now(),
                 #ID = seq(1, length(x)))
#readr::write_csv(df, file = "dados_regressao.csv")
df <- read.csv("dados_regressao.csv")


#* Echo back the input
#* @param x The message to echo
#* @param y
#* @param grupo
#* @post /add_row
function(x, y, grupo){
nova_pessoa <- data.frame(
  ID = max(df$ID)+1, x = as.numeric(x), y = as.numeric(y), grupo = grupo, momento_registro = lubridate::now())
  readr::write_csv(nova_pessoa, "dados_regressao.csv", append = TRUE)
  df <<- rbind(df, nova_pessoa)
}

#* Echo back the input
#* @param ID The message to echo
#* @delete  /del_row
function(ID){
  df <<- df[-as.numeric(ID), ]
  readr::write_csv(df, "dados_regressao.csv", append = TRUE)
}

#* Echo back the input
#* @param ID The message to echo
#* @param x The message to echo
#* @param y
#* @param grupo
#* @put  /mod_row
function(ID, x, y, grupo){
  df[as.numeric(ID), ] <<- data.frame(x = as.numeric(x), grupo = grupo, 
  y = as.numeric(y), momento_registro = lubridate::now(), ID = as.numeric(ID))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function(){
  grafico <- df %>% ggplot(aes(x = x, y = y, col = grupo)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    theme_bw()
  print(grafico) # Labels
}

#* @serializer json
#* @get /stats
function(){
  modelo <- lm(y ~ x + as.factor(grupo), data = df)
  return(toJSON(c(modelo$coefficients, anova(modelo)[3,3]))) # Colocar nomes
}


#* Return the sum of two numbers
#* @get /pred
function(a, b){
  as.numeric(a) + as.numeric(b)
}



