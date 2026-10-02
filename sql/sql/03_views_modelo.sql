-- 03_views_modelo.sql
-- objetivo: criar as views que alimentam o power bi (modelo dimensional).
-- regras aplicadas (ver docs/qualidade_dados.md):
--   * só pedidos entregues e com data de entrega entram nos fatos.
--   * nota por pedido = média das avaliações do pedido.
--   * produto sem categoria vira 'sem categoria'.
--   * categoria sem tradução usa o nome original em português.

-- 1) fato de pedidos: uma linha por pedido entregue.
-- por que: é a base da pergunta principal (atraso x nota). o grão é o
-- pedido, e a nota já vem agregada para não duplicar pedidos.
create view vw_fato_pedidos as
select o.order_id,
       o.customer_id,
       date(o.order_purchase_timestamp) as data_compra,
       date(o.order_estimated_delivery_date) as data_estimada,
       date(o.order_delivered_customer_date) as data_entrega,
       round(julianday(o.order_delivered_customer_date)
             - julianday(o.order_purchase_timestamp), 1) as dias_entrega,
       case when o.order_delivered_customer_date
                 > o.order_estimated_delivery_date then 1 else 0 end as flag_atraso,
       i.receita_itens,
       i.frete,
       r.nota
from tb_orders o
left join (select order_id,
                  sum(price) as receita_itens,
                  sum(freight_value) as frete
           from tb_order_items
           group by order_id) i on i.order_id = o.order_id
left join (select order_id, avg(review_score) as nota
           from tb_order_reviews
           group by order_id) r on r.order_id = o.order_id
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null;

-- 2) dimensão de cliente: uma linha por customer_id.
-- por que: traz o estado e a cidade para a análise geográfica.
create view vw_dim_cliente as
select customer_id,
       customer_unique_id,
       customer_city as cidade,
       customer_state as estado
from tb_customers;

-- 3) dimensão de produto: uma linha por produto, com a categoria tratada.
-- por que: aplica a decisão do 4 e do 4b (sem categoria e sem tradução).
create view vw_dim_produto as
select p.product_id,
       coalesce(t.product_category_name_english,
                p.product_category_name,
                'sem categoria') as categoria
from tb_products p
left join tb_product_category_name_translation t
  on t.product_category_name = p.product_category_name;

-- 4) fato de itens: uma linha por item vendido, só de pedidos entregues.
-- por que: permite analisar atraso e receita por categoria e por vendedor.
create view vw_fato_itens as
select oi.order_id,
       oi.order_item_id,
       oi.product_id,
       oi.seller_id,
       oi.price as preco,
       oi.freight_value as frete
from tb_order_items oi
join vw_fato_pedidos f on f.order_id = oi.order_id;

-- 5) verificações (rode e compare com os achados abaixo).
-- achado esperado: 96.470 pedidos, 7.826 atrasados.
select count(*) as pedidos, sum(flag_atraso) as atrasados
from vw_fato_pedidos;

-- achado esperado: 110.189 itens e a receita de itens bate com a do fato
-- de pedidos (cerca de r$ 13,22 mi).
select count(*) as itens, round(sum(preco), 0) as receita
from vw_fato_itens;

-- achado esperado: 610 produtos 'sem categoria'.
select count(*) as sem_categoria
from vw_dim_produto
where categoria = 'sem categoria';
