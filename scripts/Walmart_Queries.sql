CREATE DATABASE IF NOT EXISTS walmart;

USE walmart;

CREATE TABLE vendas(
id_fatura VARCHAR(30) NOT NULL PRIMARY KEY,
filial VARCHAR(5) NOT NULL,
cidade VARCHAR(30) NOT NULL,
tipo_cliente VARCHAR(30) NOT NULL,
genero VARCHAR(10) NOT NULL,
linha_produto VARCHAR(100) NOT NULL,
preco_unitario DECIMAL(10,2) NOT NULL,
quantidade INT(20) NOT NULL,
imposto_vat FLOAT(6,4) NOT NULL,
valor_total DECIMAL(12, 4) NOT NULL,
data DATETIME NOT NULL,
horario TIME NOT NULL,
metodo_pagamento VARCHAR(50) NOT NULL,
custo_mercadoria DECIMAL(10,2) NOT NULL,
margem_bruta_pct FLOAT(11,9),
renda_bruta DECIMAL(12, 4),
avaliacao FLOAT(2, 1)
);

--------------- Importação do Dataset (Table Data Import Wizard) -----------------

---Para facilitar o carregamento no MySQL Workbench, recomenda-se usar o assistente gráfico "Table Data Import Wizard" em vez do comando LOAD DATA LOCAL INFILE.

Passo a passo:
1. Abra o MySQL Workbench.
2. Selecione o banco de dados desejado (ex.: walmart).
3. Clique no menu: Server > Table Data Import Wizard.
4. Escolha o arquivo CSV: "Walmart_Sales_Data.csv".
5. Selecione a opção "Import into an existing table".
6. Escolha a tabela: vendas.
7. Faça o mapeamento das colunas se necessário.
8. Clique em Next e depois Finish.
9. O Workbench irá carregar todos os dados para a tabela.

------- Traduzir variáveis categóricas e numéricas para padrão brasileiro --------

-- TIPOS DE CLIENTE
UPDATE vendas
SET tipo_cliente = CASE tipo_cliente
  WHEN 'Member' THEN 'Membro'
  ELSE tipo_cliente
END;

-- GÊNERO
UPDATE vendas
SET genero = CASE genero
  WHEN 'Male'   THEN 'Masculino'
  WHEN 'Female' THEN 'Feminino'
  ELSE genero
END;

-- LINHA DE PRODUTO
UPDATE vendas
SET linha_produto = CASE linha_produto
  WHEN 'Electronic accessories' THEN 'Acessórios eletrônicos'
  WHEN 'Fashion accessories'    THEN 'Acessórios de moda'
  WHEN 'Food and beverages'     THEN 'Alimentos e bebidas'
  WHEN 'Health and beauty'      THEN 'Saúde e beleza'
  WHEN 'Home and lifestyle'     THEN 'Casa e estilo de vida'
  WHEN 'Sports and travel'      THEN 'Esportes e viagem'
  ELSE linha_produto
END;

-- MÉTODO DE PAGAMENTO
UPDATE vendas
SET metodo_pagamento = CASE metodo_pagamento
  WHEN 'Cash'        THEN 'Dinheiro'
  WHEN 'Credit card' THEN 'Cartão de crédito'
  WHEN 'Ewallet'     THEN 'Carteira digital'
  ELSE metodo_pagamento
END;


------------------- Feature Engineering -----------------------------
1. Periodo_do_dia

SELECT horario,
(CASE 
	WHEN `horario` BETWEEN "00:00:00" AND "12:00:00" THEN "Manha"
	WHEN `horario` BETWEEN "12:01:00" AND "16:00:00" THEN "Tarde"
	ELSE "Noite" 
END) AS periodo_do_dia
FROM vendas;

ALTER TABLE vendas ADD COLUMN periodo_do_dia VARCHAR(20);

UPDATE vendas
SET periodo_do_dia = (
	CASE 
		WHEN `horario` BETWEEN "00:00:00" AND "12:00:00" THEN "Manha"
		WHEN `horario` BETWEEN "12:01:00" AND "16:00:00" THEN "Tarde"
		ELSE "Noite" 
	END
);


