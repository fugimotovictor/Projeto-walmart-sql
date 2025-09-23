# Walmart - Análise de Dados de Vendas (Projeto em SQL)

## Sobre
Estamos analisando os dados de vendas do Walmart para identificar filiais e produtos de alto desempenho, analisar padrões de vendas de diferentes produtos e compreender o comportamento dos clientes. O objetivo principal é aprimorar e otimizar as estratégias de vendas.  
O conjunto de dados utilizado neste projeto é proveniente da Competição de Previsão de Vendas do Walmart no Kaggle.

## Objetivos do Projeto
O objetivo principal é obter insights a partir dos dados de vendas do Walmart, explorando os diversos fatores que influenciam as vendas em diferentes filiais.

## Sobre os Dados
Os dados foram obtidos na Competição de Previsão de Vendas do Walmart (Kaggle) e englobam transações de vendas de três filiais localizadas em Mandalay, Yangon e Naypyitaw.  

O dataset contém **17 colunas** e **1000 linhas**:

| Coluna            | Descrição                                      | Tipo de dado     |
|-------------------|-----------------------------------------------|------------------|
| invoice_id        | Nota fiscal da venda realizada                 | VARCHAR(30)      |
| branch            | Filial onde a venda foi realizada              | VARCHAR(5)       |
| city              | Localização da filial                          | VARCHAR(30)      |
| customer_type     | Tipo de cliente                                | VARCHAR(30)      |
| gender            | Gênero do cliente que realizou a compra        | VARCHAR(10)      |
| product_line      | Linha do produto vendido                       | VARCHAR(100)     |
| unit_price        | Preço unitário de cada produto                 | DECIMAL(10, 2)   |
| quantity          | Quantidade de produtos vendidos                | INT              |
| VAT               | Valor do imposto sobre a compra                | FLOAT(6, 4)      |
| total             | Valor total da compra                          | DECIMAL(12, 4)   |
| date              | Data da compra                                 | DATETIME         |
| time              | Horário da compra                              | TIME             |
| payment           | Método de pagamento utilizado                  | DECIMAL(10, 2)   |
| cogs              | Custo dos produtos vendidos (COGS)             | DECIMAL(10, 2)   |
| gross_margin_pct  | Percentual de margem bruta                     | FLOAT(11, 9)     |
| gross_income      | Receita bruta                                  | DECIMAL(12, 4)   |
| rating            | Avaliação dada pelo cliente                    | FLOAT(2, 1)      |

---

## Tipos de Análises

### 1. Análise de Produtos
- Identificar insights sobre as linhas de produtos.  
- Determinar quais linhas têm melhor desempenho.  
- Sugerir melhorias em linhas de baixo desempenho.  

### 2. Análise de Vendas
- Avaliar tendências de vendas ao longo do tempo.  
- Entender a eficiência das estratégias de vendas aplicadas.  
- Propor modificações para aumentar as vendas.  

### 3. Análise de Clientes
- Segmentar clientes.  
- Entender padrões de compra.  
- Avaliar a lucratividade de cada segmento.  

---

## Abordagem Utilizada

**1. Preparação de Dados (Data Wrangling)**  
- Criação do banco de dados e tabelas.  
- Inserção dos dados.  
- Checagem de valores nulos (não presentes devido ao uso de `NOT NULL`).  

**2. Engenharia de Atributos (Feature Engineering)**  
- `time_of_day`: Classifica vendas em **Manhã, Tarde ou Noite**.  
- `day_name`: Extrai o **dia da semana**.  
- `month_name`: Extrai o **mês da transação**.  

**3. Análise Exploratória de Dados (EDA)**  
- Responder às perguntas de negócio listadas.  

---

## Perguntas de Negócio

### Gerais
1. Quantas cidades distintas existem no dataset?  
2. Em qual cidade está localizada cada filial?  

### Produtos
1. Quantas linhas de produtos existem?  
2. Qual é o método de pagamento mais comum?  
3. Qual é a linha de produto mais vendida?  
4. Qual foi a receita total por mês?  
5. Qual mês teve o maior COGS (custo dos produtos vendidos)?  
6. Qual linha de produto gerou mais receita?  
7. Qual cidade gerou mais receita?  
8. Qual linha de produto teve maior imposto (VAT)?  
9. Criar coluna `product_category` classificando cada linha como "Boa" ou "Ruim" em relação à média.  
10. Qual filial vendeu mais produtos que a média?  
11. Qual é a linha de produtos mais comum por gênero?  
12. Qual a avaliação média por linha de produto?  

### Vendas
1. Número de vendas em cada horário do dia por dia da semana.  
2. Qual tipo de cliente gera mais receita?  
3. Qual cidade tem o maior percentual de imposto (VAT)?  
4. Qual tipo de cliente paga mais imposto?  

### Clientes
1. Quantos tipos únicos de clientes existem?  
2. Quantos métodos de pagamento únicos existem?  
3. Qual é o tipo de cliente mais comum?  
4. Qual tipo de cliente mais compra?  
5. Qual é o gênero mais frequente entre os clientes?  
6. Como é a distribuição de gênero por filial?  
7. Em qual horário do dia os clientes mais dão notas?  
8. Qual horário do dia tem mais avaliações por filial?  
9. Qual dia da semana tem a melhor média de notas?  
10. Qual dia da semana tem a melhor média de notas por filial?  
