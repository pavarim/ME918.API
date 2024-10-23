
# API_Regressao_Linear

## Introdução

`API_Regressao_Linear` permite, desde a interatividade do banco de dados
à sua escolha, por meio de manipulações que realizam a adição,
modificação e remoção de observações, até a utilização de regressão
linear, que traz tanto as estimativas dos parâmetros quanto suas
significâncias, além de predições para novos dados e gráficos de
dispersão relacionados à reta de regressão ajustada e dos resíduos.

Ela foi criada e desenvolvida a partir do pacote `plumber` do R, que,
através da especificação `Swagger`, define uma estrutura de API a partir
de rotas, facilitando a implementação e a verificação por meio de testes
para validar o comportamento da mesmas.

## Uso

Para exemplificação, considere o seguinte banco de dados simulado com
cinco observações:

    ##           x grupo         y    momento_registro ID
    ## 1 3.3086101     B  5.973492 2024-10-22 21:12:00  1
    ## 2 5.7396884     C 13.826110 2024-10-22 21:12:00  2
    ## 3 9.7410001     A 11.482025 2024-10-22 21:12:00  3
    ## 4 0.7200049     C  3.457060 2024-10-22 21:12:00  4
    ## 5 5.0654238     C  5.894075 2024-10-22 21:12:00  5

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

Para exemplificar, considere a seguinte requisição
`x = 10, grupo = A, y = 15`.

    ##           x grupo         y    momento_registro ID
    ## 1 3.3086101     B  5.973492 2024-10-22 21:12:00  1
    ## 2 5.7396884     C 13.826110 2024-10-22 21:12:00  2
    ## 3 9.7410001     A 11.482025 2024-10-22 21:12:00  3
    ## 4 0.7200049     C  3.457060 2024-10-22 21:12:00  4
    ## 5 5.0654238     C  5.894075 2024-10-22 21:12:00  5
    ## 6 7.4358004     A 10.314954 2024-10-22 21:12:00  6

`/data/delete_row`: Rota que exclui observações de três maneiras
diferentes, recebendo como argumento o `ID`. A primeira forma é feita
excluindo uma única observação. Suponha que deseja-se excluir o
`ID = 1`.

    ##           x grupo         y    momento_registro ID
    ## 2 5.7396884     C 13.826110 2024-10-22 21:12:00  2
    ## 3 9.7410001     A 11.482025 2024-10-22 21:12:00  3
    ## 4 0.7200049     C  3.457060 2024-10-22 21:12:00  4
    ## 5 5.0654238     C  5.894075 2024-10-22 21:12:00  5
    ## 6 7.4358004     A 10.314954 2024-10-22 21:12:00  6

Em certos casos, é preferível excluir uma sequência de observações, por
meio da sequência `1:3`.

    ##           x grupo         y    momento_registro ID
    ## 4 0.7200049     C  3.457060 2024-10-22 21:12:00  4
    ## 5 5.0654238     C  5.894075 2024-10-22 21:12:00  5
    ## 6 7.4358004     A 10.314954 2024-10-22 21:12:00  6

Por fim, a terceira maneira é utilizando vetores como `2, 4, 6`.

    ##          x grupo         y    momento_registro ID
    ## 1 3.308610     B  5.973492 2024-10-22 21:12:00  1
    ## 3 9.741000     A 11.482025 2024-10-22 21:12:00  3
    ## 5 5.065424     C  5.894075 2024-10-22 21:12:00  5

`/data/change_row`: Rota que modifica uma única observação por
requisição. Para isso, é necessário especificar os argumentos:

- `ID`
- `x`
- `y`
- `grupo`

Se o interesse é alterar a observação de `ID = 6` para `x = 5`,
`y = 10`, `grupo = C`.

    ##           x grupo         y    momento_registro ID
    ## 1 3.3086101     B  5.973492 2024-10-22 21:12:00  1
    ## 2 5.7396884     C 13.826110 2024-10-22 21:12:00  2
    ## 3 9.7410001     A 11.482025 2024-10-22 21:12:00  3
    ## 4 0.7200049     C  3.457060 2024-10-22 21:12:00  4
    ## 5 5.0654238     C  5.894075 2024-10-22 21:12:00  5
    ## 6 5.0000000     C 10.000000 2024-10-22 21:12:00  6

### Inferência

`/fit/param`: Rota que fornece as estimativas dos parâmetros da
regressão.

    ## {
    ##   "beta_0": [-3.1872],
    ##   "beta_1": [0.6248],
    ##   "beta_2": [2.5642],
    ##   "beta_3": [4.4997],
    ##   "QME": [5.2567]
    ## }

`/fit/residuals`: Rota que retorna todos os resíduos da regressão. Nesse
exemplo é exibido apenas os seis primeiros.

    ## [-1.5131,-1.2313,-1.3551,-0.9376,-1.8813,-1.5385]

`/fit/p_values`: Rota que informa sobre a significância estatística dos
parâmetros

    ## {
    ##   "beta_0": [-3.1872],
    ##   "beta_1": [0.6248],
    ##   "beta_2": [2.5642],
    ##   "beta_3": [4.4997],
    ##   "QME": [5.2567]
    ## }

`/fit/pred`: Rota que realiza predições para novas observações.
Especificando na requisição `x = 10` e `grupo = B`.

    ## [11.874]

Além disso, essa rota pode retornar mais de uma predição, caso a
requisição seja, por exemplo, `x = 10, 20` e `grupo = B, A`.

    ## [11.874,3.0613]

### Gráficos

Considere que foi necessário adicionar mais observações para a
ilustração da regressão nos gráficos.

`/plot/lm`: Rota responsável por gerar o gráfico de dispersão juntamente
com a reta de regressão ajustada. Há um argumento opcional `focus` que
destaca o grupo desejado. Caso não seja passado nenhum argumento, a
saída é

![](README_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

Supondo que queremos focar no grupo `A`. Além disso, mais de um grupo
pode ser especificado utilizando a vírgula para separá-los.

![](README_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

`/plot/residuals`: Rota que realiza a requisição do gráfico de resíduos
da regressão.

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->