2.Dia_semana

SET lc_time_names = 'pt_BR';

SELECT data,
DAYNAME(data) AS dia_semana
FROM vendas;

ALTER TABLE vendas ADD COLUMN dia_semana VARCHAR(10);

UPDATE vendas
SET dia_semana = DAYNAME(data);

3.Nome_mes

SELECT data,
MONTHNAME(data) AS nome_mes
FROM vendas;

ALTER TABLE vendas ADD COLUMN nome_mes VARCHAR(10);

UPDATE vendas
SET nome_mes = MONTHNAME(data);


---------------- Análise Exploratória de Dados (EDA) ----------------------
Perguntas Gerais
-- 1. Quantas cidades distintas existem no conjunto de dados?
SELECT DISTINCT cidade
FROM vendas;

-- 2. Em qual cidade está localizada cada filial?
SELECT DISTINCT 
  filial,
  cidade
FROM vendas;

Análise de Produtos
-- 1. Quantas linhas de produtos distintas existem no conjunto de dados?
SELECT COUNT(DISTINCT linha_produto)
FROM vendas;

-- 2. Qual é o método de pagamento mais comum?
SELECT
  metodo_pagamento,
  COUNT(metodo_pagamento) AS quantidade_pagamento
FROM vendas
GROUP BY metodo_pagamento
ORDER BY quantidade_pagamento
DESC LIMIT 1;

-- 3. Qual é a linha de produtos mais vendida?
SELECT
  linha_produto,
  COUNT(linha_produto) AS quantidade_produto
FROM vendas
GROUP BY linha_produto
ORDER BY quantidade_produto
DESC LIMIT 1;

-- 4. Qual é a receita total por mês?
SELECT
  nome_mes,
  SUM(valor_total) AS receita_total
FROM vendas
GROUP BY nome_mes
ORDER BY receita_total
DESC;

-- 5. Qual mês registrou o maior COGS (custo dos produtos vendidos)?
SELECT
  nome_mes,
  SUM(custo_mercadoria) AS total_custo_mercadoria
FROM vendas
GROUP BY nome_mes
ORDER BY total_custo_mercadoria
DESC;

-- 6. Qual linha de produto gerou a maior receita?
SELECT
  linha_produto,
  SUM(valor_total) AS receita_total_produto
FROM vendas
GROUP BY linha_produto
ORDER BY receita_total_produto
DESC LIMIT 1;

-- 7. Qual cidade gerou a maior receita?
SELECT
  cidade,
  SUM(valor_total) AS receita_total
FROM vendas
GROUP BY cidade
ORDER BY receita_total
DESC LIMIT 1;

-- 8. Qual linha de produto teve o maior imposto (VAT)?
SELECT
  linha_produto,
  SUM(imposto_vat) as imposto_vat 
FROM vendas
GROUP BY linha_produto
ORDER BY  imposto_vat
DESC LIMIT 1;

-- 9. Recupere cada linha de produto e adicione a coluna categoria_produto, indicando 'Bom' ou 'Ruim' de acordo com se suas vendas estão acima da média.

ALTER TABLE vendas ADD COLUMN categoria_produto VARCHAR(20);

UPDATE vendas
SET categoria_produto = 
    CASE 
        WHEN valor_total >= (SELECT AVG(valor_total) FROM (SELECT valor_total FROM vendas) AS t) 
        THEN 'Bom'
        ELSE 'Ruim'
    END;


-- 10. Qual filial vendeu mais produtos do que a média?
SELECT
  filial,
  SUM(quantidade)
FROM vendas
GROUP BY filial
HAVING
  SUM(quantidade) > AVG(quantidade)
ORDER BY quantidade
DESC LIMIT 1;

-- 11. Qual é a linha de produto mais comum por gênero?
SELECT
  genero, 
  linha_produto, 
  COUNT(genero) AS quantidade_genero
FROM vendas
GROUP BY
  genero,
  linha_produto
