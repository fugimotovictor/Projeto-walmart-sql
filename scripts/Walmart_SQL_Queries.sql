CREATE DATABASE IF NOT EXISTS walmart;

USE walmart;

CREATE TABLE sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
vat FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 
'/Users/mohammedshehbazdamkar/Downloads/WalmartSalesData.csv.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


------------------- Engenharia de Atributos -----------------------------
1. Periodo_do_dia

SELECT time,
(CASE 
	WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Manha"
	WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Tarde"
	ELSE "Noite" 
END) AS periodo_do_dia
FROM sales;

ALTER TABLE sales ADD COLUMN periodo_do_dia VARCHAR(20);

UPDATE sales
SET periodo_do_dia = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Manha"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Tarde"
		ELSE "Noite" 
	END
);


2.Nome_Dia

SELECT date,
DAYNAME(date) AS nome_dia
FROM sales;

ALTER TABLE sales ADD COLUMN nome_dia VARCHAR(10);

UPDATE sales
SET nome_dia = DAYNAME(date);

3.Nome_mes

SELECT date,
MONTHNAME(date) AS nome_mes
FROM sales;

ALTER TABLE sales ADD COLUMN nome_mes VARCHAR(10);

UPDATE sales
SET nome_mes = MONTHNAME(date);


---------------- Análise Exploratória de Dados (EDA) ----------------------
Perguntas Gerais
-- 1. Quantas cidades distintas existem no conjunto de dados?
SELECT DISTINCT city FROM sales;

-- 2. Em qual cidade está localizada cada filial?
SELECT DISTINCT branch, city FROM sales;

Análise de Produtos
-- 1. Quantas linhas de produtos distintas existem no conjunto de dados?
SELECT COUNT(DISTINCT product_line) FROM sales;

-- 2. Qual é o método de pagamento mais comum?
SELECT payment, COUNT(payment) AS common_payment_method 
FROM sales GROUP BY payment ORDER BY common_payment_method DESC LIMIT 1;

-- 3. Qual é a linha de produtos mais vendida?
SELECT product_line, count(product_Line) AS most_selling_product
FROM sales GROUP BY product_line ORDER BY most_selling_product DESC LIMIT 1;

-- 4. Qual é a receita total por mês?
SELECT nome_mes, SUM(total) AS total_revenue
FROM SALES GROUP BY nome_mes ORDER BY total_revenue DESC;

-- 5. Qual mês registrou o maior COGS (custo dos produtos vendidos)?
SELECT nome_mes, SUM(cogs) AS total_cogs
FROM sales GROUP BY nome_mes ORDER BY total_cogs DESC;

-- 6. Qual linha de produto gerou a maior receita?
SELECT product_line, SUM(total) AS total_revenue
FROM sales GROUP BY product_line ORDER BY total_revenue DESC LIMIT 1;

-- 7. Qual cidade gerou a maior receita?
SELECT city, SUM(total) AS total_revenue
FROM sales GROUP BY city ORDER BY total_revenue DESC LIMIT 1;

-- 8. Qual linha de produto teve o maior imposto (VAT)?
SELECT product_line, SUM(vat) as VAT 
FROM sales GROUP BY product_line ORDER BY VAT DESC LIMIT 1;

-- 9. Recupere cada linha de produto e adicione a coluna product_category, indicando 'Bom' ou 'Ruim' de acordo com se suas vendas estão acima da média.

ALTER TABLE sales ADD COLUMN product_category VARCHAR(20);

UPDATE sales 
SET product_category= 
(CASE 
	WHEN total >= (SELECT AVG(total) FROM sales) THEN "Bom"
    ELSE "Ruim"
END)FROM sales;

-- 10. Qual filial vendeu mais produtos do que a média?
SELECT branch, SUM(quantity) AS quantity
FROM sales GROUP BY branch HAVING SUM(quantity) > AVG(quantity) ORDER BY quantity DESC LIMIT 1;

