-- 01_qualidade_dados.sql
-- Objetivo: checar a qualidade dos dados antes da análise.

-- 1) Quantos pedidos existem por status?
-- Achado: 96.478 dos 99.441 pedidos (cerca de 97%) estão como 'delivered'.
-- Só esses entram na análise de entrega.
SELECT order_status, COUNT(*) AS pedidos
FROM tb_orders
GROUP BY order_status
ORDER BY pedidos DESC;

-- 2) Existem pedidos 'delivered' sem data de entrega?
-- Achado: 8 pedidos. Serão excluídos da análise de atraso.
SELECT COUNT(*) AS pedidos_sem_data
FROM tb_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;
