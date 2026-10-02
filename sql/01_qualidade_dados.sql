-- 01_qualidade_dados.sql
-- objetivo: checar a qualidade dos dados antes da análise.

-- 1) quantos pedidos existem por status?
-- achado: 96.478 dos 99.441 pedidos (cerca de 97%) estão como 'delivered'.
-- só esses entram na análise de entrega.
select order_status, count(*) as pedidos
from tb_orders
group by order_status
order by pedidos desc;

-- 2) existem pedidos 'delivered' sem data de entrega?
-- achado: 8 pedidos. serão excluídos da análise de atraso.
select count(*) as pedidos_sem_data
from tb_orders
where order_status = 'delivered'
  and order_delivered_customer_date is null;
