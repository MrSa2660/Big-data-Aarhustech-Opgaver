-- 20556 · Mandag
-- Kør: .\.venv\Scripts\python.exe src/run_sql_file.py sql/01_explore.sql
-- Raw-data ændres ikke.

------------------------------------------------------------
-- 1. Dataundersøgelse
------------------------------------------------------------

-- 1a. Antal rækker
SELECT COUNT(*) AS antal_raekker
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- RESULTAT: 3.475.226 ture. Én række = én taxitur.

-- 1b. Schema / datatyper
DESCRIBE SELECT * FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- RESULTAT: 20 kolonner. Tider = TIMESTAMP, zoner = INTEGER, beløb = DOUBLE.
-- payment_type og RatecodeID er koder (se dataordbog). Alle kolonner tillader NULL.

-- 1c. Lille udsnit
SELECT * FROM 'data/raw/yellow_tripdata_2025-01.parquet' LIMIT 5;
-- RESULTAT: Hver tur har tider, zoner, distance (miles) og beløb (USD).
-- UNDRER MIG: For VendorID 1 er total_amount 2,50 lavere end summen af beløbsfelterne.
-- Måske indgår congestion_surcharge allerede i extra.

-- 1d. Periode
SELECT MIN(tpep_pickup_datetime) AS foerste_pickup,
       MAX(tpep_pickup_datetime) AS sidste_pickup
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- RESULTAT: 2024-12-31 20:47 til 2025-02-01 00:00.
-- UNDRER MIG: Januar-filen har ture fra december og februar.

-- 1e. Ture uden for januar
SELECT COUNT(*) AS ture_uden_for_januar
FROM 'data/raw/yellow_tripdata_2025-01.parquet'
WHERE tpep_pickup_datetime <  TIMESTAMP '2025-01-01'
   OR tpep_pickup_datetime >= TIMESTAMP '2025-02-01';
-- RESULTAT: 22 ture – meget få. De bliver i raw-data.

-- 1f. Antal pickup-zoner
SELECT COUNT(DISTINCT PULocationID) AS antal_pickup_zoner
FROM 'data/raw/yellow_tripdata_2025-01.parquet';
-- RESULTAT: 261 af 265 zoner har pickups.

------------------------------------------------------------
-- 2. Eget analysespørgsmål: Hvordan betaler kunderne?
-- Én række = én betalingstype med antal ture, gns. fare og gns. tip.
------------------------------------------------------------
SELECT payment_type,
       COUNT(*)                   AS antal_ture,
       ROUND(AVG(fare_amount), 2) AS gns_fare,
       ROUND(AVG(tip_amount), 2)  AS gns_tip
FROM 'data/raw/yellow_tripdata_2025-01.parquet'
GROUP BY payment_type
ORDER BY antal_ture DESC;
-- RESULTAT: 1 = kort (ca. 70 %, gns. tip 4,11), 0 = Flex Fare (ca. 16 %),
-- 2 = kontant (ca. 11 %, tip 0,00). 3, 4 og 5 er små grupper.
-- BEGRÆNSNING: Kontante tips registreres ikke (dataordbog).
-- UNDRER MIG: Kode 0 er en stor gruppe og bør undersøges nærmere.

------------------------------------------------------------
-- 3. Sammenhæng mellem kilderne
-- Relation: PULocationID/DOLocationID = LocationID i zonefilen (TLC Taxi Zone).
-- Mange ture -> én zone (mange-til-én).
------------------------------------------------------------

-- 3a. Zonefilen
SELECT * FROM 'data/raw/taxi_zone_lookup.csv' LIMIT 5;
-- RESULTAT: Én række = én zone med Borough, Zone og service_zone.

-- 3b. Er LocationID unik?
SELECT COUNT(*) AS antal_raekker,
       COUNT(DISTINCT LocationID) AS unikke_id
FROM 'data/raw/taxi_zone_lookup.csv';
-- RESULTAT: 265 = 265. Unik, så en tur matcher højst én zone.

-- 3c. Join: ture og gns. fare pr. pickup-borough
-- Én række = én pickup-borough.
SELECT z.Borough,
       COUNT(*)                     AS antal_ture,
       ROUND(AVG(t.fare_amount), 2) AS gns_fare
FROM 'data/raw/yellow_tripdata_2025-01.parquet' AS t
LEFT JOIN 'data/raw/taxi_zone_lookup.csv' AS z
       ON t.PULocationID = z.LocationID
GROUP BY z.Borough
ORDER BY antal_ture DESC;
-- RESULTAT: Manhattan har ca. 89 % af pickups. Queens har høj gns. fare (48,35),
-- sandsynligvis pga. lufthavnene.
-- UNDRER MIG: "Unknown" og "N/A" matcher, men siger ikke hvor turen startede.

-- 3d. Kontrol: manglende matches
SELECT COUNT(*) AS ture_uden_zone
FROM 'data/raw/yellow_tripdata_2025-01.parquet' AS t
LEFT JOIN 'data/raw/taxi_zone_lookup.csv' AS z
       ON t.PULocationID = z.LocationID
WHERE z.LocationID IS NULL;
-- RESULTAT: 0. LEFT JOIN bruges, så manglende matches ville blive vist.

-- 3e. Kontrol: ekstra rækker
SELECT
    (SELECT COUNT(*) FROM 'data/raw/yellow_tripdata_2025-01.parquet') AS foer_join,
    (SELECT COUNT(*)
     FROM 'data/raw/yellow_tripdata_2025-01.parquet' AS t
     LEFT JOIN 'data/raw/taxi_zone_lookup.csv' AS z
            ON t.PULocationID = z.LocationID)                         AS efter_join;
-- RESULTAT: 3.475.226 før og efter. Ingen ekstra rækker.

-- 3f. Ændring: join på dropoff i stedet for pickup
-- Én række = én dropoff-borough.
SELECT z.Borough,
       COUNT(*)                     AS antal_ture,
       ROUND(AVG(t.fare_amount), 2) AS gns_fare
FROM 'data/raw/yellow_tripdata_2025-01.parquet' AS t
LEFT JOIN 'data/raw/taxi_zone_lookup.csv' AS z
       ON t.DOLocationID = z.LocationID
GROUP BY z.Borough
ORDER BY antal_ture DESC;
-- KONSEKVENS: Borough betyder nu hvor turen sluttede.
-- RESULTAT: Brooklyn 140.987 dropoffs mod 66.070 pickups.
-- EWR 6.873 dropoffs mod 377 pickups. Valget ændrer svaret.

------------------------------------------------------------
-- 4. Manualsider jeg brugte
------------------------------------------------------------
-- duckdb.org/docs/current/guides/file_formats/query_parquet – læse Parquet direkte
-- duckdb.org/docs/current/data/csv/overview                 – læse CSV direkte
-- duckdb.org/docs/current/sql/statements/describe           – kolonner og datatyper
-- duckdb.org/docs/current/sql/query_syntax/groupby          – GROUP BY
-- duckdb.org/docs/current/sql/query_syntax/from             – LEFT JOIN beholder alle ture
-- TLC Yellow Taxi Data Dictionary                           – payment_type-koder, zone-ID'er, kontante tips
--   https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf
