CREATE TEMPORARY TABLE temp_eta_cliente AS
SELECT
  c.id_cliente,
  YEAR(CURDATE()) - YEAR(c.data_nascita) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(c.data_nascita, '%m%d')) AS eta
FROM cliente c;


CREATE TEMPORARY TABLE temp_num_transazioni AS
SELECT
  c.id_cliente,
  SUM(CASE WHEN t.importo < 0 THEN 1 ELSE 0 END) AS num_trans_uscita,
  SUM(CASE WHEN t.importo >= 0 THEN 1 ELSE 0 END) AS num_trans_ingresso
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
GROUP BY c.id_cliente;

CREATE TEMPORARY TABLE temp_importo_transato AS
SELECT
  c.id_cliente,
  SUM(CASE WHEN t.importo < 0 THEN t.importo ELSE 0 END) AS importo_uscita,
  SUM(CASE WHEN t.importo >= 0 THEN t.importo ELSE 0 END) AS importo_ingresso
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
GROUP BY c.id_cliente;

CREATE TEMPORARY TABLE temp_num_conti_tipo AS
SELECT
  c.id_cliente,
  tc.desc_tipo_conto,
  COUNT(co.id_conto) AS num_conti_tipo
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente, tc.desc_tipo_conto;

CREATE TEMPORARY TABLE temp_num_transazioni_tipo AS
SELECT
  c.id_cliente,
  tc.desc_tipo_conto,
  SUM(CASE WHEN t.importo < 0 THEN 1 ELSE 0 END) AS num_trans_uscita_tipo,
  SUM(CASE WHEN t.importo >= 0 THEN 1 ELSE 0 END) AS num_trans_ingresso_tipo
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente, tc.desc_tipo_conto;

CREATE TEMPORARY TABLE temp_importo_transato_tipo AS
SELECT
  c.id_cliente,
  tc.desc_tipo_conto,
  SUM(CASE WHEN t.importo < 0 THEN t.importo ELSE 0 END) AS importo_uscita_tipo,
  SUM(CASE WHEN t.importo >= 0 THEN t.importo ELSE 0 END) AS importo_ingresso_tipo
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente, tc.desc_tipo_conto;

CREATE TEMPORARY TABLE temp_num_conti AS
SELECT
  id_cliente,
  COUNT(id_conto) AS num_conti
FROM conto
GROUP BY id_cliente;

CREATE TABLE indicatori_cliente AS
SELECT
  c.id_cliente,
  COALESCE(eta, 0) AS eta,
  COALESCE(num_trans_uscita, 0) AS num_trans_uscita,
  COALESCE(num_trans_ingresso, 0) AS num_trans_ingresso,
  COALESCE(importo_uscita, 0) AS importo_uscita,
  COALESCE(importo_ingresso, 0) AS importo_ingresso,
  COALESCE(num_conti, 0) AS num_conti,
  COALESCE(tnt.desc_tipo_conto, 0) AS tipo_conto,
  COALESCE(num_conti_tipo, 0) AS num_conti_tipo,
  COALESCE(num_trans_uscita_tipo, 0) AS num_trans_uscita_tipo,
  COALESCE(num_trans_ingresso_tipo, 0) AS num_trans_ingresso_tipo,
  COALESCE(importo_uscita_tipo, 0) AS importo_uscita_tipo,
  COALESCE(importo_ingresso_tipo, 0) AS importo_ingresso_tipo
FROM temp_eta_cliente c
LEFT JOIN temp_num_transazioni t ON c.id_cliente = t.id_cliente
LEFT JOIN temp_importo_transato i ON c.id_cliente = i.id_cliente
LEFT JOIN temp_num_conti nc ON c.id_cliente = nc.id_cliente
LEFT JOIN temp_num_conti_tipo nct ON c.id_cliente = nct.id_cliente
LEFT JOIN temp_num_transazioni_tipo tnt ON c.id_cliente = tnt.id_cliente AND nct.desc_tipo_conto = tnt.desc_tipo_conto
LEFT JOIN temp_importo_transato_tipo itt ON c.id_cliente = itt.id_cliente AND nct.desc_tipo_conto = itt.desc_tipo_conto;

select * from indicatori_cliente limit 20
