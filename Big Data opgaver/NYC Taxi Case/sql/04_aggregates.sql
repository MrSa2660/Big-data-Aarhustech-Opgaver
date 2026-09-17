-- 20556 · Dag03 · aggregate
-- Kør efter 02 og 03:
--   .\.venv\Scripts\python.exe src/run_sql_file.py sql/04_aggregates.sql
--
-- ANALYSEBEHOV: Hvor mange ture starter i hver zone pr. dag, og hvordan
-- udvikler antal ture og gennemsnitlig distance sig hen over januar?
--
-- GRAIN fact_trip:            én række = én taxitur.
-- GRAIN agg_trip_daily_zone:  én række = én pickup-dato x én pickup-zone.
--
-- Der filtreres ikke. Alle ture fra fact_trip indgår, også ture uden for januar
-- og ture med distance 0. Filtre ville skulle bruges ens i alle sammenligninger.

------------------------------------------------------------
-- 1. Byg aggregatet
-- Vi gemmer SUMmer og TÆLLERE – ikke færdige gennemsnit.
-- Grunden: et gennemsnit kan ikke lægges sammen på tværs af grupper,
-- men SUM(distance) / COUNT(distance) kan genberegnes på et grovere grain.
------------------------------------------------------------
CREATE OR REPLACE TABLE agg_trip_daily_zone AS
SELECT
    f.pickup_date_key,
    f.pickup_zone_key,
    COUNT(*)                                                    AS antal_ture,
    COUNT(f.trip_distance)                                      AS ture_med_distance,  -- NULL tælles ikke med
    SUM(f.trip_distance)                                        AS sum_distance_miles,
    SUM(f.fare_amount)                                          AS sum_fare,
    SUM(f.total_amount)                                         AS sum_total,
    SUM(CASE WHEN f.trip_distance = 0 THEN 1 ELSE 0 END)        AS ture_med_distance_nul
FROM fact_trip f
GROUP BY f.pickup_date_key, f.pickup_zone_key;

------------------------------------------------------------
-- 2. Kontroller
------------------------------------------------------------

-- 2a. Forekommer hver kombination i mit grain kun én gang?
SELECT COUNT(*)                                                AS antal_raekker,
       COUNT(DISTINCT (pickup_date_key, pickup_zone_key))      AS unikke_kombinationer
FROM agg_trip_daily_zone;
-- RESULTAT: (skal være ens – så er grainet overholdt)

-- 2b. Afstemning mod fact: samme antal ture og samme afstandsgrundlag?
SELECT
    (SELECT COUNT(*)                 FROM fact_trip)            AS ture_fact,
    (SELECT SUM(antal_ture)          FROM agg_trip_daily_zone)  AS ture_agg,
    (SELECT ROUND(SUM(trip_distance), 2)     FROM fact_trip)            AS distance_fact,
    (SELECT ROUND(SUM(sum_distance_miles), 2) FROM agg_trip_daily_zone) AS distance_agg;
-- RESULTAT: (parvis ens)

-- 2c. NULL kontra nul: en registreret 0 er ikke det samme som manglende værdi
SELECT SUM(antal_ture)            AS ture_i_alt,
       SUM(ture_med_distance)     AS ture_med_maalt_distance,
       SUM(antal_ture) - SUM(ture_med_distance) AS ture_uden_distance_null,
       SUM(ture_med_distance_nul) AS ture_med_distance_lig_nul
FROM agg_trip_daily_zone;
-- RESULTAT:

-- 2d. Genkørsel: CREATE OR REPLACE bygger tabellen forfra,
-- så antallet er det samme efter anden kørsel (ingen fordobling).
SELECT COUNT(*) AS raekker_efter_koersel FROM agg_trip_daily_zone;
-- RESULTAT: (samme tal ved hver kørsel)

------------------------------------------------------------
-- 3. Brug aggregatet
------------------------------------------------------------

