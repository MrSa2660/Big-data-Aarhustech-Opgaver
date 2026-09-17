# 20556 – NYC Taxi: analytisk dataløsning

Løsningen går fra rå NYC Yellow Taxi-data til en model, et aggregate og en præsentation.
Dette README beskriver **den løsning, der faktisk virker**.

## Indhold

1. [Kom i gang](#1-kom-i-gang)
2. [Kør løsningen](#2-kør-løsningen)
3. [Hvad bygges](#3-hvad-bygges)
4. [Projektets mapper](#4-projektets-mapper)
5. [Dokumentation](#5-dokumentation)
6. [Hvis noget ikke virker](#6-hvis-noget-ikke-virker)

---

# 1. Kom i gang

Miljø: **Python 3.12 (64-bit)**, duckdb 1.5.5, pandas 3.0.5. Matplotlib bruges til grafen.

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m pip install matplotlib
```

> Python 3.14 32-bit virker ikke: der findes ingen færdigbygget DuckDB-pakke til den, og pip forsøger at kompilere fra kilde.

Hent data (hvis filerne ikke allerede ligger i `data/raw/`) og test opsætningen:

```powershell
.\.venv\Scripts\python.exe src/download_data.py
.\.venv\Scripts\python.exe src/check_setup.py
```

Testen skal slutte med `Setup OK.`

# 2. Kør løsningen

```powershell
# hele buildet: dimensions -> fact -> aggregate
.\.venv\Scripts\python.exe src/pipeline.py

# grafer og præsentationsside
.\.venv\Scripts\python.exe src/make_chart.py
```

Resultatet ligger i `output/top10_zoner.png`. Pipelinen kan køres igen uden at fordoble data.

Enkeltfiler kan køres hver for sig under udvikling:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/01_explore.sql
```

# 3. Hvad bygges

```text
data/raw/*.parquet, *.csv        raw – bevares uændret
        ↓ sql/02_dimensions.sql
dim_zone, dim_date               dimensioner (bruges i pickup- og dropoff-rollen)
        ↓ sql/03_fact_trip.sql
fact_trip                        én række pr. taxitur
        ↓ sql/04_aggregates.sql
agg_trip_daily_zone              én række pr. pickup-dato x pickup-zone
        ↓ src/make_chart.py
output/top10_zoner.png           top 10 pickup-zoner i januar
```

Alt afledt ligger i `data/warehouse/taxi_20556.duckdb` og kan bygges igen fra raw.

| Fil | Indhold |
|---|---|
| `sql/01_explore.sql` | Dataundersøgelse, gruppering og join til zonefilen (Dag01) |
| `sql/02_dimensions.sql` | `dim_zone`, `dim_date` + kontroller |
| `sql/03_fact_trip.sql` | `fact_trip`, kontroller og analysequeries |
| `sql/04_aggregates.sql` | Aggregate, kontroller og re-aggregering |
| `src/pipeline.py` | Reproducerbart build i rækkefølgen 02 → 03 → 04 |
| `src/make_chart.py` | Simpel graf: top 10 pickup-zoner |

# 4. Projektets mapper

```text
data/raw/        originale inputfiler (må ikke ændres)
data/warehouse/  DuckDB-database med afledte tabeller
sql/             SQL til udforskning, model og aggregat
src/             pipeline, runner og grafer
docs/            architecture.md og model.md
output/          præsentation
```

# 5. Dokumentation

- `docs/architecture.md` – data, analysebehov, dataflow, lagring/platform, bevaring og genskabelse, pipeline, ETL/ELT, streaming og parallelisering
- `docs/model.md` – grain, measures, dimensions, roller, diagram og kontroller

# 6. Hvis noget ikke virker

Test ét lag ad gangen fra raw og frem:

```text
1. Kan raw-data læses?        -> src/check_setup.py
2. Virker dimensionerne?      -> sql/02_dimensions.sql
3. Virker fact?               -> sql/03_fact_trip.sql
4. Virker aggregatet?         -> sql/04_aggregates.sql
5. Virker præsentationen?     -> src/make_chart.py
```

Pipelinen skriver hvilket trin og statement der kører, så den første fejl kan placeres. Ved fejl rulles buildet tilbage, og raw-data er altid urørt.