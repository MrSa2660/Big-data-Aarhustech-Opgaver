-- 20556 · Dag02 · fact_trip og analysequeries
-- Kør efter 02_dimensions.sql:
--   .\.venv\Scripts\python.exe src/run_sql_file.py sql/03_fact_trip.sql
--
-- GRAIN: én række i fact_trip = én taxitur som registreret i rawfilen.
-- Der filtreres ikke, og der fjernes ikke dubletter, så fact matcher raw 1:1.

------------------------------------------------------------
-- 1. fact_trip
-- Nøgler: trip_key (teknisk PK) + 4 foreign keys til dimensionerne.
-- dim_zone bruges i rollen pickup OG dropoff, dim_date ligeså.
-- Measures: distance, tid og beløb – alt sammen additivt pr. tur.
------------------------------------------------------------
CREATE OR REPLACE TABLE fact_trip AS
SELECT
    ROW_NUMBER() OVER (ORDER BY tpep_pickup_datetime,
                                tpep_dropoff_datetime,
                                PULocationID,
                                DOLocationID,
                                total_amount)                       AS trip_key,
    -- foreign keys (roller)
    CAST(strftime(CAST(tpep_pickup_datetime  AS DATE), '%Y%m%d') AS INTEGER) AS pickup_date_key,
    CAST(strftime(CAST(tpep_dropoff_datetime AS DATE), '%Y%m%d') AS INTEGER) AS dropoff_date_key,
    CAST(PULocationID AS INTEGER)                                   AS pickup_zone_key,
    CAST(DOLocationID AS INTEGER)                                   AS dropoff_zone_key,
    -- tidsstempler beholdes til kontrol og tidsanalyser
    tpep_pickup_datetime                                            AS pickup_ts,
    tpep_dropoff_datetime                                           AS dropoff_ts,
    -- measures
    trip_distance,
    date_diff('minute', tpep_pickup_datetime, tpep_dropoff_datetime) AS trip_minutes,
    passenger_count,
    fare_amount,
    tip_amount,
    total_amount,
    -- degenereret dimension: kode uden egen dimensionstabel
    payment_type
FROM 'data/raw/yellow_tripdata_2025-01.parquet';

------------------------------------------------------------
-- 2. Kontrol af fact mod raw
------------------------------------------------------------

-- 2a. Samme antal rækker som rawfilen? (grain er 1:1 med raw)
SELECT
    (SELECT COUNT(*) FROM 'data/raw/yellow_tripdata_2025-01.parquet') AS raekker_raw,
    (SELECT COUNT(*) FROM fact_trip)                                  AS raekker_fact;
-- RESULTAT: (skal være ens)

-- 2b. Er trip_key entydig? (primary key-egenskab)
SELECT COUNT(*)                 AS antal_raekker,
       COUNT(DISTINCT trip_key) AS unikke_noegler
FROM fact_trip;
-- RESULTAT: (skal være ens)

------------------------------------------------------------
-- 3. Kontrol af relationernes dækning
-- Mangler der matches i nogen af de fire roller?
------------------------------------------------------------
SELECT
    SUM(CASE WHEN dz_pu.zone_key IS NULL THEN 1 ELSE 0 END) AS mangler_pickup_zone,
    SUM(CASE WHEN dz_do.zone_key IS NULL THEN 1 ELSE 0 END) AS mangler_dropoff_zone,
    SUM(CASE WHEN dd_pu.date_key IS NULL THEN 1 ELSE 0 END) AS mangler_pickup_dato,
    SUM(CASE WHEN dd_do.date_key IS NULL THEN 1 ELSE 0 END) AS mangler_dropoff_dato
FROM fact_trip f
LEFT JOIN dim_zone dz_pu ON f.pickup_zone_key  = dz_pu.zone_key
LEFT JOIN dim_zone dz_do ON f.dropoff_zone_key = dz_do.zone_key
LEFT JOIN dim_date dd_pu ON f.pickup_date_key  = dd_pu.date_key
LEFT JOIN dim_date dd_do ON f.dropoff_date_key = dd_do.date_key;
-- RESULTAT: (forventet 0 i alle fire kolonner)