-- 3a. Analysebehov: ture pr. dag i januar (kan aggregatet svare på)
SELECT d.full_date,
       d.weekday_name,
       SUM(a.antal_ture)                                            AS antal_ture,
       ROUND(SUM(a.sum_distance_miles) / NULLIF(SUM(a.ture_med_distance), 0), 2) AS gns_distance_miles
FROM agg_trip_daily_zone a
JOIN dim_date d ON a.pickup_date_key = d.date_key
WHERE d.year = 2025 AND d.month = 1
GROUP BY d.full_date, d.weekday_name
ORDER BY d.full_date;
-- RESULTAT:

-- 3b. Top 10 pickup-zoner i januar
SELECT z.borough,
       z.zone_name,
       SUM(a.antal_ture) AS antal_ture
FROM agg_trip_daily_zone a
JOIN dim_zone z ON a.pickup_zone_key = z.zone_key
JOIN dim_date d ON a.pickup_date_key = d.date_key
WHERE d.year = 2025 AND d.month = 1
GROUP BY z.borough, z.zone_name
ORDER BY antal_ture DESC
LIMIT 10;
-- RESULTAT:

------------------------------------------------------------
-- 4. Sammenfat igen (aggregat af aggregat) og kontrollér mod fact
-- Gennemsnit beregnes som SUM / COUNT – ikke som AVG af gruppegennemsnit.
------------------------------------------------------------

-- 4a. Vægtet gennemsnit pr. bydel, beregnet fra aggregatet
SELECT z.borough,
       SUM(a.antal_ture)                                            AS antal_ture,
       ROUND(SUM(a.sum_distance_miles) / NULLIF(SUM(a.ture_med_distance), 0), 4) AS gns_distance_vaegtet
FROM agg_trip_daily_zone a
JOIN dim_zone z ON a.pickup_zone_key = z.zone_key
GROUP BY z.borough
ORDER BY antal_ture DESC;
-- RESULTAT:

-- 4b. Samme tal direkte fra fact_trip – kontrol af 4a
SELECT z.borough,
       COUNT(*)                            AS antal_ture,
       ROUND(AVG(f.trip_distance), 4)      AS gns_distance_fact
FROM fact_trip f
JOIN dim_zone z ON f.pickup_zone_key = z.zone_key
GROUP BY z.borough
ORDER BY antal_ture DESC;
-- RESULTAT: (skal matche 4a)

-- 4c. FORKERT metode til sammenligning: gennemsnit af gruppegennemsnit
-- Hver zone-dag vejer lige meget, uanset om den har 3 eller 30.000 ture.
SELECT z.borough,
       ROUND(AVG(a.sum_distance_miles / NULLIF(a.ture_med_distance, 0)), 4) AS gns_af_gruppegennemsnit
FROM agg_trip_daily_zone a
JOIN dim_zone z ON a.pickup_zone_key = z.zone_key
GROUP BY z.borough
ORDER BY z.borough;
-- RESULTAT: (afviger fra 4a/4b – derfor gemmer vi summer og tællere)

------------------------------------------------------------
-- 5. Hvad aggregatet IKKE kan svare på
-- Fx "hvad er gennemsnitsprisen pr. betalingstype?" eller
-- "hvilke dropoff-zoner bruges fra en bestemt pickup-zone?" –
-- payment_type og dropoff-zone indgår ikke i aggregatets grain.
-- Det kræver fact_trip:
------------------------------------------------------------
SELECT f.payment_type,
       COUNT(*)                     AS antal_ture,
       ROUND(AVG(f.fare_amount), 2) AS gns_fare
FROM fact_trip f
GROUP BY f.payment_type
ORDER BY antal_ture DESC;
-- RESULTAT:

------------------------------------------------------------
-- Manualsider
------------------------------------------------------------
-- duckdb.org/docs/current/sql/functions/aggregates      – COUNT(kolonne) tæller ikke NULL
-- duckdb.org/docs/current/sql/query_syntax/groupby      – grain styres af GROUP BY
-- duckdb.org/docs/current/sql/functions/utility#nullif  – NULLIF undgår division med nul
-- kimballgroup.com/.../dimensional-modeling-techniques/ – additive og ikke-additive measures
