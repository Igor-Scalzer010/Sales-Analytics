-- ============================================
-- GERAR 1000 VENDAS REALISTAS
-- Período: Janeiro/2025 a Dezembro/2026 (2 anos completos)
-- ============================================
-- Lógica de distribuição:
--   - ~500 vendas em 2025, ~500 vendas em 2026
--   - 2026 tem leve crescimento (~5-10%) para simular empresa saudável
--   - Nov/Dez têm mais vendas (Black Friday + Natal) em ambos os anos
--   - Jan/Fev têm queda natural (pós-festas)
--   - Sudeste concentra ~45% das vendas
-- ============================================

DO $$
DECLARE
    i                   INTEGER;
    v_employee_id       INTEGER;
    v_product_id        INTEGER;
    v_store_id          INTEGER;
    v_quantity          INTEGER;
    v_unit_price        NUMERIC(10,2);
    v_cost_price        NUMERIC(10,2);
    v_discount          NUMERIC(10,2);
    v_sale_date         TIMESTAMP WITH TIME ZONE;
    v_payment           VARCHAR(30);
    v_channel           VARCHAR(30);
    v_customer          VARCHAR(200);
    v_month             INTEGER;
    v_day               INTEGER;
    v_hour              INTEGER;
    v_minute            INTEGER;
    v_rand              DOUBLE PRECISION;
    v_month_rand        DOUBLE PRECISION;
    v_price_variation   NUMERIC(10,2);
    v_year              INTEGER;

    -- Arrays
    customers           TEXT[] := ARRAY[
        'João Mendes','Maria Aparecida','Carlos Eduardo','Ana Beatriz','Paulo Ricardo',
        'Fernanda Lima','Ricardo Souza','Juliana Costa','Marcos Antônio','Luciana Ferreira',
        'André Luiz','Patrícia Gomes','Rodrigo Alves','Camila Rocha','Gustavo Henrique',
        'Adriana Santos','Leandro Vieira','Cristiane Oliveira','Fábio Augusto','Simone Teixeira',
        'Daniel Barbosa','Priscila Nunes','Tiago Moreira','Renata Cardoso','Matheus Pinto',
        'Alessandra Dias','Leonardo Correia','Bianca Monteiro','Hugo Freitas','Débora Ramos',
        NULL, NULL, NULL, NULL, NULL  -- ~15% sem nome (venda rápida sem cadastro)
    ];