ORDER BY quantidade_genero
DESC;

-- 12. Qual é a avaliação média de cada linha de produto?
SELECT
  linha_produto,
  ROUND(AVG(avaliacao),2) AS avaliacao_media_produto
FROM vendas
GROUP BY linha_produto
ORDER BY avaliacao_media_produto
DESC;


Análise de Vendas
-- 1. Número de vendas realizadas em cada período do dia por dia da semana
SELECT
  dia_semana,
  periodo_do_dia,
  COUNT(id_fatura) AS quantidade_vendas
FROM vendas
GROUP BY
  dia_semana,
  periodo_do_dia
HAVING dia_semana
NOT IN 
  ('Domingo','Sabado');

-- 2. Identifique o tipo de cliente que gera a maior receita.
SELECT
  tipo_cliente,
  SUM(valor_total) AS valor_total
FROM vendas
GROUP BY tipo_cliente
ORDER BY valor_total
DESC LIMIT 1;

-- 3. Qual cidade tem o maior percentual de imposto (VAT)?
SELECT 
    cidade, 
    (SUM(imposto_vat) / SUM(valor_total)) * 100 AS percentual_imposto
FROM vendas
GROUP BY cidade
ORDER BY percentual_imposto
DESC LIMIT 1;

-- 4. Qual tipo de cliente paga mais imposto (VAT)?
SELECT
  tipo_cliente,
  SUM(imposto_vat) AS imposto_vat
FROM vendas
GROUP BY tipo_cliente
ORDER BY imposto_vat
DESC LIMIT 1;

Análise de Clientes

-- 1. Quantos tipos únicos de clientes existem no conjunto de dados?
SELECT COUNT(DISTINCT tipo_cliente)
FROM vendas;

-- 2. Quantos métodos de pagamento únicos existem no conjunto de dados?
SELECT COUNT(DISTINCT metodo_pagamento)
FROM vendas;

-- 3. Qual é o tipo de cliente mais comum?
SELECT
  tipo_cliente,
  COUNT(tipo_cliente) AS quantidade
FROM vendas
GROUP BY tipo_cliente
ORDER BY quantidade
DESC LIMIT 1;

-- 4. Qual tipo de cliente mais compra?
SELECT
  tipo_cliente,
  SUM(valor_total) as total_vendas
FROM vendas
GROUP BY tipo_cliente
ORDER BY total_vendas
LIMIT 1;

-- 5. Qual é o gênero da maioria dos clientes?
SELECT
  genero,
  COUNT(*) AS quantidade 
FROM vendas
GROUP BY genero
ORDER BY quantidade
DESC LIMIT 1;

-- 6. Qual é a distribuição de gênero por filial?
SELECT
  filial,
  genero,
  COUNT(genero) AS quantidade_genero
FROM vendas
GROUP BY
  filial,
  genero
ORDER BY filial;

-- 7. Em qual período do dia os clientes mais dão avaliações?
SELECT
  periodo_do_dia,
  AVG(avaliacao) AS avaliacao_media
FROM vendas
GROUP BY periodo_do_dia
ORDER BY avaliacao_media
DESC LIMIT 1;

-- 8. Em qual período do dia os clientes mais dão avaliações por filial?
SELECT
  filial,
  periodo_do_dia,
  AVG(avaliacao) AS avaliacao_media
FROM vendas
GROUP BY
  filial,
  periodo_do_dia
ORDER BY
  avaliacao_media
DESC;

-- 9. Qual dia da semana tem a melhor média de avaliações?
SELECT
  dia_semana,
  AVG(avaliacao) AS avaliacao_media
FROM vendas
GROUP BY dia_semana
ORDER BY avaliacao_media
DESC LIMIT 1;

-- 10. Qual dia da semana tem a melhor média de avaliações por filial?
SELECT
  filial,
  dia_semana,
  AVG(avaliacao) AS avaliacao_media
FROM vendas
GROUP BY
  dia_semana,
  filial
ORDER BY avaliacao_media
DESC;

