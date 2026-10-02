# Qualidade dos dados

Checagens feitas no banco `olist.db` antes da análise. As consultas
estão em `sql/01_qualidade_dados.sql` e `sql/02_qualidade_dados_parte2.sql`.

## Resumo dos problemas e decisões

| # | Verificação | Achado | Decisão |
|---|---|---|---|
| 1 | Pedidos por status | 96.478 de 99.441 pedidos (cerca de 97%) estão como `delivered` | Só pedidos entregues entram na análise de entrega |
| 2 | Entregues sem data de entrega | 8 pedidos | Excluídos da análise de atraso |
| 3 | Pedidos por mês | 2016 (09, 10 e 12) e 2018 (09 e 10) têm de 1 a 324 pedidos; os demais meses têm 800 ou mais | Mantidos no total geral; gráficos mensais limitados a 01/2017–08/2018 |
| 4 | Produtos sem categoria | 610 produtos (1,9%), 1.603 itens vendidos (cerca de R$ 180 mil, 1,3% da receita de itens) | Mantidos e agrupados como "sem categoria" |
| 4b | Categorias sem tradução | `pc_gamer` (3 produtos) e `portateis_cozinha_e_preparadores_de_alimentos` (10 produtos) | Usar o nome original em português |
| 5 | Pedidos com várias avaliações | 555 pedidos (551 com 2 avaliações e 4 com 3); em 209 as notas divergem | Usar a média das notas por pedido (um pedido = uma nota) |

## Teste de sensibilidade (avaliações)

Para escolher a regra, comparei três tratamentos para pedidos com
várias avaliações, sobre os pedidos entregues:

| Regra | Nota média, no prazo | Nota média, atrasado |
|---|---|---|
| A. Excluir pedidos com várias avaliações | 4,284 | 2,546 |
| B. Média das notas do pedido (adotada) | 4,284 | 2,546 |
| C. Última avaliação | 4,283 | 2,545 |

**Conclusão:** o resultado praticamente não muda entre as regras
(só cerca de 0,6% dos pedidos entregues têm várias avaliações),
então a escolha não altera a conclusão do projeto. Adotei a regra B
porque não descarta pedidos e evita contar o mesmo pedido duas vezes.

**Limitação:** em 209 pedidos as notas são diferentes entre si, e a
média pode esconder uma mudança de opinião do cliente.

## Fonte dos dados

Brazilian E-Commerce Public Dataset by Olist (Kaggle). Projeto  
pessoal de estudo, sem vínculo com a Olist.    
