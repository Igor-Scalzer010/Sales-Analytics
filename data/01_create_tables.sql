-- ============================================
-- PROJETO: Análise Financeira de Vendas
-- BANCO: PostgreSQL (Supabase)
-- AUTOR: Igor Scalzer
-- DATA: 2026-02-10
-- ============================================

-- 1. Tabela de Categorias
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Tabela de Lojas
CREATE TABLE stores (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    state       CHAR(2) NOT NULL,           -- Sigla do estado (SP, RJ, MG...)
    region      VARCHAR(20) NOT NULL         -- Norte, Nordeste, Sul, Sudeste, Centro-Oeste
);

-- 3. Tabela de Funcionários
CREATE TABLE employees (
    id          SERIAL PRIMARY KEY,
    full_name   VARCHAR(200) NOT NULL,
    birth_date  DATE NOT NULL,
    hire_date   DATE NOT NULL,
    role        VARCHAR(50) NOT NULL,        -- Vendedor, Gerente, Supervisor
    store_id    INTEGER NOT NULL REFERENCES stores(id)
);

-- 4. Tabela de Produtos
CREATE TABLE products (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(200) NOT NULL,
    category_id   INTEGER NOT NULL REFERENCES categories(id),
    unit_price    NUMERIC(10,2) NOT NULL,    -- Preço de venda atual
    cost_price    NUMERIC(10,2) NOT NULL     -- Custo de aquisição (para cálculo de margem)
);

-- 5. Tabela de Vendas (tabela fato)
CREATE TABLE sales (
    id                  SERIAL PRIMARY KEY,
    employee_id         INTEGER NOT NULL REFERENCES employees(id),
    product_id          INTEGER NOT NULL REFERENCES products(id),
    store_id            INTEGER NOT NULL REFERENCES stores(id),
    customer_name       VARCHAR(200),                         -- Pode ser NULL (venda sem cadastro)
    sale_date           TIMESTAMP WITH TIME ZONE NOT NULL,
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_at_sale  NUMERIC(10,2) NOT NULL,               -- Preço no momento da venda
    discount            NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    payment_method      VARCHAR(30) NOT NULL,                  -- pix, cartao_credito, cartao_debito, boleto, dinheiro
    sales_channel       VARCHAR(30) NOT NULL,                  -- loja_fisica, site, marketplace, whatsapp
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance das consultas no dashboard
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_employee ON sales(employee_id);
CREATE INDEX idx_sales_product ON sales(product_id);
CREATE INDEX idx_sales_store ON sales(store_id);