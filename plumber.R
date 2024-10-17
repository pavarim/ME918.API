# packages
library(plumber)
library(ggplot2)
library(dplyr)
library(farver)
library(jsonlite)

#* @apiTitle API Regressão Linear
# Variável global
# ra <- 185416
# set.seed(ra)
# b0 <- runif(1, -2, 2); b1 <- runif(1, -2, 2)
# bB <- 2; bC <- 3
# n <- 25
# x <- rpois(n, lambda = 4) + runif(n, -3, 3)
# grupo <- sample(LETTERS[1:3], size = n, replace = TRUE)
# y <- rnorm(n, mean = b0 + b1*x + bB*(grupo=="B") + bC*(grupo=="C"), sd = 2)
# df <- data.frame(x = x, grupo = grupo, y = y, momento_registro = lubridate::now(), 
#                  ID = seq(1, length(x)))
# readr::write_csv(df, file = "dados_regressao.csv")
df <- read.csv("dados_regressao.csv")

#* Adiciona uma nova observação
#* @param x Variável numérica
#* @param grupo Variável categórica
#* @param y Variável resposta
#* @post /add_row
function(x, grupo, y) {
  nova_pessoa <- data.frame(x = as.numeric(x), grupo = grupo, y = as.numeric(y),
                            momento_registro = lubridate::now(), ID = max(df$ID) + 1)
  readr::write_csv(nova_pessoa, "dados_regressao.csv", append = TRUE)
  df <<- rbind(df, nova_pessoa)
}

#* Remove observações pelo ID
#* @param ID Identificador da linha
#* @delete /delete_row
function(ID) {
  df <<- df[-as.numeric(ID), ]
  readr::write_csv(df, "dados_regressao.csv")
}

#* Modifica uma determinada observação
#* @param ID Identificador da linha
#* @param x Variável numérica
#* @param grupo Variável categórica
#* @param y Variável resposta
#* @put /change_row
function(ID, x, y, grupo) {
  df[as.numeric(ID), ] <<- data.frame(x = as.numeric(x), grupo = grupo, 
  y = as.numeric(y), momento_registro = lubridate::now(), ID = as.numeric(ID))
  readr::write_csv(df, "dados_regressao.csv")
}

#* Gera um gráfico de dispersão com a reta de regressão ajustada por categoria
#* @serializer png
#* @get /plot_lm
function() {
  grafico <- df %>% ggplot(aes(x = x, y = y, col = grupo)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) +
    theme_bw() +
    labs(title = "Gráfico de dispersão com a reta de regressão ajustada por categoria", 
         subtitle = "Dados simulados", x = colnames(df)[1], y = colnames(df)[3])
  print(grafico) 
}

#* Fornece as estimativas dos betas e da variância
#* @serializer json
#* @get /stats
function() {
  modelo <- lm(y ~ x + as.factor(grupo), data = df)
  resultado <- list(
    beta0 = modelo$coefficients[1],       
    beta1 = modelo$coefficients[2],          
    beta2 = modelo$coefficients[3],          
    beta3 = modelo$coefficients[4],          
    QME = anova(modelo)[3, 3]                
  )
  return(toJSON(resultado, pretty = TRUE))
}

#* Retorna todos os resíduos do modelo de regressão ajustado
#* @serializer json
#* @get /residuals
function() {
  modelo <- lm(y ~ x + as.factor(grupo), data = df)
  return(toJSON(modelo$residuals, pretty = TRUE))
}

#* Gera um gráfico dos resíduos do modelo de regressão ajustado
#* @serializer png
#* @get /plot_residuals
function() {
  modelo <- lm(y ~ x + as.factor(grupo), data = df)
  grafico <- df %>% ggplot(aes(sample = modelo$residuals)) +
    geom_qq() +
    theme_bw() +
    labs(title = "Gráfico dos resíduos do modelo de regressão ajustado", 
         subtitle = "Dados simulados", x = "Observação", y ="Resíduos")
  print(grafico) 
}

#* Retorna informações sobre a significância estatística dos parâmetros
#* @serializer json
#* @get /stats_p-values
function() {
  modelo <- lm(y ~ x + as.factor(grupo), data = df)
  resultado <- list(
    beta0 = summary(modelo)$coefficients[1, "Pr(>|t|)"],       
    beta1 = summary(modelo)$coefficients[2, "Pr(>|t|)"],          
    beta2 = summary(modelo)$coefficients[3, "Pr(>|t|)"],          
    beta3 = summary(modelo)$coefficients[4, "Pr(>|t|)"]
  )
  return(toJSON(resultado, pretty = TRUE))
}