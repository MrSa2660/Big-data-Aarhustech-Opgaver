# DuckDB mini-lab

**Version 1.0 · 20556 · LMS-materiale**

Mini-labben bruges før arbejdet med NYC Taxi-data. Formålet er at træne den grundlæggende arbejdsmodel i DuckDB på et lille datasæt, så værktøjet ikke forveksles med selve Taxi-casen.

## Indhold

1. [Mål](#1-mål)
2. [Filer](#2-filer)
3. [Klargøring](#3-klargøring)
4. [Opgave A – læs en CSV-fil direkte](#4-opgave-a--læs-en-csv-fil-direkte)
5. [Opgave B – materialisér en tabel](#5-opgave-b--materialisér-en-tabel)
6. [Opgave C – skriv og læs Parquet](#6-opgave-c--skriv-og-læs-parquet)
7. [Checkpoint](#7-checkpoint)
8. [Hjælp og fordybelse](#8-hjælp-og-fordybelse)

---

# 1. Mål

Efter øvelsen skal du kunne forklare forskellen på:

```text
CSV-fil / Parquet-fil
        ↓
DuckDB som SQL-engine
        ↓
DuckDB-databasefil med materialiserede tabeller
        ↓
query-resultat
```

Du skal især kunne svare på spørgsmålet:

> Hvor ligger dataene, og hvad gør DuckDB?

# 2. Filer

```text
duckdb_minilab/
├── data/
│   └── sales.csv
├── output/
│   └── oprettes under øvelsen
├── duckdb_minilab.sql
├── run_duckdb_file.py
└── requirements.txt
```

`sales.csv` er et lille øvedatasæt. Det bruges kun til at lære DuckDB-arbejdsformen. Taxi-data bruges bagefter i hovedcasen.

# 3. Klargøring

Åbn terminalen i mappen `duckdb_minilab`.

Installér pakkerne, hvis de ikke allerede findes i dit miljø:

```powershell
python -m pip install -r requirements.txt
```

Kør elevfilen:

```powershell
python run_duckdb_file.py duckdb_minilab.sql
```

Når filen kun indeholder kommentarer, får du besked om, at der endnu ikke er SQL-statements at køre. Det er forventet.

# 4. Opgave A – læs en CSV-fil direkte

Skriv SQL i `duckdb_minilab.sql`.

Start med at læse filen direkte:

```sql
SELECT *
FROM 'data/sales.csv'
LIMIT 5;
```

Undersøg derefter schemaet:

```sql
DESCRIBE
SELECT *
FROM 'data/sales.csv';
```

Svar kort som SQL-kommentar:

```sql
-- Ligger sales.csv nu som en tabel i DuckDB-databasen?
```

# 5. Opgave B – materialisér en tabel

Beregn først et simpelt analysefelt direkte på CSV-filen:

```sql
SELECT
    category,
    SUM(quantity * unit_price) AS total_amount
FROM 'data/sales.csv'
GROUP BY category
ORDER BY total_amount DESC;
```

Opret derefter en tabel i DuckDB-databasen:

```sql
CREATE OR REPLACE TABLE sales AS
SELECT *
FROM 'data/sales.csv';
```

Forespørg tabellen:

```sql
SELECT
    region,
    SUM(quantity * unit_price) AS total_amount
FROM sales
GROUP BY region
ORDER BY total_amount DESC;
```

Svar kort som SQL-kommentar:

```sql
-- Hvad er forskellen på 'data/sales.csv' og tabellen sales?
```

# 6. Opgave C – skriv og læs Parquet

Skriv tabellen til en Parquet-fil:

```sql
COPY sales
TO 'output/sales.parquet'
(FORMAT PARQUET);
```

Læs derefter Parquet-filen direkte:

```sql
SELECT *
FROM 'output/sales.parquet'
LIMIT 5;
```

Svar kort som SQL-kommentar:

```sql
-- Er output/sales.parquet en database eller en datafil?
```

# 7. Checkpoint

Ved øvelsens afslutning skal du kunne forklare:

- hvad DuckDB gør i øvelsen;
- hvor `sales.csv` ligger;
- hvor tabellen `sales` ligger;
- hvor `sales.parquet` ligger;
- hvorfor Parquet og DuckDB ikke er det samme.

# 8. Hjælp og fordybelse

## Hjælp

Kontrollér først:

1. Står terminalen i mappen `duckdb_minilab`?
2. Findes `data/sales.csv`?
3. Har du afsluttet hvert SQL-statement med semikolon?
4. Viser fejlmeddelelsen et forkert filnavn, et forkert kolonnenavn eller et syntaxproblem?

## Fordybelse

Når checkpointet virker, kan du undersøge:

- forskellen på at læse fra CSV-filen og fra tabellen `sales`;
- hvilke filer der findes i mappen før og efter `COPY`;
- om `duckdb_lab.duckdb` stadig indeholder tabellen `sales`, når du lukker terminalen og kører scriptet igen;
- hvordan `WHERE`, `GROUP BY` og `ORDER BY` påvirker resultatet.

## Kilder

DuckDB – Why DuckDB  
https://duckdb.org/why_duckdb

DuckDB – Reading and Writing Parquet Files  
https://duckdb.org/docs/current/data/parquet/overview

DuckDB – CREATE TABLE  
https://duckdb.org/docs/current/sql/statements/create_table

DuckDB – COPY  
https://duckdb.org/docs/current/sql/statements/copy
