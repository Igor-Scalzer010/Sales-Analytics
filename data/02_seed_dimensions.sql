-- ============================================
-- CATEGORIAS
-- ============================================
INSERT INTO categories (name) VALUES
    ('Smartphones'),
    ('Notebooks e Laptops'),
    ('Computadores Desktop'),
    ('Televisores'),
    ('Eletrodomésticos'),
    ('Áudio e Fones'),
    ('Acessórios e Periféricos'),
    ('Armazenamento');

-- ============================================
-- LOJAS (cobrindo todas as 5 regiões do Brasil)
-- ============================================
INSERT INTO stores (name, state, region) VALUES
    ('Filial Centro SP',        'SP', 'Sudeste'),
    ('Filial Shopping RJ',      'RJ', 'Sudeste'),
    ('Filial Savassi BH',       'MG', 'Sudeste'),
    ('Filial Batel Curitiba',   'PR', 'Sul'),
    ('Filial Moinhos POA',      'RS', 'Sul'),
    ('Filial Recife',           'PE', 'Nordeste'),
    ('Filial Salvador',         'BA', 'Nordeste'),
    ('Filial Brasília',         'DF', 'Centro-Oeste'),
    ('Filial Goiânia',          'GO', 'Centro-Oeste'),
    ('Filial Manaus',           'AM', 'Norte');

-- ============================================
-- FUNCIONÁRIOS (30 funcionários distribuídos pelas lojas)
-- ============================================
INSERT INTO employees (full_name, birth_date, hire_date, role, store_id) VALUES
    -- Loja 1 - SP
    ('Lucas Oliveira',      '1995-03-12', '2022-01-10', 'Vendedor',    1),
    ('Mariana Silva',       '1990-07-25', '2020-06-15', 'Gerente',     1),
    ('Pedro Santos',        '1998-11-03', '2023-08-01', 'Vendedor',    1),
    -- Loja 2 - RJ
    ('Camila Costa',        '1993-01-18', '2021-03-20', 'Vendedor',    2),
    ('Rafael Pereira',      '1988-09-07', '2019-11-05', 'Supervisor',  2),
    ('Juliana Almeida',     '1996-05-30', '2023-02-14', 'Vendedor',    2),
    -- Loja 3 - MG
    ('Fernando Lima',       '1991-12-22', '2021-07-01', 'Vendedor',    3),
    ('Beatriz Rocha',       '1994-04-15', '2022-04-10', 'Gerente',     3),
    ('Thiago Mendes',       '1999-08-09', '2024-01-15', 'Vendedor',    3),
    -- Loja 4 - PR
    ('Aline Ferreira',      '1992-06-11', '2020-09-01', 'Vendedor',    4),
    ('Gustavo Ribeiro',     '1987-02-28', '2018-05-20', 'Gerente',     4),
    ('Isabela Martins',     '1997-10-17', '2023-06-01', 'Vendedor',    4),
    -- Loja 5 - RS
    ('Diego Souza',         '1990-03-05', '2021-01-10', 'Vendedor',    5),
    ('Larissa Gomes',       '1995-08-20', '2022-10-01', 'Supervisor',  5),
    ('Vinícius Araújo',     '1993-12-01', '2024-03-15', 'Vendedor',    5),
    -- Loja 6 - PE
    ('Patrícia Barbosa',    '1989-04-25', '2019-08-12', 'Gerente',     6),
    ('Henrique Cardoso',    '1996-07-14', '2023-01-20', 'Vendedor',    6),
    ('Natália Teixeira',    '1998-02-08', '2024-05-01', 'Vendedor',    6),
    -- Loja 7 - BA
    ('Roberto Nascimento',  '1991-09-19', '2020-12-01', 'Vendedor',    7),
    ('Amanda Dias',         '1994-11-30', '2022-07-15', 'Supervisor',  7),
    ('Felipe Moreira',      '2000-01-22', '2024-08-01', 'Vendedor',    7),
    -- Loja 8 - DF
    ('Vanessa Correia',     '1992-05-16', '2021-04-10', 'Vendedor',    8),
    ('André Nunes',         '1986-10-03', '2018-02-28', 'Gerente',     8),
    ('Tatiane Pinto',       '1997-03-27', '2023-09-01', 'Vendedor',    8),
    -- Loja 9 - GO
    ('Marcelo Freitas',     '1993-08-14', '2022-03-15', 'Vendedor',    9),
    ('Carolina Vieira',     '1990-12-09', '2020-10-20', 'Supervisor',  9),
    ('Bruno Carvalho',      '1999-06-21', '2024-06-01', 'Vendedor',    9),
    -- Loja 10 - AM
    ('Renata Monteiro',     '1991-01-30', '2021-08-01', 'Gerente',     10),
    ('Eduardo Castro',      '1996-04-18', '2023-04-10', 'Vendedor',    10),
    ('Gabriela Ramos',      '1998-09-12', '2024-09-15', 'Vendedor',    10);

