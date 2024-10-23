# packages
library(plumber)
library(ggplot2)
library(dplyr)
library(farver)  # necessario para funcionar comptuadores do lab
library(jsonlite)
library(ggfocus)

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
# readr::write_csv(df, file = "dados/dados_regressao.csv")

df <- read.csv("dados/dados_regressao.csv")  # Recuperando dados anteriores
modelo <- lm(y ~ x + as.factor(grupo), data = df)  # Ajustando modelo


# Parte 2
#* Adiciona uma nova observação
#* @tag Dados
#* @param x Variável numérica
#* @param grupo Variável categórica
#* @param y Variável resposta
#* @post /data/add_row
function(x, grupo, y) {
  nova_pessoa <- data.frame(x = as.numeric(x), grupo = grupo, y = as.numeric(y),
                            momento_registro = lubridate::now(), ID = max(df$ID) + 1)
  readr::write_csv(nova_pessoa, "dados/dados_regressao.csv", append = TRUE)
  df <<- rbind(df, nova_pessoa)
  modelo <<- lm(y ~ x + as.factor(grupo), data = df)
  return(nova_pessoa)
}


# Parte 2 - Eletiva
#* Remove observações pelo ID
#* @tag Dados
#* @param ID Identificador da linha
#* @delete /data/delete_row
function(ID) {
  if (grepl(':', ID)) {
    ID <- as.numeric(unlist(strsplit(ID,":")))
    ID <- seq(ID[1], ID[2])
  }
  else {
    ID <- as.numeric(unlist(strsplit(ID, ",")))
  }
  df <<- df[!(df$ID %in% ID),]
  readr::write_csv(df, "dados/dados_regressao.csv")
  modelo <<- lm(y ~ x + as.factor(grupo), data = df)
  return(df)
}


# Parte 2 - Eletiva
#* Modifica uma observação pelo ID
#* @tag Dados
#* @param ID Identificador da linha
#* @param x Variável numérica
#* @param grupo Variável categórica
#* @param y Variável resposta
#* @put /data/change_row
function(ID, x, y, grupo) {
  df[df$ID == as.numeric(ID),] <<- data.frame(x = as.numeric(x), grupo = grupo, 
  y = as.numeric(y), momento_registro = lubridate::now(), ID = as.numeric(ID))
  readr::write_csv(df, "dados/dados_regressao.csv")
  modelo <<- lm(y ~ x + as.factor(grupo), data = df)
  return(df[df$ID == as.numeric(ID),])
}


# Parte 3
#* Gera um gráfico de dispersão com a reta de regressão ajustada por categoria
#* @tag Gráficos
#* @serializer png
#* @get /plot/lm
function(focus = NULL) {
  grafico <- df %>% ggplot(aes(x = x, y = y, col = grupo, alpha = grupo, group = grupo)) +
    geom_point(alpha=1) +
    geom_smooth(method = "lm", se = FALSE) +
    theme_bw() +
    labs(title = "Gráfico de dispersão com a reta de regressão ajustada por categoria",
         x = colnames(df)[1], y = colnames(df)[3])
  if (!(is.null(focus))) {
    focus <- unlist(strsplit(gsub(" ", "",focus), ","))
    grafico <- grafico +
      scale_alpha_focus(focus) +
      scale_color_focus(focus)
  }
  print(grafico)
}


# Parte 3
#* Fornece as estimativas dos betas e da variância
#* @tag Inferências
#* @serializer json
#* @get /fit/param
function() {
  resultado <- list(
    beta0 = modelo$coefficients[1],       
    beta1 = modelo$coefficients[2],          
    beta2 = modelo$coefficients[3],          
    beta3 = modelo$coefficients[4],          
    QME = anova(modelo)[3, 3]                
  )
  return(resultado)
}


# Parte 3 - Eletiva
#* Retorna todos os resíduos do modelo de regressão ajustado
#* @tag Inferências
#* @serializer json
#* @get /fit/residuals
function() {
  return(modelo$residuals)
}


# Parte 3 - Eletiva
#* Gera um gráfico dos resíduos do modelo de regressão ajustado
#* @tag Gráficos
#* @serializer png
#* @get /plot/residuals
function() {
  grafico <- df %>% ggplot(aes(sample = modelo$residuals)) +
    geom_qq() +
    theme_bw() +
    labs(title = "Gráfico dos resíduos do modelo de regressão ajustado",
         x = "Observação", y ="Resíduos")
  print(grafico) 
}


# Parte 3 - Eletiva
#* Retorna informações sobre a significância estatística dos parâmetros
#* @tag Inferências
#* @serializer json
#* @get /fit/p_values
function() {
  resultado <- list(
    beta0 = summary(modelo)$coefficients[1, "Pr(>|t|)"],       
    beta1 = summary(modelo)$coefficients[2, "Pr(>|t|)"],          
    beta2 = summary(modelo)$coefficients[3, "Pr(>|t|)"],          
    beta3 = summary(modelo)$coefficients[4, "Pr(>|t|)"]
  )
  return(resultado)
}


# Parte 4
#* Predição para novas observações
#* @tag Inferências
#* @param x Variável numérica
#* @param grupo Variável categórica
#* @serializer json
#* @parser json
#* @get /fit/pred
function(x, grupo) {
  x <- as.numeric(unlist(strsplit(x, ",")))
  grupo <- unlist(strsplit(gsub(" ", "",grupo), ","))
  newdata <- data.frame(x, grupo)
  pred <- predict(modelo, newdata)
  return(pred)
}
