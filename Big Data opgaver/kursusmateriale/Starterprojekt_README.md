# 20556 Taxi Starterprojekt

**Version 1.0**

Starterprojektet bruges i **20556 – Big Data modeller og datamodellering**.

## Indhold

1. [Kom i gang](#1-kom-i-gang)
2. [Hent og test data](#2-hent-og-test-data)
3. [Kør SQL](#3-kør-sql)
4. [Projektets mapper](#4-projektets-mapper)
5. [Mandag og tirsdag](#5-mandag-og-tirsdag)
6. [Hvis noget ikke virker](#6-hvis-noget-ikke-virker)

---

# 1. Kom i gang

Åbn **denne mappe som projekt**. Din terminal skal stå i mappen, hvor du kan se:

```text
README.md
requirements.txt
src/
sql/
data/
```

På Windows:

```powershell
python --version
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

På macOS/Linux bruges `.venv/bin/python` i stedet for Windows-stien.

Pakken bruger DuckDB 1.5.5 og pandas 3.0.5. Referencekombinationen er afprøvet med Python 3.12.14 på Windows. Har du en anden Python-version, så brug underviserens aftalte miljø og få installation og setup-test til at virke før det fælles SQL-arbejde. Du skal ikke selv skifte Python-version, hvis dit miljø allerede virker.

> Du behøver ikke aktivere miljøet. Kommandoerne bruger miljøets Python direkte.

---

# 2. Hent og test data

Hvis underviseren ikke allerede har udleveret datafilerne:

```powershell
.\.venv\Scripts\python.exe src/download_data.py
```

Efter download skal disse filer findes:

```text
data/raw/yellow_tripdata_2025-01.parquet
data/raw/taxi_zone_lookup.csv
```

Test setup:

```powershell
.\.venv\Scripts\python.exe src/check_setup.py
```

Testen skal slutte med:

```text
Setup OK.
```

Setup-testen kontrollerer, at filerne kan læses. Dine faglige undersøgelser og kontroller skriver du selv i SQL.

Data hentes fra NYC Taxi & Limousine Commissions offentlige datasæt.

---

# 3. Kør SQL

Mandag:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/01_explore.sql
```

Senere i ugen:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/02_dimensions.sql
.\.venv\Scripts\python.exe src/run_sql_file.py sql/03_fact_trip.sql
.\.venv\Scripts\python.exe src/run_sql_file.py sql/04_aggregates.sql
```

Torsdag implementerer du `src/pipeline.py`. Når din pipeline er klar, køres den sådan:

```powershell
.\.venv\Scripts\python.exe src/pipeline.py
```

Indtil torsdag køres SQL-filerne enkeltvis med `src/run_sql_file.py`. Det er derfor forventet, at den udleverede `pipeline.py` endnu ikke kan gennemføre processen.

---

# 4. Projektets mapper

```text
data/raw/        originale inputfiler
data/warehouse/  DuckDB-database
sql/             SQL til udforskning, model og aggregater
src/             små Python-værktøjer
docs/            arkitektur og datamodel
reference/       kort DuckDB/SQL-opslag
output/          senere præsentationer/output
```

Raw-filerne skal bevares uændret.

---

# 5. Mandag og tirsdag

## Mandag

Arbejd især i:

```text
sql/01_explore.sql
docs/architecture.md
```

Målet er at forstå dataene, lave et join og tegne det første dataflow.

SQL-filen indeholder opgavekrav som kommentarer. Du skriver selv dine undersøgelser, en relevant gruppering og et join, som du begrunder og kontrollerer. Find syntaks i den officielle dokumentation via referencearket. Skriv dataforklaring, 3–5 feltforklaringer, tre analysebehov og dit eget diagram i `docs/architecture.md`. Mindst ét analysebehov skal bruge Zone Lookup.

Når du kører en SQL-fil, udføres alle dens queries i rækkefølge. Resultaterne vises i terminalen. Brug `LIMIT` ved dataudsnit, og find det relevante resultat under dets `Statement`-nummer.

## Tirsdag

Arbejd især i:

```text
docs/model.md
sql/02_dimensions.sql
sql/03_fact_trip.sql
```

SQL-filerne angiver kravene, men indeholder ingen færdig model. Du skriver selv SQL og dokumenterer dine valg og kontroller i `docs/model.md`.

Torsdag implementerer du selv `src/pipeline.py`. Den skal køre dine SQL-trin i en begrundet rækkefølge, stoppe tydeligt ved manglende arbejde og kunne genkøres uden at fordoble data.

---

# 6. Hvis noget ikke virker

Start med:

```text
1. Står terminalen i projektets rodmappe?
2. Virker check_setup.py?
3. Findes filen på den sti, din query bruger?
4. Hvilket trin virkede sidst?
```

Kør kun videre, når det foregående trin virker.

En SQL-fil med kun kommentarer giver besked om, at der endnu ikke er SQL at køre. Det er forventet i den tomme elevskabelon. Ved faglige problemer: find den relevante manualside, lav et lille testeksempel, og medbring det sammen med din forventning og det faktiske resultat, når du beder om hjælp.

Kort SQL-reference findes i:

```text
reference/duckdb_sql_reference.md
```