-- ============================================
-- PRODUTOS (com preços realistas praticados no Brasil em 2025/2026)
-- ============================================
INSERT INTO products (name, category_id, unit_price, cost_price) VALUES
    -- Smartphones (category_id = 1)
    ('Samsung Galaxy S24',              1, 4299.00, 2800.00),
    ('iPhone 15 128GB',                 1, 5999.00, 4200.00),
    ('Motorola Edge 40',                1, 2499.00, 1600.00),
    ('Xiaomi Redmi Note 13',            1, 1299.00,  780.00),
    ('Samsung Galaxy A15',              1,  999.00,  580.00),

    -- Notebooks e Laptops (category_id = 2)
    ('Notebook Dell Inspiron 15',       2, 3499.00, 2300.00),
    ('MacBook Air M2',                  2, 8999.00, 6500.00),
    ('Notebook Lenovo IdeaPad 3',       2, 2799.00, 1800.00),
    ('Notebook Acer Aspire 5',          2, 3199.00, 2100.00),
    ('Notebook Samsung Book',           2, 2599.00, 1700.00),

    -- Computadores Desktop (category_id = 3)
    ('PC Gamer Completo i5 RTX 3060',  3, 5499.00, 3800.00),
    ('Desktop Dell Vostro',             3, 3899.00, 2600.00),
    ('PC Positivo Master',              3, 2199.00, 1400.00),

    -- Televisores (category_id = 4)
    ('Smart TV Samsung 55" 4K',         4, 2799.00, 1900.00),
    ('Smart TV LG 50" 4K',             4, 2399.00, 1600.00),
    ('Smart TV TCL 43"',               4, 1699.00, 1050.00),
    ('Smart TV Samsung 65" QLED',       4, 4999.00, 3500.00),

    -- Eletrodomésticos (category_id = 5)
    ('Geladeira Brastemp Frost Free 375L',  5, 3299.00, 2200.00),
    ('Geladeira Electrolux 430L',           5, 3799.00, 2500.00),
    ('Micro-ondas Panasonic 32L',           5,  599.00,  350.00),
    ('Secador de Cabelo Taiff 2100W',       5,  189.00,   95.00),
    ('Aspirador de Pó Vertical Electrolux', 5,  449.00,  260.00),
    ('Cafeteira Nespresso Vertuo',          5,  699.00,  420.00),

    -- Áudio e Fones (category_id = 6)
    ('Fone JBL Tune 520BT',            6,  219.00,  120.00),
    ('AirPods Pro 2ª Geração',          6, 1899.00, 1300.00),
    ('Caixa de Som JBL Flip 6',         6,  599.00,  360.00),
    ('Headset HyperX Cloud Stinger',    6,  249.00,  140.00),
    ('Soundbar Samsung HW-C400',        6,  899.00,  560.00),

    -- Acessórios e Periféricos (category_id = 7)
    ('Mouse Logitech MX Master 3S',    7,  549.00,  340.00),
    ('Teclado Mecânico Redragon Kumara',7,  219.00,  120.00),
    ('Webcam Logitech C920',           7,  399.00,  230.00),
    ('Cabo HDMI 2.1 2m',              7,   49.90,   18.00),
    ('Suporte para Notebook',          7,   89.90,   40.00),
    ('Mouse Pad Gamer Grande',         7,   79.90,   30.00),
    ('Hub USB-C 7 em 1',              7,  199.00,  100.00),

    -- Armazenamento (category_id = 8)
    ('SSD Kingston 480GB',             8,  219.00,  130.00),
    ('SSD Samsung 1TB NVMe',          8,  549.00,  350.00),
    ('HD Externo Seagate 1TB',        8,  329.00,  200.00),
    ('Pen Drive Kingston 64GB',        8,   39.90,   15.00),
    ('Cartão MicroSD SanDisk 128GB',   8,   79.90,   35.00);