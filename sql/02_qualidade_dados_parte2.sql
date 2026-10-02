-- 02_qualidade_dados_parte2.sql
-- objetivo: continuar a checagem de qualidade antes da análise.

-- 3) quantos pedidos por mês? há meses com volume muito baixo?
-- achado: 2016 (09, 10 e 12) e 2018 (09 e 10) têm poucos pedidos
-- (de 1 a 324 por mês). a partir de 2017-01 todos os meses têm 800 ou
-- mais, chegando a mais de 7 mil em 2017-11 e em 2018.
-- mês com poucos pedidos distorce percentuais.
-- decisão: manter no total geral e limitar os gráficos mensais
-- a 01/2017 até 08/2018.
select substr(order_purchase_timestamp, 1, 7) as mes,
       count(*) as pedidos
from tb_orders
group by mes
order by mes;

-- 4) quantos produtos estão sem categoria?
-- achado: 610 produtos (cerca de 1,9% dos 32.951 do catálogo), todos null.
-- representam 1.603 itens vendidos (cerca de r$ 180 mil, 1,3% da
-- receita de itens), impacto pequeno.
-- decisão: manter no cálculo geral e agrupar como 'sem categoria'
-- nas análises por categoria.
select count(*) as produtos_sem_categoria
from tb_products
where product_category_name is null;

-- 4b) categorias sem tradução para o inglês
-- achado: 2 categorias não têm tradução: pc_gamer (3 produtos) e
-- portateis_cozinha_e_preparadores_de_alimentos (10 produtos).
-- decisão: usar o nome original em português nessas categorias, para
-- não perder os produtos ao juntar com a tabela de tradução.
select p.product_category_name, count(*) as produtos
from tb_products p
left join tb_product_category_name_translation t
  on t.product_category_name = p.product_category_name
where p.product_category_name is not null
  and t.product_category_name is null
group by p.product_category_name;

-- 5) existem pedidos com mais de uma avaliação?
-- achado: 555 pedidos têm mais de uma avaliação.
-- decisão oficial: usar a média das notas por pedido (um pedido = uma nota).
-- a view vw_fato_pedidos já aplica essa regra. teste de sensibilidade: 5d.
select count(*) as pedidos_com_varias_avaliacoes
from (
  select order_id
  from tb_order_reviews
  group by order_id
  having count(*) > 1
);

-- 5b) maior número de avaliações em um mesmo pedido
-- achado: o máximo é 3 avaliações por pedido. só 4 pedidos têm 3;
-- os outros 551 têm 2.
select order_id, count(*) as avaliacoes
from tb_order_reviews
group by order_id
having count(*) > 1
order by avaliacoes desc
limit 10;

-- 5c) pedidos com várias avaliações e notas diferentes entre si
-- achado: 209 dos 555 pedidos têm notas diferentes entre as avaliações.
-- a média pode esconder uma mudança de opinião do cliente.
select count(*) as pedidos_notas_diferentes
from (
  select order_id
  from tb_order_reviews
  group by order_id
  having count(*) > 1
     and min(review_score) <> max(review_score)
);

-- 5d) teste de sensibilidade: nota média, no prazo x atrasado,
-- com três regras para pedidos com várias avaliações.
-- achado: as três regras dão praticamente o mesmo resultado.
-- atrasados: 2,545 a 2,546. no prazo: 4,283 a 4,284.
-- conclusão: a escolha da regra não altera a conclusão do projeto.
with e as (
  select order_id,
         case when order_delivered_customer_date > order_estimated_delivery_date
              then 1 else 0 end as atrasado
  from tb_orders
  where order_status = 'delivered'
    and order_delivered_customer_date is not null
),
m as (
  select order_id, count(*) as n, avg(review_score) as media
  from tb_order_reviews
  group by order_id
),
u as (
  select order_id, review_score as ultima
  from (select order_id, review_score,
               row_number() over (partition by order_id
                                  order by review_answer_timestamp desc) as rn
        from tb_order_reviews)
  where rn = 1
)
select 'a. exclui' as regra, atrasado, count(*) as pedidos,
       round(avg(media), 3) as nota_media
from e join m using (order_id)
where n = 1
group by atrasado
union all
select 'b. media', atrasado, count(*), round(avg(media), 3)
from e join m using (order_id)
group by atrasado
union all
select 'c. ultima', atrasado, count(*), round(avg(ultima), 3)
from e join u using (order_id)
group by atrasado;
