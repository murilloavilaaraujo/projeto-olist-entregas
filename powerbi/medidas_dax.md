# Medidas DAX

Medidas criadas no Power BI para o dashboard de entregas e satisfação.

| Medida | Fórmula | O que faz |
|---|---|---|
| Pedidos | `DISTINCTCOUNT(fato_pedidos[order_id])` | Conta pedidos únicos |
| Pedidos Atrasados | `CALCULATE([Pedidos], fato_pedidos[flag_atraso] = 1)` | Conta só os pedidos entregues depois da data estimada |
| % Atraso | `DIVIDE([Pedidos Atrasados], [Pedidos])` | Proporção de pedidos atrasados |
| Nota Média | `AVERAGE(fato_pedidos[nota])` | Média das notas por pedido |
| Nota Média Atrasados | `CALCULATE([Nota Média], fato_pedidos[flag_atraso] = 1)` | Nota média só dos pedidos atrasados |
| Nota Média No Prazo | `CALCULATE([Nota Média], fato_pedidos[flag_atraso] = 0)` | Nota média só dos pedidos no prazo |
| Receita | `SUM(fato_pedidos[receita_itens])` | Soma da receita dos itens |
| % Atraso Destaque | `IF([% Atraso] > 0.10, [% Atraso], BLANK())` | Mostra o % de atraso só nos meses acima de 10%, para destacá-los no gráfico |

## Decisões

- Os gráficos mensais cobrem 01/2017 a 08/2018 (ver `docs/qualidade_dados.md`).
- A nota usada é a média das avaliações de cada pedido.