------------------------------------------------------------
-- 4. Kontrol af kardinalitet
-- Giver join til alle fire dimensionsroller flere rækker?
------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM fact_trip) AS foer_join,
    (SELECT COUNT(*)
     FROM fact_trip f
     LEFT JOIN dim_zone dz_pu ON f.pickup_zone_key  = dz_pu.zone_key
     LEFT JOIN dim_zone dz_do ON f.dropoff_zone_key = dz_do.zone_key
     LEFT JOIN dim_date dd_pu ON f.pickup_date_key  = dd_pu.date_key
     LEFT JOIN dim_date dd_do ON f.dropoff_date_key = dd_do.date_key) AS efter_join;
-- RESULTAT: (skal være ens – dimensionsnøglerne er entydige, så joins mangedobler ikke)

------------------------------------------------------------
-- 5. ANALYSEQUERY 1
-- Analysebehov 1 (Dag01): Hvilke bydele har flest pickups,
-- og hvor er den gennemsnitlige pris højest?
-- Bruger dim_zone (pickup-rolle) + dim_date (pickup-rolle) + measures.
-- Én række = én pickup-bydel i januar 2025.
------------------------------------------------------------
SELECT
    dz.borough                          AS pickup_borough,
    COUNT(*)                            AS antal_ture,
    ROUND(AVG(f.fare_amount), 2)        AS gns_fare,
    ROUND(AVG(f.trip_distance), 2)      AS gns_distance_miles,
    ROUND(SUM(f.total_amount), 0)       AS samlet_omsaetning
FROM fact_trip f
JOIN dim_zone dz ON f.pickup_zone_key = dz.zone_key
JOIN dim_date dd ON f.pickup_date_key = dd.date_key
WHERE dd.year = 2025 AND dd.month = 1
GROUP BY dz.borough
ORDER BY antal_ture DESC;
-- RESULTAT:

------------------------------------------------------------
-- 6. ANALYSEQUERY 2
-- Analysebehov 2 (Dag01): Hvordan varierer ture og distance over ugedagene?
-- Bruger dim_date (pickup-rolle) + measure ud over optælling.
-- Én række = én ugedag i januar 2025.
------------------------------------------------------------
SELECT
    dd.weekday_no,
    dd.weekday_name,
    COUNT(*)                        AS antal_ture,
    ROUND(AVG(f.trip_distance), 2)  AS gns_distance_miles,
    ROUND(AVG(f.trip_minutes), 1)   AS gns_minutter
FROM fact_trip f
JOIN dim_date dd ON f.pickup_date_key = dd.date_key
WHERE dd.year = 2025 AND dd.month = 1
GROUP BY dd.weekday_no, dd.weekday_name
ORDER BY dd.weekday_no;
-- RESULTAT:

------------------------------------------------------------
-- 7. EKSTRA: begge roller i samme query (pickup -> dropoff)
-- Viser hvorfor dim_zone er en role-playing dimension.
-- Én række = én kombination af pickup-bydel og dropoff-bydel.
------------------------------------------------------------
SELECT
    pu.borough                    AS fra_borough,
    do_.borough                   AS til_borough,
    COUNT(*)                      AS antal_ture,
    ROUND(AVG(f.fare_amount), 2)  AS gns_fare
FROM fact_trip f
JOIN dim_zone pu  ON f.pickup_zone_key  = pu.zone_key
JOIN dim_zone do_ ON f.dropoff_zone_key = do_.zone_key
GROUP BY pu.borough, do_.borough
ORDER BY antal_ture DESC
LIMIT 10;
-- RESULTAT:

------------------------------------------------------------
-- Manualsider
------------------------------------------------------------
-- duckdb.org/docs/current/sql/functions/window_functions – ROW_NUMBER() til teknisk nøgle
-- duckdb.org/docs/current/sql/functions/date            – date_diff() til turens varighed
-- duckdb.org/docs/current/sql/query_syntax/from         – JOIN og alias til to roller af samme dimension
-- kimballgroup.com/.../dimensional-modeling-techniques/ – grain, fact, dimension, role-playing dimension
