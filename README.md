-- 01_qualidade_dados.sql
-- Objetivo: checar a qualidade dos dados antes da análise.

-- 1) Quantos pedidos existem por status?
-- Achado: 96.478 dos 99.441 pedidos (cerca de 97%) estão como 'delivered'.
-- Só esses entram na análise de entrega.
select order_status, count(*) as pedidos
from tb_orders
group by order_status
order by pedidos desc;

-- 2) Existem pedidos 'delivered' sem data de entrega?
-- Achado: 8 pedidos. Serão excluídos da análise de atraso.
select count(*) as pedidos_sem_data
from tb_orders
where order_status = 'delivered'
  and order_delivered_customer_date is null;
  
