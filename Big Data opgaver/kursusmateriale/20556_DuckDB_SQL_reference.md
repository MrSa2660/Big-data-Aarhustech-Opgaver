# 20556 – DuckDB/SQL-reference

**Version 1.0**

Brug dette opslag til at finde relevant dokumentation. Du vælger selv SQL, tilpasser eksemplerne til data og kontrollerer resultaterne.

## Indhold

1. [Kør dit arbejde](#1-kør-dit-arbejde)
2. [Find den relevante manual](#2-find-den-relevante-manual)
3. [Brug dokumentationen](#3-brug-dokumentationen)
4. [Kontrollér resultatet](#4-kontrollér-resultatet)
5. [Hvis du går i stå](#5-hvis-du-går-i-stå)

---

# 1. Kør dit arbejde

Følg opstarten i starterprojektets `README.md`. Terminalen skal stå i projektets rod, hvor `README.md`, `src`, `sql` og `data` ligger. Setup-testen skal slutte med `Setup OK.`.

Gem din SQL-fil, og kør den på Windows:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/01_explore.sql
```

På macOS/Linux bruges `.venv/bin/python`. Alle queries i filen kører i rækkefølge, og resultaterne vises i terminalen. En fil med kun kommentarer giver besked om, at der endnu ikke er SQL at køre. Afgræns dataudsnit, så du ikke udskriver hele datasættet.

# 2. Find den relevante manual

| Det du skal undersøge | Officiel dokumentation |
|---|---|
| Datakilde og filernes betydning | [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) |
| Felter, enheder og koder | [Yellow Taxi Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf) |
| Læsning af Parquet | [DuckDB: Querying Parquet Files](https://duckdb.org/docs/current/guides/file_formats/query_parquet) |
| Læsning af CSV og typevalg | [DuckDB: CSV overview](https://duckdb.org/docs/current/data/csv/overview) |
| Schema og datatyper | [DuckDB: DESCRIBE](https://duckdb.org/docs/current/sql/statements/describe) |
| Optælling og andre aggregater | [DuckDB: Aggregate functions](https://duckdb.org/docs/current/sql/functions/aggregates) |
| Gruppering | [DuckDB: GROUP BY](https://duckdb.org/docs/current/sql/query_syntax/groupby) |
| Join-varianter og deres betydning | [DuckDB: FROM and JOIN](https://duckdb.org/docs/current/sql/query_syntax/from) |
| Ukendte og manglende værdier | [DuckDB: NULL values](https://duckdb.org/docs/current/sql/data_types/nulls) |
| Tabeller til tirsdag | [DuckDB: CREATE TABLE](https://duckdb.org/docs/current/sql/statements/create_table) |
| Dimensionel modellering | [Kimball: Modeling techniques](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/) |
| Eget diagram i Markdown | [Mermaid: Flowcharts](https://mermaid.js.org/syntax/flowchart.html) |

Brug søgningen i DuckDB-manualen til emner, der ikke står i tabellen. Kig både på syntaksen og på forklaringen af, hvad funktionen gør.

# 3. Brug dokumentationen

Formulér først, hvad din query skal undersøge. Find derefter den relevante del af manualen og prøv et lille eksempel med dine egne data. Kontrollér, at dit resultat besvarer spørgsmålet, og notér manualens URL sammen med den pointe, du brugte.

Når dataordbogen beskriver en kolonne, skal du sammenholde den med filens faktiske schema. Vær opmærksom på enheder, særlige kodeværdier og begrænsninger. Et feltnavn alene er ikke tilstrækkelig dokumentation for betydningen.

# 4. Kontrollér resultatet

Forklar, hvad én række betyder før og efter din query. Ved et join skal du kunne begrunde relationen, forklare din håndtering af manglende matches og undersøge, om rækker bliver mangedoblet.

Sammenhold en aggregering med dens input. Skeln mellem en dokumenteret observation og en mulig forklaring. Hvis data viser et usædvanligt beløb eller tidspunkt, skal du undersøge betydningen, før du beslutter at ændre noget.

# 5. Hvis du går i stå

Find det første trin, der ikke virker. Læs fejlmeddelelsen, og lav en så lille query som muligt, der stadig viser problemet. Kontrollér filsti, kolonnenavne og datatyper mod dokumentationen og de faktiske data.

Når du beder om hjælp, skal du kunne vise din forventning, det faktiske resultat, den manualside du har brugt, og hvad du allerede har afprøvet.
