-- 20556 · Tirsdag (Dag02) · dimensions
-- Kør: .\.venv\Scripts\python.exe src/run_sql_file.py sql/02_dimensions.sql
-- Raw-filerne læses kun. Tabellerne gemmes i data/warehouse/taxi_20556.duckdb.

------------------------------------------------------------
-- 1. Kontrollér de rå kilder
------------------------------------------------------------

-- 1a. Zonefilen: antal rækker og unikke ID'er
SELECT COUNT(*) AS antal_raekker,
       COUNT(DISTINCT LocationID) AS unikke_id
FROM 'data/raw/taxi_zone_lookup.csv';
-- RESULTAT:

-- 1b. Tripdata: datointerval for pickup og dropoff
SELECT MIN(CAST(tpep_pickup_datetime  AS DATE)) AS min_pickup,
       MAX(CAST(tpep_pickup_datetime  AS DATE)) AS max_pickup,
       MIN(CAST(tpep_dropoff_datetime AS DATE)) AS min_dropoff,
       MAX(CAST(tpep_dropoff_datetime AS DATE)) AS max_dropoff
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- RESULTAT:

------------------------------------------------------------
-- 2. dim_zone – én række pr. taxizone
-- Nøgle: zone_key = LocationID (natural key fra TLC).
-- Begrundelse: LocationID er unik, stabil og er samme ID som
-- PULocationID/DOLocationID i tripdata. Derfor kan samme tabel
-- bruges i både pickup- og dropoff-rollen.
-- Attributter: borough, zone_name, service_zone (til gruppering).
------------------------------------------------------------
CREATE OR REPLACE TABLE dim_zone AS
SELECT
    CAST(LocationID AS INTEGER) AS zone_key,
    Borough                     AS borough,
    Zone                        AS zone_name,
    service_zone
FROM 'data/raw/taxi_zone_lookup.csv';

------------------------------------------------------------
-- 3. Kontrollér dim_zone
------------------------------------------------------------

-- 3a. Er zone_key entydig og uden NULL?
SELECT COUNT(*)                 AS antal_raekker,
       COUNT(DISTINCT zone_key) AS unikke_noegler,
       COUNT(*) - COUNT(zone_key) AS null_noegler
FROM dim_zone;
-- RESULTAT: (forventet 265 / 265 / 0)

-- 3b. Udsnit
SELECT * FROM dim_zone ORDER BY zone_key LIMIT 5;

------------------------------------------------------------
-- 4. dim_date – én række pr. dato
-- Nøgle: date_key = YYYYMMDD som heltal (fx 20250115).
-- Begrundelse: læsbar, entydig og giver samme værdi ved genopbygning.
-- Datoerne dækker hele perioden fra første til sidste dato i
-- BÅDE pickup og dropoff, så tabellen kan bruges i begge roller.
-- Kalenderen har ingen huller – også dage uden ture er med.
------------------------------------------------------------
CREATE OR REPLACE TABLE dim_date AS
WITH graenser AS (
    SELECT
        LEAST(MIN(CAST(tpep_pickup_datetime  AS DATE)),
              MIN(CAST(tpep_dropoff_datetime AS DATE))) AS foerste_dato,
        GREATEST(MAX(CAST(tpep_pickup_datetime  AS DATE)),
                 MAX(CAST(tpep_dropoff_datetime AS DATE))) AS sidste_dato
    FROM 'data/raw/yellow_tripdata_2025-01.parquet'
),
kalender AS (
    SELECT CAST(d.range AS DATE) AS full_date
    FROM graenser g,
         range(g.foerste_dato, g.sidste_dato + INTERVAL 1 DAY, INTERVAL 1 DAY) AS d
)
SELECT
    CAST(strftime(full_date, '%Y%m%d') AS INTEGER) AS date_key,
    full_date,
    year(full_date)          AS year,
    month(full_date)         AS month,
    day(full_date)           AS day,
    isodow(full_date)        AS weekday_no,    -- 1 = mandag … 7 = søndag
    dayname(full_date)       AS weekday_name,
    isodow(full_date) >= 6   AS is_weekend
FROM kalender
ORDER BY full_date;

------------------------------------------------------------
-- 5. Kontrollér dim_date
------------------------------------------------------------

-- 5a. Er date_key entydig, og hvilken periode dækkes?
SELECT COUNT(*)                 AS antal_raekker,
       COUNT(DISTINCT date_key) AS unikke_noegler,
       MIN(full_date)           AS min_dato,
       MAX(full_date)           AS max_dato
FROM dim_date;
-- RESULTAT:

-- 5b. Findes alle pickup- og dropoff-datoer i dim_date?
SELECT
    (SELECT COUNT(*)
     FROM 'data/raw/yellow_tripdata_2025-01.parquet' t
     LEFT JOIN dim_date d ON CAST(t.tpep_pickup_datetime AS DATE) = d.full_date
     WHERE d.date_key IS NULL)  AS pickup_uden_dato,
    (SELECT COUNT(*)
     FROM 'data/raw/yellow_tripdata_2025-01.parquet' t
     LEFT JOIN dim_date d ON CAST(t.tpep_dropoff_datetime AS DATE) = d.full_date
     WHERE d.date_key IS NULL)  AS dropoff_uden_dato;
-- RESULTAT: (forventet 0 / 0)

-- 5c. Udsnit
SELECT * FROM dim_date ORDER BY date_key LIMIT 5;

------------------------------------------------------------
-- Manualsider
------------------------------------------------------------
-- duckdb.org/docs/current/sql/statements/create_table   – CREATE OR REPLACE TABLE ... AS
-- duckdb.org/docs/current/sql/functions/date            – year(), month(), dayname(), isodow()
-- duckdb.org/docs/current/sql/functions/dateformat      – strftime() til date_key
-- duckdb.org/docs/current/sql/functions/list#range      – range() til kalender uden huller
