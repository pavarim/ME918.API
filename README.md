
# API_Regressao_Linear

## Introdução

`API_Regressao_Linear` permite, desde a interatividade do banco de dados
à sua escolha, por meio de manipulações que realizam a adição,
modificação e remoção de observações, até a utilização de regressão
linear, que traz tanto as estimativas dos parâmetros quanto suas
significâncias, além de predições para novos dados e gráficos de
dispersão relacionados à reta de regressão ajustada e dos resíduos.

Ela foi criada e desenvolvida a partir do pacote `plumber` do R, que,
através da especificação `Swagger`, define uma estrutura de API,
facilitando a implementação e a verificação por meio de testes para
validar o comportamento da mesma.

# Uso

Para exemplificação, considere as seis primeiras observações de um banco
de dados simulado:

    ##            x grupo           y     momento_registro ID
    ## 1 -0.4507920     C  3.44753059 2024-10-22T03:26:05Z  1
    ## 2  7.2438838     A 13.50629387 2024-10-22T03:26:05Z  2
    ## 3  4.7304495     C  9.63047577 2024-10-22T03:26:05Z  3
    ## 4  4.0057026     A  5.69065916 2024-10-22T03:26:05Z  4
    ## 5  3.4586276     C  5.68649829 2024-10-22T03:26:05Z  5
    ## 6  0.1439889     B  0.08298869 2024-10-22T03:26:05Z  6

onde

- `x`: variável preditora de natureza númerica.
- `grupo`:variável preditora categórica.
- `y`:variável resposta.
- `momento_registro`: horário em que a observação foi gerada.
- `ID`: identificador responsável pela exclusividade da observação.

## Rotas

### Dados

`/data/add_row`: Rota responsável por adicionar uma nova observação por
requisição, recebendo os seguintes argumentos:

- `x`
- `grupo`
- `y`

`/data/delete_row`

### Inferência

### Gráficos
