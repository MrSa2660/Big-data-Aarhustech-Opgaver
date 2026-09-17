# 20556 – Big Data modeller og datamodellering
## Ugecase: NYC Taxi – fra rå data til analytisk dataløsning

**Revision 1.7 · 16. september 2026**

> **Bemærk om den aktuelle gennemførelse:** Krav og checkpoints for Dag01–Dag03 ændres ikke retrospektivt. Revision 1.7 låser og konkretiserer Dag04; den indfører ingen nye afleveringskrav for de tre foregående dage.

## Indhold

1. [Opgaven og ugens mål](#1-opgaven-og-ugens-mål)
2. [Dag01 – forstå data og løsningen](#2-dag01--forstå-data-og-løsningen)
3. [Dag02 – grain og analytisk datamodel](#3-dag02--grain-og-analytisk-datamodel)
4. [Dag03 – raw, modeled, aggregate og datalivscyklus](#4-dag03--raw-modeled-aggregate-og-datalivscyklus)
5. [Dag04 – processing og pipeline](#5-dag04--processing-og-pipeline)
6. [Dag05 – præsentation og eget datafund](#6-dag05--præsentation-og-eget-datafund)
7. [Hvis du går i stå](#7-hvis-du-går-i-stå)
8. [Ugens slutprodukt](#8-ugens-slutprodukt)

---

# 1. Opgaven og ugens mål

New York City offentliggør store mængder data om taxiture. I denne uge bygger du en mindre analytisk dataløsning, der gør det muligt at gå fra rå tripdata til organiserede data, som kan forespørges, aggregeres og præsenteres.

Du arbejder hele ugen på **den samme løsning**. Den skal understøtte dine analysebehov, bevare de originale input og gøre det muligt at forklare og genskabe dine resultater. Du skal selv begrunde, hvordan de enkelte dele forbindes.

Kernedata:

```text
yellow_tripdata_2025-01.parquet
taxi_zone_lookup.csv
```

Yellow Taxi-filen indeholder registreringer af taxiture. Zone Lookup-filen giver menneskelige beskrivelser til de zone-id'er, der bruges som pickup- og dropoff-lokationer.

> **Raw-data skal bevares uændret.** Bearbejdning og afledte tabeller laves i andre lag.

## Projektstruktur

Du arbejder i det udleverede starterprojekt:

```text
Starterprojekt/
├── data/
│   ├── raw/
│   └── warehouse/
├── sql/
│   ├── 01_explore.sql
│   ├── 02_dimensions.sql
│   ├── 03_fact_trip.sql
│   └── 04_aggregates.sql
├── src/
├── output/
├── docs/
│   ├── architecture.md
│   └── model.md
└── README.md
```

Konkrete installations- og opstartstrin står i `README.md`.

Start i `README.md` i dit starterprojekt. Brug [20556_Laerling_Reference_DuckDB_SQL.md](../Materiale/Lærling/20556_Laerling_Reference_DuckDB_SQL.md) som opslag undervejs.

---

# 2. Dag01 – forstå data og løsningen

**Aktuel placering:** Mandag

## Mål

Dag01 handler om at forstå inputdata og den løsning, vi er på vej til at bygge. Du skal kunne læse dataene, koble dem sammen og forklare, hvad de kan bruges til.

Du arbejder især i:

```text
sql/01_explore.sql
docs/architecture.md
```

## Opgaver

**Undersøg data.** Skriv selv SQL til antal rækker, schema/datatyper, et lille udsnit, tidligste/seneste pickup-tidspunkt og antal forskellige pickup-lokationer. Tilføj en selvvalgt gruppering, der undersøger et relevant spørgsmål. Forklar kort i SQL-kommentarer, hvad resultaterne viser. Notér uventede værdier uden at ændre raw-data.

**Forbind kilderne.** Undersøg Zone Lookup, find og begrund relationen til tripdata, og skriv selv et join. Kontrollér for manglende matches og for, om joinet giver ekstra rækker. Afprøv én meningsfuld ændring og forklar konsekvensen. Dit join og din gruppering må gerne indgå i samme query.

**Forklar og design.** Beskriv, hvad én række i hvert input repræsenterer. Slå 3–5 relevante felter op i TLC's dataordbog, og angiv betydning, enheder og kildehenvisning. Formulér tre analysebehov, der kan undersøges med de udleverede data; mindst ét skal bruge Zone Lookup. Tegn selv et dataflow til analysebehovene. Forklar rå og afledte data, og markér, hvad der virker nu, og hvad der først bygges senere.

Gem alle queries og korte resultatforklaringer i `sql/01_explore.sql`. Gem dataforklaringer, analysebehov og diagram i `docs/architecture.md`. Gem SQL-filen, før du kører den igen.

På H4 forventes det, at du selv opsøger og anvender dokumentation. [20556_Laerling_Reference_DuckDB_SQL.md](../Materiale/Lærling/20556_Laerling_Reference_DuckDB_SQL.md) viser relevante manualsider. Notér de sider, du faktisk brugte, og hvad de hjalp dig med. Du skal kunne forklare og tilpasse din løsning, også når du bruger et eksempel fra en manual.

## Checkpoint

Ved dagens afslutning skal du kunne vise:

- et fungerende starterprojekt og egne dataundersøgelser med en relevant gruppering
- et selvskrevet join, kontroller af resultatet og en forklaret ændring
- dataforklaringer med kilder og tre relevante analysebehov
- dit eget dataflow med begrundelse for rå og afledte data

Vis dit arbejde fra de to filer, og forklar, hvad én række betyder både i input og i et af dine resultater.

## Hvis du vil mere

Når checkpointet virker, kan du undersøge flere felter i dataordbogen, kontrollere antal rækker før og efter et join eller bruge `EXPLAIN` på en simpel query.

Du skal ikke begynde på den endelige fact/dimension-model før Dag02.

---

# 3. Dag02 – grain og analytisk datamodel

**Aktuel placering:** Tirsdag

## Opstart i dit eksisterende projekt

Pak [20556_Dag02_starter_patch.zip](Dag02/20556_Dag02_starter_patch.zip) ud **i rodmappen af det starterprojekt, du brugte Dag01** — den mappe, hvor `README.md`, `sql` og `docs` ligger. Arkivet overskriver kun `docs/model.md`, `sql/02_dimensions.sql` og `sql/03_fact_trip.sql`; behold dit Dag01-arbejde. Har du allerede skrevet i en af de tre filer, så gem din egen kopi først. Kontrollér, at de nye TODO'er står i filerne.

Når du har skrevet og gemt din egen SQL, kører du filerne i denne rækkefølge på Windows:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/02_dimensions.sql
.\.venv\Scripts\python.exe src/run_sql_file.py sql/03_fact_trip.sql
```

På macOS/Linux bruger du miljøets Python-sti fra projektets `README.md`.

## Mål

På Dag02 organiserer du data til analyse. Dagens vigtigste spørgsmål er:

> **Hvad betyder én række, og hvordan gør vi data nemme at analysere?**

Du arbejder først med analysebehov og modelskitse. Derefter sætter vi faglige begreber på modellen og implementerer den i DuckDB.

## Første modelskitse

Vælg 2–3 analysebehov fra Dag01. Skriv for hvert behov:

- hvilke oplysninger du skal bruge;
- hvad du vil tælle, måle eller gruppere efter;
- hvad én række i de centrale data bør repræsentere.

Tegn derefter en første datastruktur, der kan understøtte dine analysebehov. Brug almindelige ord først. Begreberne fact, measure, dimension og star schema sættes på i den fælles opsamling.

## Kernemodel

Efter den fælles opsamling arbejder du videre med denne kernemodel:

```text
fact_trip
dim_date
dim_zone
```

`dim_zone` bruges både som pickup- og dropoff-dimension. `dim_date` bruges både som pickup- og dropoff-dato.

I den fælles undervisning sammenligner vi desuden kort star og snowflake samt Kimball- og Inmon-inspirerede integrationsretninger. Det er perspektivering til modelvalget og giver **ikke** en ekstra afleveringsopgave.

## Opgaver

Formulér grain for `fact_trip`. Begrund formuleringen ud fra datakilden og dine analysebehov, før du vælger nøgler og measures.

Identificér derefter relevante measures og dimensions og dokumentér modellen i `docs/model.md`.

Implementér `dim_zone`, `dim_date` og `fact_trip`. Dag02's to analysequeries gemmes nederst i `sql/03_fact_trip.sql`.

De to queries skal samlet:

- bruge `dim_date`;
- bruge `dim_zone`;
- bruge mindst ét numerisk measure ud over optælling.

Mindst én query skal besvare et analysebehov fra Dag01.

## Checkpoint

Ved dagens afslutning skal du kunne vise:

- grain og modeldiagram i `docs/model.md`;
- fungerende `dim_date`, `dim_zone` og `fact_trip`;
- to analysequeries mod modellen;
- kontrol af at pickup/dropoff-relationerne dækker data og ikke giver uventet flere fact-rækker.

Du skal kunne forklare forskellen på **grain**, **primary key**, **measure** og **dimension**.

## Hvis du vil mere

Når kernemodellen virker, kan du fx tilføje `dim_payment`, undersøge natural/surrogate keys, tegne en snowflake-variant eller formulere en alternativ grain.

Fordybelse skal gøre modellen eller din forklaring bedre – ikke bare give flere tabeller.

---

# 4. Dag03 – raw, modeled, aggregate og datalivscyklus

**Aktuel placering:** Onsdag

## Mål

På Dag03 undersøger du, hvad der sker, når detaljerede data aggregeres, og hvordan forskellige dele af en dataløsning kan lagres og genskabes.

Dagens hovedspørgsmål er:

> **Hvad skal vi gemme, hvor skal vi gemme det, og hvad skal der til for at kunne genskabe det?**

I dette dokument bruges **aggregate** som fagterm. At aggregere betyder her at gruppere detaljerede rækker og beregne fx antal, sum eller gennemsnit, så resultatet får et nyt grain.

Du bygger videre på dit eksisterende arbejde. Du starter ikke en ny løsning.

## Aggregate og informationstab

Arbejd i:

```text
sql/04_aggregates.sql
```

Vælg et relevant analysebehov og byg mindst ét materialiseret aggregate fra den analytiske model fra Dag02.

Du skal:

- formulere aggregatets grain;
- begrunde grupperinger og beregninger;
- kontrollere, at resultatet passer til det grain, du har valgt;
- bruge aggregatet til mindst én analyse;
- vise mindst ét spørgsmål, aggregatet kan besvare;
- vise mindst ét spørgsmål, der kræver mere detaljerede data;
- undersøge, hvad der sker, når resultatet aggregeres endnu en gang.

Hvis du arbejder med gennemsnit på tværs af grupper, skal du kunne forklare, hvilke summer og tællere der er nødvendige for at kombinere resultater korrekt.

## Udbyg din eksisterende arkitektur

Åbn din **eksisterende**:

```text
docs/architecture.md
```

Behold dit Dag01-arbejde. Tilføj et nyt Dag03-afsnit eller en ny revideret skitse, så dokumentet også viser:

```text
raw
→ modeled  (den detaljerede analytiske model fra Dag02)
→ aggregate
```

Forklar kort:

- hvad der er originalt og hvad der er afledt;
- hvor de tre lag ligger i dit nuværende projekt;
- hvad der kan genbygges;
- ét begrundet valg af data store ud fra et konkret adgangsmønster, med én begrænsning og ét relevant alternativ;
- hvordan Data Warehouse, Data Lake og Lakehouse kan bruges som perspektiv på løsningen;
- hvorfor Data Mesh handler om ejerskab/governance og ikke er en databasetype.

Du skal ikke installere nye databasesystemer for at løse denne del.

## Datalivscyklus og recovery

Brug konkrete artefakter fra dit eget projekt, fx:

```text
raw Parquet/CSV
SQL/kode
DuckDB modeled data
aggregate
eventuelt publiceret resultat
```

Forklar forskellen på:

```text
persistent state
dataversion
retention
snapshot
backup
rebuild
```

Beskriv derefter, hvad du skulle have bevaret, hvis din afledte DuckDB-database blev slettet, og du senere skulle forklare eller genskabe et vigtigt tidligere resultat.

Husk:

```text
Git ≠ databackup
checksum ≠ backup
snapshot ≠ raw-data
rebuild ≠ restore fra backup
```

## Checkpoint

Ved dagens afslutning skal du kunne vise og forklare:

- mindst ét fungerende aggregate;
- grain for den detaljerede model og for aggregatet;
- mindst ét spørgsmål aggregatet kan besvare;
- mindst ét spørgsmål der kræver mere detaljerede data;
- din udbyggede data store-/platformskitse i `docs/architecture.md`;
- forskellen på raw, persistent state, versionering, retention, snapshot, backup og rebuild;
- hvilke artefakter der skal bevares for at kunne genskabe et vigtigt resultat.

Dette er ét samlet checkpoint, ikke separate afleveringer.

## Hvis du vil mere

Når kernesporet virker, kan du fx:

- sammenligne to aggregates med forskelligt grain;
- undersøge hvilke measures der kan kombineres korrekt på tværs af grupper;
- sammenligne et materialiseret aggregate med beregning direkte fra fact-tabellen;
- lave en mere detaljeret lakehouse- eller Data Mesh-skitse;
- gennemføre en recovery-test i en kopi af projektet.

Fordybelse skal give et nyt fagligt lag, ikke bare flere ens queries.

---

# 5. Dag04 – processing og pipeline

**Aktuel placering:** Torsdag

## Opstart i dit eksisterende projekt

Hent [20556_Dag04_starter_patch.zip](Dag04/20556_Dag04_starter_patch.zip), pak den ud i en separat mappe, og læs pakkens `README.md`.

Du arbejder videre i det Taxi-projekt, du allerede har brugt. Behold raw-data, SQL og dokumentation fra Dag01–Dag03. Patchen indeholder:

```text
src/pipeline.py
docs/architecture_Dag04_tilfoejelse.md
```

Gem din nuværende `pipeline.py`, hvis du allerede har skrevet i den. Overfør derefter arbejdsfilen til `src`, og kopiér Dag04-afsnittet ind i dit eksisterende `docs/architecture.md` som beskrevet i patchens README.

## Mål

På Dag04 gør du processen fra raw til aggregate reproducerbar og forklarer, hvordan samme problem ændrer sig ved løbende events og større datamængder.

Dagens hovedspørgsmål er:

> **Hvordan gør vi et afhængigt dataflow genkørbart, synligt og muligt at fejlfinde?**

## Implementér batch-pipelinen

Implementér selv `src/pipeline.py`. Den skal køre:

```text
02_dimensions.sql
→ 03_fact_trip.sql
→ 04_aggregates.sql
```

Rækkefølgen skal begrundes med tabellernes dependencies. `01_explore.sql` er udforskning og er derfor ikke et build-trin.

Pipelinen skal:

- bruge den lokale DuckDB-database i `data/warehouse/taxi_20556.duckdb`;
- stoppe tydeligt, hvis en påkrævet SQL-fil mangler eller ikke indeholder kørbar SQL;
- vise hvilket trin og statement der kører, så første fejl kan placeres;
- køre afhængige trin i korrekt rækkefølge og undlade senere trin efter fejl;
- undgå at efterlade en delvist publiceret build, hvis et trin fejler;
- lukke databaseforbindelsen ved både succes og fejl;
- kunne køres igen med samme input uden at fordoble de afledte data.

Brug DuckDBs parser til SQL-filerne frem for selv at splitte tekst blindt ved hvert semikolon. Du må gerne opdele Python-koden i flere funktioner, hvis ansvaret bliver tydeligere.

Kør fra projektets rodmappe:

```powershell
.\.venv\Scripts\python.exe src/pipeline.py
```

Kør først din løsning med de fungerende SQL-filer. Kør den derefter igen og sammenlign relevante kontroller. Afprøv mindst ét fejlscenarie i en øvelseskopi eller med en ufarlig midlertidig ændring, som du retter tilbage bagefter. Raw-data må ikke slettes eller ændres.

## Forklar flowet i `docs/architecture.md`

Udfyld Dag04-afsnittet fra patchen. Dokumentationen skal vise og begrunde:

- den implementerede batch-pipeline, dens dependencies og fejl-/commit-adfærd;
- ETL og/eller ELT med en navngivet destination;
- forskellen mellem genkørsel med samme input og indlæsning af et nyt månedligt batch;
- en tænkt streamingvariant med producer, queue/log, processor, data store og anvendelse;
- forskellen på transformation, queue/log og orchestration;
- et konceptuelt paralleliseringsdesign med udløser, partitioner, workers, combine og trade-off;
- hvad der faktisk er implementeret/testet, og hvad der kun er foreslået.

Et diagram skal have konkrete labels og pile, der forklarer handlingen. Produktnavne er ikke i sig selv en arkitekturforklaring.

## Checkpoint

Ved dagens afslutning skal du kunne vise og forklare:

1. en vellykket kørsel af `src/pipeline.py` fra dimensions til aggregate;
2. en genkørsel med samme input og kontroller, der viser, at data ikke blev fordoblet;
3. et afprøvet fejlscenarie, hvor du kan pege på første fejl og forklare tilstanden bagefter;
4. din ETL/ELT-klassifikation med navngivet destination;
5. streamingdiagrammet og rollerne for producer, queue/log, processor og orchestrator;
6. paralleliseringsdiagrammet med konkret udløser, partitionering, combine-trin og mindst ét trade-off.

Dette er ét samlet checkpoint i `src/pipeline.py` og `docs/architecture.md`.

## Hvis du vil mere

Når kernesporet virker, kan du udvide med logfil, køretidsmåling eller en test mod en ny månedsfil. Påstå ikke støtte for inkrementel indlæsning, schema evolution eller deduplikering, før du har designet og testet dem.

Du skal ikke installere Kafka, RabbitMQ, Airflow eller Spark for at gennemføre Dag04.

---

# 6. Dag05 – præsentation og eget datafund

**Aktuel placering:** Fredag

På Dag05 bruger du den løsning, du har bygget.

Vælg et relevant spørgsmål i dataene, lav den nødvendige query/aggregation og vis resultatet på en passende måde.

Du skal kunne forklare:

- hvad du undersøgte
- hvordan resultatet blev produceret
- hvad resultatet viser
- mindst én begrænsning i fortolkningen

Der afsluttes med individuel demonstration og faglig samtale.

---

# 7. Hvis du går i stå

Find det første lag, der ikke virker:

```text
Kan raw-data læses?
→ virker Zone Lookup?
→ virker dimensions?
→ virker fact?
→ virker joins?
→ virker aggregate?
→ virker query?
→ virker præsentation?
```

Spørg derefter:

```text
Hvad forventede jeg?
Hvad skete faktisk?
Hvor opstår forskellen første gang?
Hvordan kan jeg teste netop det lag?
```

Hvis du har været fraværende, skal du ikke lave en særskilt sygeopgave. Find det første checkpoint, du mangler, og arbejd frem derfra.

---

# 8. Ugens slutprodukt

Ved ugens afslutning skal du have en mindre sammenhængende dataløsning med:

- bevarede raw-inputs og en dokumenteret grain/model
- en reproducerbar vej fra raw til analytiske data og mindst ét aggregate
- queries og en enkel præsentation af et selvvalgt datafund
- kort teknisk dokumentation i README og diagrammer

README skal beskrive **den løsning, der faktisk virker**. Den skal ikke være en traditionel rapport.

## Ressourcer og opslag

De dagsspecifikke links til gratis genlæsning og fordybelse findes i [20556_Laerling_Forloebsoversigt.md](../Materiale/Lærling/20556_Laerling_Forloebsoversigt.md). Ressourcerne nedenfor er centrale opslag til ugecasen og skaber ikke nye afleveringskrav.

NYC Taxi & Limousine Commission – Trip Record Data:  
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

Yellow Taxi Data Dictionary:  
https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf

DuckDB – Guides:  
https://duckdb.org/docs/current/guides/overview

Kimball Group – Dimensional Modeling Techniques:  
https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/

## Revisionshistorik

| Version | Dato | Hovedændring |
|---|---|---|
| 1.0 | 14. september 2026 | Første ugecase til 20556 NYC Taxi-ugen. |
| 1.1 | 15. september 2026 | Dag02 justeret, så lærlingene starter med analysebehov og modelskitse før de formelle begreber og den fælles kernemodel. |
| 1.2 | 15. september 2026 | Dag02-opstart præciseret, og checkpointet justeret til to analysequeries. Henvisninger bruger stabile filnavne. |
| 1.3 | 15. september 2026 | Filnavn og DagNN-terminologi harmoniseret; star/snowflake og Kimball/Inmon fastholdt som fælles perspektivering uden ekstra aflevering. |
| 1.4 | 15. september 2026 | Dag03 konkretiseret med aggregate/informationstab, udbygning af eksisterende `architecture.md`, storage/platforme og datalivscyklus/recovery. |
| **1.5** | **16. september 2026** | Dag03's storekrav harmoniseret til ét grundigt begrundet valg med begrænsning og alternativ. Dag03-overskrift og TOC-anchor rettet. |
| **1.6** | **16. september 2026** | Terminologisk og navigationsmæssig præcisering uden nye krav: `sammenfattes` ændret til `aggregeres`, `aggregate` forklares kort, `modeled` kobles eksplicit til Dag02-modellen, `storage-/platformskitse` præciseres til `data store-/platformskitse`, og dagsspecifikke gratis ressourcer henvises til forløbsoversigten. Dag01–Dag03's krav og checkpoints er uændrede. |
| **1.7** | **16. september 2026** | Dag04 låst med præcis patch-opstart, pipelinekontrakt, fejl- og genkørselsafprøvning, arkitekturdokumentation samt samlet checkpoint for batch, ETL/ELT, streaming, orchestration og konceptuel parallel processing. Dag01–Dag03 er uændrede. |
