# Medidas DAX — Sales Analytics

> Catálogo completo de todas as medidas DAX utilizadas no dashboard, organizadas por categoria funcional. Cada medida inclui a fórmula, a lógica de cálculo e o contexto de uso.

---

## Índice

1. [Boas Práticas Adotadas](#1-boas-práticas-adotadas)
2. [Medidas Base — Receita](#2-medidas-base--receita)
3. [Medidas de Custo e Margem](#3-medidas-de-custo-e-margem)
4. [Medidas de Volume](#4-medidas-de-volume)
5. [Medidas de Ticket Médio](#5-medidas-de-ticket-médio)
6. [Medidas de Inteligência de Tempo (YoY)](#6-medidas-de-inteligência-de-tempo-yoy)
7. [Medidas de Canal e Pagamento](#7-medidas-de-canal-e-pagamento)
8. [Medidas de Performance de Funcionários](#8-medidas-de-performance-de-funcionários)
9. [Medidas de Performance Regional](#9-medidas-de-performance-regional)
10. [Medidas de Ranking e Top N](#10-medidas-de-ranking-e-top-n)
11. [Medidas Auxiliares (Formatação e UX)](#11-medidas-auxiliares-formatação-e-ux)
12. [Conceitos DAX Aplicados](#12-conceitos-dax-aplicados)

---

## 1. Boas Práticas Adotadas

| Prática                                 | Descrição                                                                                    |
|-----------------------------------------|----------------------------------------------------------------------------------------------|
| **Tabela de medidas isolada**           | Todas as medidas estão na tabela `_Medidas` (sem dados, apenas para organização)             |
| **Variáveis (`VAR`)**                   | Usadas para evitar recálculos e tornar fórmulas legíveis                                     |
| **`DIVIDE()` no lugar de `/`**          | Evita erros de divisão por zero; retorna `BLANK()` ou `0` como fallback                     |
| **`BLANK()` vs `0`**                    | `BLANK()` em medidas de variação para não distorcer gráficos                                 |
| **Reutilização de medidas (DRY)**       | Medidas complexas referenciam medidas base (ex: `[Lucro Bruto] = [Receita Liquida] - [Custo Total]`) |
| **Relação com `dCalendario`**           | Todas as medidas de Time Intelligence dependem da tabela calendário                          |

---

## 2. Medidas Base — Receita

### `Receita Bruta`

Soma de `unit_price_at_sale × quantity` para todas as transações. **Não desconta descontos.**

```dax
Receita Bruta =
SUMX(
    sales,
    sales[unit_price_at_sale] * sales[quantity]
)
```

> Usa `SUMX` (iterador) em vez de `SUM` porque precisa multiplicar duas colunas linha a linha.

---

### `Total Descontos`

```dax
Total Descontos = SUM(sales[discount])
```

---

### `Receita Liquida`

Receita efetivamente reconhecida, após descontos.

```dax
Receita Liquida =
SUMX(
    sales,
    sales[unit_price_at_sale] * sales[quantity]
) - SUM(sales[discount])
```

---

## 3. Medidas de Custo e Margem

### `Custo Total`

Custo de aquisição dos produtos vendidos. Usa `RELATED()` para acessar `cost_price` da tabela `products`.

```dax
Custo Total =
SUMX(
    sales,
    RELATED(products[cost_price]) * sales[quantity]
)
```

> `RELATED()` funciona porque existe um relacionamento N:1 de `sales` para `products`.

---

### `Lucro Bruto`

```dax
Lucro Bruto = [Receita Liquida] - [Custo Total]
```

---

### `Margem de Lucro %`

```dax
Margem de Lucro % =
DIVIDE([Lucro Bruto], [Receita Liquida], 0)
```

---

### `Desconto Medio %`

Impacto proporcional dos descontos sobre a receita bruta.

```dax
Desconto Medio % =
DIVIDE([Total Descontos], [Receita Bruta], 0)
```

---

## 4. Medidas de Volume

### `Num Vendas`

Número de transações (linhas na tabela `sales`).

```dax
Num Vendas = COUNTROWS(sales)
```

---

### `Qtd Vendida`

Soma total de unidades vendidas.

```dax
Qtd Vendida = SUM(sales[quantity])
```

---

### `Total Funcionarios`

Contagem de **todos** os funcionários cadastrados (não muda com filtros de vendas).

```dax
Total Funcionarios = COUNTROWS(employees)
```

---

### `Funcionarios Ativos`

Conta apenas funcionários que **têm vendas** no período filtrado.

```dax
Funcionarios Ativos = DISTINCTCOUNT(sales[employee_id])
```

> **Diferença chave:** `Total Funcionarios` = 30 sempre. `Funcionarios Ativos` = quantos venderam no filtro atual.

---

### `Num Estados Ativos`

Conta estados com pelo menos 1 venda no período.

```dax
Num Estados Ativos = DISTINCTCOUNT(sales[store_id])
```

---

## 5. Medidas de Ticket Médio

### `Ticket Medio`

Valor médio por transação.

```dax
Ticket Medio =
DIVIDE([Receita Liquida], [Num Vendas], 0)
```

---

### `Receita por Funcionario`

```dax
Receita por Funcionario =
DIVIDE(
    [Receita Liquida],
    DISTINCTCOUNT(sales[employee_id]),
    0
)
```

---

### `Media Vendas por Funcionario`

```dax
Media Vendas por Funcionario =
DIVIDE(
    [Num Vendas],
    DISTINCTCOUNT(sales[employee_id]),
    0
)
```

---

## 6. Medidas de Inteligência de Tempo (YoY)

> **Pré-requisito:** tabela `dCalendario` com relacionamento ativo com `sales[sale_date_only]`.

### `Receita Liquida AA`

Receita do mesmo período no ano anterior.

```dax
Receita Liquida AA =
CALCULATE(
    [Receita Liquida],
    SAMEPERIODLASTYEAR(dCalendario[Data])
)
```

---

### `Crescimento YoY %`

```dax
Crescimento YoY % =
VAR ReceitaAtual    = [Receita Liquida]
VAR ReceitaAnterior = [Receita Liquida AA]
RETURN
    DIVIDE(ReceitaAtual - ReceitaAnterior, ReceitaAnterior, BLANK())
```

---

### `Receita YTD`

Receita acumulada desde o início do ano.

```dax
Receita YTD =
CALCULATE(
    [Receita Liquida],
    DATESYTD(dCalendario[Data])
)
```

---

### `Receita MTD`

Receita acumulada desde o início do mês.

```dax
Receita MTD =
CALCULATE(
    [Receita Liquida],
    DATESMTD(dCalendario[Data])
)
```

---

### `Media Movel 3M`

Média móvel de 3 meses (suaviza sazonalidade).

```dax
Media Movel 3M =
CALCULATE(
    [Receita Liquida],
    DATESINPERIOD(dCalendario[Data], MAX(dCalendario[Data]), -3, MONTH)
) / 3
```

---

## 7. Medidas de Canal e Pagamento

### `Receita Canais Digitais`

```dax
Receita Canais Digitais =
CALCULATE(
    [Receita Liquida],
    sales[sales_channel] IN {"site", "marketplace", "whatsapp"}
)
```

---

### `% Canais Digitais`

```dax
% Canais Digitais =
DIVIDE([Receita Canais Digitais], [Receita Liquida], 0)
```

---

## 8. Medidas de Performance de Funcionários

### `Melhor Vendedor`

Retorna o **nome** (texto) do funcionário com maior receita no período filtrado.

```dax
Melhor Vendedor =
VAR TabelaVendedores =
    ADDCOLUMNS(
        VALUES(employees[full_name]),
        "@Receita", [Receita Liquida]
    )
VAR TopVendedor =
    TOPN(1, TabelaVendedores, [@Receita], DESC)
RETURN
    MAXX(TopVendedor, employees[full_name])
```

> **Técnica:** `ADDCOLUMNS` cria tabela virtual → `TOPN` pega o 1º → `MAXX` extrai o texto.

---

### `Cargo do Top Vendedor`

```dax
Cargo do Top Vendedor =
VAR TabelaRanking =
    ADDCOLUMNS(
        SUMMARIZE(employees, employees[full_name], employees[role]),
        "@Receita", [Receita Liquida]
    )
VAR TopVendedor = TOPN(1, TabelaRanking, [@Receita], DESC)
RETURN
    MAXX(TopVendedor, employees[role])
```

---

### `Loja do Top Vendedor`

```dax
Loja do Top Vendedor =
VAR TabelaRanking =
    ADDCOLUMNS(
        SUMMARIZE(employees, employees[full_name], stores[state]),
        "@Receita", [Receita Liquida]
    )
VAR TopVendedor = TOPN(1, TabelaRanking, [@Receita], DESC)
RETURN
    MAXX(TopVendedor, stores[state])
```

---

## 9. Medidas de Performance Regional

### `Estado Top`

```dax
Estado Top =
VAR TabelaEstados =
    ADDCOLUMNS(VALUES(stores[state]), "@Receita", [Receita Liquida])
VAR TopEstado = TOPN(1, TabelaEstados, [@Receita], DESC)
RETURN
    MAXX(TopEstado, stores[state])
```

---

### `Regiao Top`

```dax
Regiao Top =
VAR TabelaRegioes =
    ADDCOLUMNS(VALUES(stores[region]), "@Receita", [Receita Liquida])
VAR TopRegiao = TOPN(1, TabelaRegioes, [@Receita], DESC)
RETURN
    MAXX(TopRegiao, stores[region])
```

---

### `Receita Media por Estado`

```dax
Receita Media por Estado =
AVERAGEX(
    VALUES(stores[state]),
    [Receita Liquida]
)
```

> Usa `AVERAGEX` (iterador): para cada estado, calcula a receita, depois tira a média.

---

### `Concentracao Top Estado %`

Quanto % da receita total vem do estado que mais vende. Indica risco de dependência geográfica.

```dax
Concentracao Top Estado % =
VAR ReceitaTotal = CALCULATE([Receita Liquida], ALL(stores))
VAR TabelaEstados = ADDCOLUMNS(ALL(stores[state]), "@Receita", [Receita Liquida])
VAR ReceitaTopEstado = MAXX(TabelaEstados, [@Receita])
RETURN
    DIVIDE(ReceitaTopEstado, ReceitaTotal, 0)
```

> **Interpretação:** > 40% = alta concentração ⚠️ | 20–40% = moderada | < 20% = bem distribuída ✅

---

### `Media Global Num Vendas` (para linha de referência no Scatter)

```dax
Media Global Num Vendas =
AVERAGEX(
    ALL('public employees'[full_name]),
    [Num Vendas]
)
```

> Usa `ALL()` para ignorar o contexto do visual e manter valor fixo.

---

### `Media Global Ticket Medio` (para linha de referência no Scatter)

```dax
Media Global Ticket Medio =
AVERAGEX(
    ALL('public employees'[full_name]),
    DIVIDE([Receita Liquida], [Num Vendas], 0)
)
```

---

## 10. Medidas de Ranking e Top N

### `Top 5 Vendedores`

Medida central do gráfico de evolução mensal. Retorna `[Receita Liquida]` apenas para vendedores no Top 5 **global**, `BLANK()` para os demais (o Power BI esconde automaticamente).

```dax
Top 5 Vendedores =
VAR RankVendedor =
    RANKX(
        ALL('public employees'[full_name]),
        CALCULATE(
            [Receita Liquida],
            ALLSELECTED(dCalendario)
        ),
        ,
        DESC,
        DENSE
    )
RETURN
    IF(RankVendedor <= 5, [Receita Liquida], BLANK())
```

> **Conceito-chave:**
> - `ALL(employees[full_name])`: percorre TODOS os vendedores para comparação
> - `ALLSELECTED(dCalendario)`: remove filtro interno do Eixo X (mês), mas MANTÉM filtros dos slicers (ano, região)
> - `[Receita Liquida]` no RETURN: usa o contexto do mês para mostrar o valor mensal de cada vendedor

---

### `Ranking de Produto por Receita`

```dax
Ranking de Produto por Receita =
IF(
    ISBLANK([Receita Liquida]),
    BLANK(),
    RANKX(ALL(products[name]), [Receita Liquida], , DESC, DENSE)
)
```

---

### `Ranking de Funcionario por Receita`

```dax
Ranking de Funcionario por Receita =
IF(
    ISBLANK([Receita Liquida]),
    BLANK(),
    RANKX(ALL(employees[full_name]), [Receita Liquida], , DESC, DENSE)
)
```

---

## 11. Medidas Auxiliares (Formatação e UX)

### `Receita Formatada`

Formata receita para exibição compacta em cards.

```dax
Receita Formatada =
VAR Valor = [Receita Liquida]
RETURN
    SWITCH(
        TRUE(),
        Valor >= 1000000, FORMAT(Valor / 1000000, "R$ #,##0.0") & " M",
        Valor >= 1000,    FORMAT(Valor / 1000, "R$ #,##0.0") & " K",
        FORMAT(Valor, "R$ #,##0.00")
    )
```

---

### `Seta YoY`

Símbolo de seta com valor para cards KPI.

```dax
Seta YoY =
VAR Variacao = [Crescimento YoY %]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(Variacao), "—",
        Variacao > 0,      "▲ " & FORMAT(Variacao, "0.0%"),
        Variacao < 0,      "▼ " & FORMAT(Variacao, "0.0%"),
        "= 0,0%"
    )
```

---

### `Tendencia YoY`

Texto descritivo para formatação condicional.

```dax
Tendencia YoY =
VAR Crescimento = [Crescimento YoY %]
RETURN
    SWITCH(
        TRUE(),
        Crescimento > 0.05, "▲ Crescimento",
        Crescimento > 0,    "► Estável",
        Crescimento <= 0,   "▼ Queda",
        BLANK()
    )
```

---

### `Periodo Selecionado`

Exibe dinamicamente o período filtrado no título do relatório.

```dax
Periodo Selecionado =
VAR AnoMin = YEAR(MIN(dCalendario[Data]))
VAR AnoMax = YEAR(MAX(dCalendario[Data]))
RETURN
    IF(AnoMin = AnoMax, "Ano " & AnoMin, AnoMin & " – " & AnoMax)
```

---

## 12. Conceitos DAX Aplicados

Referência rápida dos conceitos DAX utilizados neste projeto, com equivalência SQL:

| Conceito DAX          | Exemplo no Projeto                              | Equivalente SQL                  |
|-----------------------|-------------------------------------------------|----------------------------------|
| `SUMX` (iterador)    | Receita Bruta (multiplica 2 colunas)            | `SUM(col1 * col2)`              |
| `AVERAGEX` (iterador)| Receita Média por Estado                        | `AVG()` com `GROUP BY`          |
| `DIVIDE`             | Ticket Médio, Margem % (divisão segura)         | `CASE WHEN den=0 THEN 0 ELSE`  |
| `RELATED`            | Custo Total (acessa tabela relacionada)         | `JOIN`                           |
| `CALCULATE`          | Modificar contexto de filtro                    | Subquery com `WHERE` diferente  |
| `ALL`                | Remover todos os filtros                        | `SELECT` sem `WHERE`            |
| `ALLSELECTED`        | Remover filtros internos do visual              | Sem equivalente direto          |
| `VALUES`             | Lista de valores únicos                         | `SELECT DISTINCT`               |
| `ADDCOLUMNS`         | Tabela virtual com colunas extras               | `SELECT *, (subquery) AS col`   |
| `TOPN`               | Top 1 estado, Top 5 vendedores                  | `ORDER BY ... LIMIT N`          |
| `RANKX`              | Rankings dinâmicos                              | `RANK() OVER(ORDER BY)`         |
| `MAXX`               | Extrair texto de tabela virtual                 | `MAX()` em subquery             |
| `DISTINCTCOUNT`      | Estados ativos, Funcionários ativos             | `COUNT(DISTINCT col)`           |
| `COUNTROWS`          | Total de funcionários, Nº de vendas             | `COUNT(*)`                       |
| `SAMEPERIODLASTYEAR` | Comparativo ano anterior                        | `WHERE year = year - 1`         |
| `DATESYTD`           | Receita acumulada no ano                        | `WHERE date >= '01-01' AND ...` |
| `VAR / RETURN`       | Variáveis intermediárias                        | `WITH` (CTE)                     |
| `IF / BLANK`         | Filtrar visuais (Top N dinâmico)                | `CASE WHEN ... ELSE NULL`       |
| `SWITCH`             | Formatação condicional                          | `CASE WHEN ... WHEN ...`        |

---

← [Voltar ao README](../README.md)