-- 11. Qual é a linha de produto mais comum por gênero?
SELECT gender, product_line, COUNT(gender) total_count
FROM sales GROUP BY gender, product_line ORDER BY total_count DESC;

-- 12. Qual é a avaliação média de cada linha de produto?
SELECT product_line, ROUND(AVG(rating),2) average_rating
FROM sales GROUP BY product_line ORDER BY average_rating DESC;


Análise de Vendas
-- 1. Número de vendas realizadas em cada período do dia por dia da semana
SELECT nome_dia, periodo_do_dia, COUNT(invoice_id) AS total_sales
FROM sales GROUP BY nome_dia, periodo_do_dia HAVING nome_dia NOT IN ('Sunday','Saturday');

SELECT nome_dia, periodo_do_dia, COUNT(*) AS total_sales
FROM sales WHERE nome_dia NOT IN ('Saturday','Sunday') GROUP BY nome_dia, periodo_do_dia;

-- 2. Identifique o tipo de cliente que gera a maior receita.
SELECT customer_type, SUM(total) AS total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales DESC LIMIT 1;

-- 3. Qual cidade tem o maior percentual de imposto (VAT)?
SELECT city, SUM(VAT) AS total_VAT
FROM sales GROUP BY city ORDER BY total_VAT DESC LIMIT 1;

-- 4. Qual tipo de cliente paga mais imposto (VAT)?
SELECT customer_type, SUM(VAT) AS total_VAT
FROM sales GROUP BY customer_type ORDER BY total_VAT DESC LIMIT 1;

Análise de Clientes

-- 1. Quantos tipos únicos de clientes existem no conjunto de dados?
SELECT COUNT(DISTINCT customer_type) FROM sales;

-- 2. Quantos métodos de pagamento únicos existem no conjunto de dados?
SELECT COUNT(DISTINCT payment) FROM sales;

-- 3. Qual é o tipo de cliente mais comum?
SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales GROUP BY customer_type ORDER BY common_customer DESC LIMIT 1;

-- 4. Qual tipo de cliente mais compra?
SELECT customer_type, SUM(total) as total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales LIMIT 1;

SELECT customer_type, COUNT(*) AS most_buyer
FROM sales GROUP BY customer_type ORDER BY most_buyer DESC LIMIT 1;

-- 5. Qual é o gênero da maioria dos clientes?
SELECT gender, COUNT(*) AS all_genders 
FROM sales GROUP BY gender ORDER BY all_genders DESC LIMIT 1;

-- 6. Qual é a distribuição de gênero por filial?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales GROUP BY branch, gender ORDER BY branch;

-- 7. Em qual período do dia os clientes mais dão avaliações?
SELECT periodo_do_dia, AVG(rating) AS average_rating
FROM sales GROUP BY periodo_do_dia ORDER BY average_rating DESC LIMIT 1;

-- 8. Em qual período do dia os clientes mais dão avaliações por filial?
SELECT branch, periodo_do_dia, AVG(rating) AS average_rating
FROM sales GROUP BY branch, periodo_do_dia ORDER BY average_rating DESC;

SELECT branch, periodo_do_dia,
AVG(rating) OVER(PARTITION BY branch) AS ratings
FROM sales GROUP BY branch;

-- 9. Qual dia da semana tem a melhor média de avaliações?
SELECT nome_dia, AVG(rating) AS average_rating
FROM sales GROUP BY nome_dia ORDER BY average_rating DESC LIMIT 1;

-- 10. Qual dia da semana tem a melhor média de avaliações por filial?
SELECT  branch, nome_dia, AVG(rating) AS average_rating
FROM sales GROUP BY nome_dia, branch ORDER BY average_rating DESC;

SELECT  branch, nome_dia,
AVG(rating) OVER(PARTITION BY branch) AS rating
FROM sales GROUP BY branch ORDER BY rating DESC;
