-- 20556 · DuckDB mini-lab · Elevfil
-- Kør fra mappen duckdb_minilab:
-- Windows:        python run_duckdb_file.py duckdb_minilab.sql
-- macOS/Linux:   python3 run_duckdb_file.py duckdb_minilab.sql
--
-- Formålet er at forstå forskellen på:
-- 1. en datafil på disk
-- 2. DuckDB som SQL-engine
-- 3. en materialiseret tabel i en DuckDB-databasefil
-- 4. en Parquet-fil som analytisk dataformat

-- A. Læs en CSV-fil direkte.
-- TODO: Vis fem rækker fra data/sales.csv.


-- B. Undersøg filens schema.
-- TODO: Brug DESCRIBE SELECT ... til at se kolonner og datatyper.


-- C. Brug DuckDB til en lille analyse direkte på CSV-filen.
-- TODO: Beregn amount = quantity * unit_price, og find samlet amount pr. category.


-- D. Materialisér data som en tabel i DuckDB-databasen.
-- TODO: Opret tabellen sales med CREATE OR REPLACE TABLE ... AS SELECT ...


-- E. Forespørg tabellen sales.
-- TODO: Vis samlet amount pr. region fra tabellen sales.


-- F. Eksportér tabellen til Parquet.
-- TODO: Skriv sales-tabellen til output/sales.parquet med COPY ... TO ... (FORMAT PARQUET).


-- G. Læs Parquet-filen direkte.
-- TODO: Vis fem rækker fra output/sales.parquet.


-- H. Afsluttende forklaring.
-- Skriv som kommentarer nederst:
-- Hvor ligger sales.csv?
-- Hvor ligger tabellen sales?
-- Hvor ligger sales.parquet?
-- Hvad gør DuckDB i øvelsen?
