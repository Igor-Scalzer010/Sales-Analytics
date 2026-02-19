-- Total de vendas
SELECT COUNT(*) AS total_vendas from sales;

-- Distribuição de vendas por ano
SELECT
    EXTRACT(YEAR FROM sale_date) AS ano,
    COUNT(*) AS total_vendas_por_ano
FROM sales
GROUP BY ano
ORDER BY ano;

-- Quntidade de produtos vendidos por mês e o faturamento total do mês
SELECT
    TO_CHAR(sale_date, 'YYYY-MM') AS ano_mês,
    COUNT(*) AS total_vendas_por_mês,
    ROUND(SUM(unit_price_at_sale * quantity)::NUMERIC, 2) AS total_faturamento_por_mês
FROM sales
GROUP BY ano_mês
ORDER BY ano_mês;

-- Comparativo YoY de receita mensal
SELECT
    EXTRACT(MONTH FROM sale_date)::INTEGER AS mês,
    SUM(
        CASE WHEN EXTRACT(YEAR FROM sale_date) = 2025
            THEN unit_price_at_sale * quantity - discount
        ELSE 0 END
    ) AS receita_2025,
    SUM(
        CASE WHEN EXTRACT(YEAR FROM sale_date) = 2026
            THEN unit_price_at_sale * quantity - discount
        ELSE 0 END
    ) AS receita_2026
FROM sales
GROUP BY mês
ORDER BY mês;

-- Venda por região (verificamos a sazonalidade por região)
SELECT
    s.region,
    COUNT(*) AS total_vendas_por_região,
    ROUND(SUM(sa.unit_price_at_sale * sa.quantity - sa.quantity)::NUMERIC, 2) AS total_faturamento_por_região
FROM sales sa
JOIN stores s ON s.id = sa.store_id
GROUP BY s.region
ORDER BY total_faturamento_por_região DESC;

-- Canal de venda mais eficiente e qual a participação (percentual) de cada canal no ano.
-- Exemplo: loja_física teve 218 vendas em 2025, e a sua participação no total de vendas do ano foi de 44.95%
WITH vendas_por_canal AS (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS ano,
        sales_channel,
        COUNT(*) AS total_vendas
    FROM sales
    GROUP BY ano, sales_channel
),
total_vendas_ano AS (
    SELECT
        ano,
        SUM(total_vendas) AS total_vendas_ano
    FROM vendas_por_canal
    GROUP BY ano
)
SELECT
    v.ano,
    v.sales_channel,
    v.total_vendas,
    ROUND(v.total_vendas::NUMERIC / t.total_vendas_ano * 100, 2) AS percentual_vendas
FROM vendas_por_canal v
JOIN total_vendas_ano t
    ON t.ano = v.ano
ORDER BY v.ano, v.total_vendas DESC;