BEGIN
    FOR i IN 1..1000 LOOP

        -- =====================================================
        -- 1. ANO: ~48% em 2025, ~52% em 2026 (leve crescimento)
        -- =====================================================
        IF random() < 0.48 THEN
            v_year := 2025;
        ELSE
            v_year := 2026;
        END IF;

        -- =====================================================
        -- 2. MÊS (com sazonalidade realista)
        --    Jan/Fev: baixo (pós-festas)
        --    Mar-Out: estável
        --    Nov: alto (Black Friday)
        --    Dez: alto (Natal)
        -- =====================================================
        -- Pesos por mês (somam ~1.0):
        --   Jan: 0.06  Fev: 0.06  Mar: 0.07  Abr: 0.07
        --   Mai: 0.08  Jun: 0.08  Jul: 0.08  Ago: 0.08
        --   Set: 0.08  Out: 0.08  Nov: 0.13  Dez: 0.13
        -- =====================================================
        v_month_rand := random();
        IF v_month_rand < 0.06 THEN
            v_month := 1;    -- Janeiro (baixo)
        ELSIF v_month_rand < 0.12 THEN
            v_month := 2;    -- Fevereiro (baixo)
        ELSIF v_month_rand < 0.19 THEN
            v_month := 3;    -- Março
        ELSIF v_month_rand < 0.26 THEN
            v_month := 4;    -- Abril
        ELSIF v_month_rand < 0.34 THEN
            v_month := 5;    -- Maio (Dia das Mães impulsiona)
        ELSIF v_month_rand < 0.42 THEN
            v_month := 6;    -- Junho (Dia dos Namorados)
        ELSIF v_month_rand < 0.50 THEN
            v_month := 7;    -- Julho
        ELSIF v_month_rand < 0.58 THEN
            v_month := 8;    -- Agosto (Dia dos Pais)
        ELSIF v_month_rand < 0.66 THEN
            v_month := 9;    -- Setembro
        ELSIF v_month_rand < 0.74 THEN
            v_month := 10;   -- Outubro (Dia das Crianças)
        ELSIF v_month_rand < 0.87 THEN
            v_month := 11;   -- Novembro (Black Friday)
        ELSE
            v_month := 12;   -- Dezembro (Natal)
        END IF;

        -- Dia (1 a 28 para evitar problemas com meses curtos)
        v_day    := 1 + floor(random() * 27)::INTEGER;
        -- Horário comercial estendido (08h às 22h)
        v_hour   := 8 + floor(random() * 14)::INTEGER;
        v_minute := floor(random() * 60)::INTEGER;

        v_sale_date := make_timestamptz(v_year, v_month, v_day, v_hour, v_minute, 0, 'America/Sao_Paulo');

        -- =====================================================
        -- 3. LOJA (Sudeste ~45%, distribuição realista por PIB)
        -- =====================================================
        v_rand := random();
        IF v_rand < 0.20 THEN
            v_store_id := 1;   -- SP (maior mercado)
        ELSIF v_rand < 0.35 THEN
            v_store_id := 2;   -- RJ
        ELSIF v_rand < 0.45 THEN
            v_store_id := 3;   -- MG
        ELSIF v_rand < 0.55 THEN
            v_store_id := 4;   -- PR
        ELSIF v_rand < 0.62 THEN
            v_store_id := 5;   -- RS
        ELSIF v_rand < 0.70 THEN
            v_store_id := 6;   -- PE
        ELSIF v_rand < 0.78 THEN
            v_store_id := 7;   -- BA
        ELSIF v_rand < 0.86 THEN
            v_store_id := 8;   -- DF
        ELSIF v_rand < 0.93 THEN
            v_store_id := 9;   -- GO
        ELSE
            v_store_id := 10;  -- AM
        END IF;

        -- =====================================================
        -- 4. FUNCIONÁRIO (da mesma loja)
        --    Cada loja tem 3 funcionários: ids (store_id-1)*3+1 até (store_id-1)*3+3
        -- =====================================================
        v_employee_id := (v_store_id - 1) * 3 + (1 + floor(random() * 3)::INTEGER);

        -- =====================================================
        -- 5. PRODUTO (40 produtos, com pesos realistas)
        --    Produtos populares/baratos vendem mais
        -- =====================================================
        v_rand := random();
        IF v_rand < 0.25 THEN
            -- Smartphones (best sellers) - ids 1 a 5
            v_product_id := 1 + floor(random() * 5)::INTEGER;
        ELSIF v_rand < 0.40 THEN
            -- Acessórios e Periféricos (volume alto, ticket baixo) - ids 29 a 35
            v_product_id := 29 + floor(random() * 7)::INTEGER;
        ELSIF v_rand < 0.52 THEN
            -- Notebooks - ids 6 a 10
            v_product_id := 6 + floor(random() * 5)::INTEGER;
        ELSIF v_rand < 0.62 THEN
            -- Áudio e Fones - ids 24 a 28
            v_product_id := 24 + floor(random() * 5)::INTEGER;
        ELSIF v_rand < 0.72 THEN
            -- Televisores - ids 14 a 17
            v_product_id := 14 + floor(random() * 4)::INTEGER;
        ELSIF v_rand < 0.80 THEN
            -- Eletrodomésticos - ids 18 a 23
            v_product_id := 18 + floor(random() * 6)::INTEGER;
        ELSIF v_rand < 0.90 THEN
            -- Armazenamento - ids 36 a 40
            v_product_id := 36 + floor(random() * 5)::INTEGER;
        ELSE
            -- Desktop - ids 11 a 13
            v_product_id := 11 + floor(random() * 3)::INTEGER;
        END IF;

        -- Buscar preço do produto
        SELECT unit_price, cost_price INTO v_unit_price, v_cost_price
        FROM products WHERE id = v_product_id;

        -- =====================================================
        -- 6. SIMULAÇÃO DE INFLAÇÃO/REAJUSTE para 2026
        --    Produtos ficam ~4-6% mais caros em 2026 (realista)
        -- =====================================================
        IF v_year = 2026 THEN
            v_unit_price := v_unit_price * (1.04 + random() * 0.02);
        END IF;

        -- =====================================================
        -- 7. QUANTIDADE (realista conforme faixa de preço)
        -- =====================================================
        IF v_unit_price > 3000 THEN
            v_quantity := 1;                                       -- Itens caros: sempre 1
        ELSIF v_unit_price > 500 THEN
            v_quantity := 1 + floor(random() * 2)::INTEGER;       -- 1 a 2
        ELSIF v_unit_price > 100 THEN
            v_quantity := 1 + floor(random() * 3)::INTEGER;       -- 1 a 3
        ELSE
            v_quantity := 1 + floor(random() * 5)::INTEGER;       -- 1 a 5
        END IF;

        -- =====================================================
        -- 8. PREÇO NA VENDA (variação natural de ±3%)
        -- =====================================================
        v_price_variation := v_unit_price * (0.97 + random() * 0.06);
        v_unit_price := round(v_price_variation, 2);

        -- =====================================================
        -- 9. DESCONTO
        --    - Nov/Dez: descontos mais agressivos (Black Friday/Natal)
        --    - Demais meses: descontos moderados
        -- =====================================================
        v_rand := random();
        IF v_month IN (11, 12) THEN
            -- Black Friday / Natal
            IF v_rand < 0.25 THEN
                v_discount := 0;
            ELSIF v_rand < 0.50 THEN
                v_discount := round((v_unit_price * v_quantity * (0.03 + random() * 0.05))::NUMERIC, 2);  -- 3-8%
            ELSE
                v_discount := round((v_unit_price * v_quantity * (0.08 + random() * 0.07))::NUMERIC, 2);  -- 8-15%
            END IF;
        ELSIF v_month IN (5, 6, 8, 10) THEN
            -- Datas comemorativas (Dia das Mães, Namorados, Pais, Crianças)
            IF v_rand < 0.40 THEN
                v_discount := 0;
            ELSIF v_rand < 0.75 THEN
                v_discount := round((v_unit_price * v_quantity * (0.02 + random() * 0.05))::NUMERIC, 2);  -- 2-7%
            ELSE
                v_discount := round((v_unit_price * v_quantity * (0.05 + random() * 0.05))::NUMERIC, 2);  -- 5-10%
            END IF;
        ELSE
            -- Meses normais
            IF v_rand < 0.55 THEN
                v_discount := 0;
            ELSIF v_rand < 0.85 THEN
                v_discount := round((v_unit_price * v_quantity * (0.02 + random() * 0.04))::NUMERIC, 2);  -- 2-6%
            ELSE
                v_discount := round((v_unit_price * v_quantity * (0.04 + random() * 0.06))::NUMERIC, 2);  -- 4-10%
            END IF;
        END IF;

        -- =====================================================
        -- 10. FORMA DE PAGAMENTO (distribuição realista Brasil)
        -- =====================================================
        v_rand := random();
        IF v_rand < 0.35 THEN
            v_payment := 'pix';
        ELSIF v_rand < 0.65 THEN
            v_payment := 'cartao_credito';
        ELSIF v_rand < 0.80 THEN
            v_payment := 'cartao_debito';
        ELSIF v_rand < 0.92 THEN
            v_payment := 'boleto';
        ELSE
            v_payment := 'dinheiro';
        END IF;

        -- =====================================================
        -- 11. CANAL DE VENDA
        --     Tendência: site cresce em 2026 vs 2025
        -- =====================================================
        v_rand := random();
        IF v_year = 2025 THEN
            IF v_rand < 0.42 THEN
                v_channel := 'loja_fisica';
            ELSIF v_rand < 0.68 THEN
                v_channel := 'site';
            ELSIF v_rand < 0.84 THEN
                v_channel := 'marketplace';
            ELSE
                v_channel := 'whatsapp';
            END IF;
        ELSE  -- 2026: digital cresce
            IF v_rand < 0.35 THEN
                v_channel := 'loja_fisica';
            ELSIF v_rand < 0.65 THEN
                v_channel := 'site';
            ELSIF v_rand < 0.85 THEN
                v_channel := 'marketplace';
            ELSE
                v_channel := 'whatsapp';
            END IF;
        END IF;

        -- =====================================================
        -- 12. NOME DO CLIENTE (pode ser NULL)
        -- =====================================================
        v_customer := customers[1 + floor(random() * array_length(customers, 1))::INTEGER];

        -- =====================================================
        -- INSERT
        -- =====================================================
        INSERT INTO sales (
            employee_id, product_id, store_id, customer_name,
            sale_date, quantity, unit_price_at_sale, discount,
            payment_method, sales_channel
        ) VALUES (
            v_employee_id, v_product_id, v_store_id, v_customer,
            v_sale_date, v_quantity, v_unit_price, v_discount,
            v_payment, v_channel
        );

    END LOOP;
END $$;