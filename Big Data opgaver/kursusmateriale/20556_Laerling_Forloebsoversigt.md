# 20556 – Big Data modeller og datamodellering
## Forløbsoversigt for lærlinge

**Revision 1.8 · 16. september 2026**

## Indhold

1. [Forløbet i overblik](#1-forløbet-i-overblik)
2. [Dag01](#2-dag01)
3. [Dag02](#3-dag02)
4. [Dag03](#4-dag03)
5. [Dag04](#5-dag04)
6. [Dag05](#6-dag05)
7. [Hvis du bliver bagud](#7-hvis-du-bliver-bagud)
8. [Materialer og links](#8-materialer-og-links)

---

# 1. Forløbet i overblik

Du arbejder gennem forløbet på **én analytisk dataløsning** med NYC Taxi-data.

Du undersøger kilderne og udvikler et dataflow og en model, der understøtter dine analysebehov. Til sidst demonstrerer du et resultat fra løsningen og forklarer, hvordan resultatet er produceret.

| Dag | Aktuel placering | Aktuelt skema | Fokus |
|---|---|---:|---|
| Dag01 | Mandag | 5 × 60 min | Forstå data, DuckDB/Parquet og dataflow |
| Dag02 | Tirsdag | 6 × 60 min | Grain, facts, dimensions og star schema |
| Dag03 | Onsdag | 4 × 60 min | Aggregate, lagring og genskabelse |
| Dag04 | Torsdag | 5 × 60 min | Processing og pipeline |
| Dag05 | Fredag | 4 × 60 min | Præsentation og faglig forklaring |

Du arbejder med konkrete teknologier i LMS-materialer og starterprojekt: Parquet, CSV, DuckDB, SQL, Python, Markdown og Git. Teknologierne bruges til at træne fagets centrale kompetencer: at designe, opbygge, behandle, lagre og præsentere data i en mindre Big Data-løsning.

Opgavefilerne beskriver de konkrete krav. Dokumentation bruges aktivt, når du skal afklare syntaks, felter, datatyper og designvalg.

Hver dag har et **checkpoint**. Hvis du når checkpointet tidligt, arbejder du med faglig fordybelse frem for flere gentagelser af samme type opgave.

### Faglige links er støtte – ikke nye krav

De frit tilgængelige links i denne oversigt bruges til **opslag, genlæsning og fordybelse**. De ændrer ikke ugecasens afleveringskrav eller checkpoints. Start med dagens slides, ugecase og arbejdsfiler; brug derefter linksene, når du har brug for en anden forklaring eller den originale dokumentation.

---

# 2. Dag01

**Aktuel placering:** Mandag

## Hvad arbejder vi med?

Dag01 bygger grundlaget for resten af ugen. Du arbejder med:

1. operationelle og analytiske behov, herunder OLTP og OLAP;
2. raw-data og afledte resultater;
3. forskellen på Parquet som datafilformat og DuckDB som analytisk SQL-engine/database;
4. en kort DuckDB mini-lab på et lille øvedatasæt;
5. praktisk undersøgelse af Taxi-data med SQL;
6. kobling mellem tripdata og Zone Lookup;
7. første dataflow i `docs/architecture.md`.

Mini-labben bruger et lille salgsdatasæt, så du kan træne DuckDB-arbejdsformen, før du anvender den på NYC Taxi-data.

På det aktuelle hold bruges mini-labben som kort opsamling ved starten af Dag02, fordi Dag01 blev gennemført før denne del blev tilføjet. Dag01's checkpoint ændres ikke.

## Dagens checkpoint

Du skal have:

- et fungerende starterprojekt;
- `sql/01_explore.sql` med egne dataundersøgelser og en selvvalgt gruppering;
- et selvskrevet og kontrolleret join til Zone Lookup;
- tre analysebehov, hvor mindst ét bruger Zone Lookup;
- `docs/architecture.md` med kildehenvisninger, dataforklaringer og dit første dataflow.

Du skal kunne forklare:

- hvad én rå Taxi-række repræsenterer;
- forskellen på raw og afledte data;
- forskellen på Parquet-filen, DuckDB-engine'en, DuckDB-databasefilen og et query-resultat.

## Hvis du har mere tid

Undersøg flere felter i dataordbogen, skift pickup til dropoff i et relevant join, sammenlign CSV og Parquet i DuckDB mini-labben, eller brug `EXPLAIN` på en simpel query.

## Hvis du var syg / arbejder videre hjemme

Arbejd i denne rækkefølge:

```text
DuckDB mini-lab
→ README setup-test
→ ugecasens Dag01-afsnit
→ sql/01_explore.sql
→ docs/architecture.md
→ checkpoint
```

Der er ikke nye afleveringskrav ud over ugecasens Dag01-checkpoint. Mini-labben bruges til at forstå værktøjet.

## Ressourcer ved behov

- [Microsoft Learn – Online Transaction Processing (OLTP)](https://learn.microsoft.com/en-us/azure/architecture/data-guide/relational-data/online-transaction-processing) – brug især definitionen og de typiske egenskaber ved operationelle workloads.
- [Microsoft Learn – Online Analytical Processing (OLAP)](https://learn.microsoft.com/en-us/azure/architecture/data-guide/relational-data/online-analytical-processing) – brug til at genfinde, hvorfor analytiske workloads organiseres anderledes.
- [DuckDB – Reading and Writing Parquet Files](https://duckdb.org/docs/current/data/parquet/overview) – opslag til direkte query på Parquet.
- [NYC TLC – Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) og [Yellow Taxi Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf) – de konkrete kilder til Taxi-data og feltbetydninger.

---

# 3. Dag02

**Aktuel placering:** Tirsdag

## Hvad arbejder vi med?

Dag02 organiserer du Taxi-data, så de bliver lettere at analysere.

Du arbejder i denne rækkefølge:

```text
analysebehov fra Dag01
→ hvad betyder én række? / grain
→ første modelskitse
→ facts, measures og dimensions
→ star schema og role-playing dimensions
→ kort star/snowflake-sammenligning
→ kort Kimball/Inmon-perspektiv
→ DuckDB-tabeller
→ kontroller og analysequeries
```

Først arbejder du med, hvordan data bør organiseres ud fra analysebehovene. Derefter introduceres de faglige begreber og den fælles kernemodel.

## Dagens checkpoint

Du skal have:

- grain og modeldiagram i `docs/model.md`;
- `dim_date`, `dim_zone` og `fact_trip`;
- kontroller, der viser om relationerne dækker data og ikke giver uventet flere fact-rækker;
- to queries, der samlet bruger dato, zone og mindst ét numerisk measure ud over optælling.

Du skal kunne forklare:

- hvad grain betyder;
- forskellen på grain og primary key;
- forskellen på measure og dimension;
- hvorfor `dim_zone` og `dim_date` kan bruges i flere roller.

## Hvis du har mere tid

Tilføj fx `dim_payment`, tegn en snowflake-variant, undersøg natural/surrogate keys eller formulér en alternativ grain og forklar konsekvensen.

Fordybelse skal tilføje et nyt fagligt lag, ikke bare flere ens queries.

## Hvis du var syg / arbejder videre hjemme

Arbejd i rækkefølgen:

```text
genfind Dag02-slides og ugecase
→ vælg analysebehov
→ formulér grain
→ udfyld docs/model.md
→ byg dim_zone og dim_date
→ byg fact_trip
→ kontrollér relationerne
→ skriv to analysequeries
→ genfind star/snowflake og Kimball/Inmon-perspektivet
```

## Ressourcer ved behov

- [Kimball Group – Grain](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/grain/) – brug til at genfinde, hvorfor grain fastlægges før dimensions-/factdesign.
- [Kimball Group – Role-Playing Dimensions](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/role-playing-dimension/) – samme dimension brugt i forskellige roller.
- [Microsoft Learn – Understand star schema](https://learn.microsoft.com/en-us/power-bi/guidance/star-schema) – samlet reference til fact/dimension, star, snowflake, measures og role-playing dimensions.
- [Kimball Group – Dimensional Modeling Techniques](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/) – samlet indeks, hvis du vil genfinde et bestemt dimensional-model-begreb.

---

# 4. Dag03

**Aktuel placering:** Onsdag

## Hvad arbejder vi med?

Dag03 samler tre spørgsmål:

> Hvad skal vi gemme, hvor skal vi gemme det, og hvad kræver det at genskabe resultatet?

Du arbejder videre i dit eksisterende Taxi-projekt i:

```text
sql/04_aggregates.sql
docs/architecture.md
```

Dagen er opdelt i fire læringsblokke:

1. **Fra tur til sammenfatning:** Du bygger og kontrollerer mindst ét gemt aggregate. Du forklarer grain før og efter, og hvilke oplysninger der bevares eller mistes.
2. **Vælg lagring efter behov:** Du sammenligner relevante data stores og perspektiverer til warehouse, lake og lakehouse. Du skelner teknisk drift fra organisatorisk ejerskab og Data Mesh.
3. **Bevar det, der gør genskabelse mulig:** Du bruger raw, persistent state, versionering, retention, snapshot, backup og rebuild på projektets konkrete artefakter.
4. **Vis og begrund din løsning:** Du samler SQL og arkitekturdokumentation og afprøver forklaringen med en makker.

Den præcise opgave står i Dag03-afsnittet i `20556_Laerling_Ugecase_NYC_Taxi.md` og i TODO'erne i de to arbejdsfiler. Du skal ikke installere nye databasesystemer.

## Dagens checkpoint

Du skal kunne vise og forklare:

- et fungerende aggregate og kontroller af grain, ture og afstandsgrundlag;
- grain før og efter samt ét spørgsmål, aggregatet kan besvare, og ét, der kræver mere detaljerede data;
- en enkel storage-/platformskitse med ét begrundet valg og en begrænsning;
- hvilke konkrete artefakter der skal bevares for at kunne genskabe et vigtigt resultat.

Det er ét samlet checkpoint fra `04_aggregates.sql` og `architecture.md`.

## Hvis du har mere tid

Sammenlign to aggregates med forskelligt grain, eller prøv en faktisk genskabelse i en særskilt øvelseskopi. Slet ikke databasen i dit arbejdsprojekt. Pipeline og orkestrering hører til Dag04.

## Hvis du var syg / arbejder videre hjemme

Arbejd i rækkefølgen:

```text
genfind læringsblok A–C i Dag03-undervisningsslides
→ læs ugecasens Dag03-afsnit
→ indarbejd Dag03-pakken i dit eksisterende projekt
→ byg og kontrollér aggregatet i sql/04_aggregates.sql
→ udfyld Dag03-afsnittet i docs/architecture.md
→ gennemfør det samlede checkpoint
```

Brug ugecasen og arbejdsfilerne som opgavegrundlag. Dokumentér den første konkrete blocker, hvis et tidligere checkpoint mangler.

## Ressourcer ved behov

- [DuckDB – Aggregate Functions](https://duckdb.org/docs/stable/sql/functions/aggregates) – opslag til aggregates og bl.a. forskellen på `count(*)` og `count(column)`.
- [DuckDB – NULL Values](https://duckdb.org/docs/current/sql/data_types/nulls) – genfind hvordan `NULL` påvirker sammenligninger og aggregate-funktioner.
- [Microsoft Learn – Big Data Architectures](https://learn.microsoft.com/en-us/azure/architecture/databases/guide/big-data-architectures) – perspektiv på data lake, warehouse/lakehouse-lignende lag og forskellige dataflows. Brug den som arkitekturreference, ikke som krav om Azure.
- [Microsoft Learn – Technology choices for Azure solutions](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/technology-choices-overview) – brug især princippet om at vælge data store efter datamodel og adgangsmønster; konkrete Azure-produkter er ikke pensum.
- [DuckDB – Persistence](https://duckdb.org/docs/current/connect/overview) – forskellen på in-memory database og persistent databasefil.
- **Fordybelse:** Zhamak Dehghani, [Data Mesh Principles and Logical Architecture](https://martinfowler.com/articles/data-mesh-principles.html) – original reference til Data Mesh som ejerskabs-/organisationsperspektiv, ikke som databasetype.

---

# 5. Dag04

**Aktuel placering:** Torsdag

## Hvad arbejder vi med?

Dag04 samler fem læringsblokke:

1. **Batch og ETL/ELT:** Du placerer extract, load og transform i dit konkrete flow og navngiver destinationen.
2. **Fra SQL-filer til pipeline:** Du implementerer `src/pipeline.py` med tydelige dependencies og status under kørsel.
3. **Fejl og genkørsel:** Du afprøver stop/rollback og viser, at samme input ikke fordobler afledte data.
4. **Streaming, queue/log og orchestration:** Du tegner en tænkt event-baseret variant og fordeler ansvar mellem komponenterne.
5. **Parallel processing og checkpoint:** Du designer partitioner → workers → combine ud fra en konkret udløser og forklarer trade-offs.

Du arbejder videre i dit eksisterende Taxi-projekt i:

```text
src/pipeline.py
docs/architecture.md
```

Den præcise opgave står i Dag04-afsnittet i `20556_Laerling_Ugecase_NYC_Taxi.md` og TODO'erne i Dag04-patchen. Der kræves ikke Kafka, RabbitMQ, Airflow eller Spark.

## Dagens checkpoint

Du skal kunne vise og forklare:

- en vellykket pipelinekørsel i dependency-rækkefølge;
- en anden kørsel med samme input uden fordobling;
- et fejlscenarie, første fejlende trin og tilstanden bagefter;
- ETL/ELT med en navngivet destination;
- et streamingflow og ansvar for producer, queue/log, processor og orchestrator;
- et paralleliseringsdesign med udløser, partitionering, combine og trade-off.

## Hvis du har mere tid

Arbejd fx med logfil, køretidsmåling, ekstra måned/schema evolution eller en rigtig workflow-/producer-consumer-demo. Udvidelsen må ikke erstatte kernesporets checkpoint.

## Hvis du var syg / arbejder videre hjemme

Arbejd i rækkefølgen:

```text
genfind Dag04-slides og ugecase
→ indarbejd Dag04-patchen i dit eksisterende projekt
→ tegn dependencies og klassificér ETL/ELT
→ implementér og kør src/pipeline.py
→ genkør og kontrollér centrale counts/summer
→ afprøv ét sikkert fejlscenarie
→ udfyld streaming- og paralleliseringsafsnittene
→ gennemfør det samlede checkpoint
```

Hvis et tidligere SQL-trin ikke virker, dokumentér den første konkrete blocker og ret det led før pipelinen.

## Ressourcer ved behov

- [Microsoft Learn – What Is a Data Lake?](https://learn.microsoft.com/en-us/azure/architecture/data-guide/scenarios/data-lake) – brug især afsnittene om ingestion, transformation og ETL/ELT; Azure er kun eksempelplatform.
- [Apache Beam – Programming Guide](https://beam.apache.org/documentation/programming-guide/) – reference til bounded/unbounded data og batch/streaming-principper.
- [Apache Kafka – Introduction](https://kafka.apache.org/documentation/) – original introduktion til event streaming, producers/consumers, topics og retention.
- [RabbitMQ – AMQP 0-9-1 Model Explained](https://www.rabbitmq.com/tutorials/amqp-concepts) – queue, producer/consumer, acknowledgements og redelivery.
- [Apache Airflow – Architecture Overview](https://airflow.apache.org/docs/apache-airflow/stable/concepts/overview.html) – reference til DAGs, dependencies og orchestration. Installation af Airflow er ikke et Dag04-krav.
- [DuckDB – Python Client API](https://duckdb.org/docs/stable/clients/python/reference) – opslag til forbindelse, statement-kørsel og `extract_statements`.

---

# 6. Dag05

**Aktuel placering:** Fredag

## Hvad arbejder vi med?

Du bruger løsningen til at undersøge et selvvalgt spørgsmål og præsenterer resultatet.

## Dagens checkpoint

Du kan demonstrere:

```text
datakilde → raw → model → query/aggregate → præsentation
```

og forklare, hvad resultatet viser, samt mindst én begrænsning.

Der afsluttes med individuel faglig demonstration.

## Ressourcer ved behov

- [Microsoft Learn – Reports in the Power BI service](https://learn.microsoft.com/en-us/power-bi/consumer/end-user-reports) – brug især sammenligningen mellem reports og dashboards som begrebsreference; Power BI er ikke et obligatorisk værktøj i 20556.
- [IBM – What is Data Mining?](https://www.ibm.com/think/topics/data-mining) – begrebsreference til data mining og forskellen fra almindelig reporting.
- [Matplotlib – Pyplot tutorial](https://matplotlib.org/stable/tutorials/pyplot.html) – teknisk opslag, hvis Matplotlib bruges til den konkrete visualisering.

---

# 7. Hvis du bliver bagud

Find det første checkpoint, du ikke kan dokumentere:

```text
1. Kan jeg læse og forstå data?
2. Har jeg grain og en fungerende model?
3. Har jeg raw, modeled og aggregate?
4. Kan processen genkøres?
5. Kan jeg hente og forklare et resultat?
```

Arbejd på det første manglende led frem for at starte forfra.

Ved tekniske fejl: test ét lag ad gangen fra raw og frem.

---

# 8. Materialer og links

De konkrete arbejdsfiler og LMS-materialer er første indgang. De faglige webressourcer står ved den relevante dag ovenfor og er hjælp til opslag/genlæsning – ikke ekstra afleveringer.

## Materialer til Dag04

Start i [20556_Laerling_Ugecase_NYC_Taxi.md](../../Case/20556_Laerling_Ugecase_NYC_Taxi.md#5-dag04--processing-og-pipeline), og hent [20556_Dag04_starter_patch.zip](../../Case/Dag04/20556_Dag04_starter_patch.zip). Pak patchen ud i en separat mappe, læs dens `README.md`, og indarbejd den i dit eksisterende projekt uden at overskrive tidligere arbejde.

Du arbejder i:

```text
src/pipeline.py
docs/architecture.md
```

Brug Dag04-undervisningsslides i LMS til forklaring og repetition. Brug de officielle dokumentationslinks i Dag04-afsnittet, når du skal finde API- og arkitekturdetaljer.

## Materialer til Dag03

Start i [20556_Laerling_Ugecase_NYC_Taxi.md](../../Case/20556_Laerling_Ugecase_NYC_Taxi.md#4-dag03--raw-modeled-aggregate-og-datalivscyklus), og hent [20556_Dag03_starter_patch.zip](../../Case/Dag03/20556_Dag03_starter_patch.zip). Pak patchen ud i en separat mappe, læs dens `README.md`, og indarbejd den i dit eksisterende projekt uden at overskrive dit udfyldte `architecture.md`.

Du arbejder i:

```text
sql/04_aggregates.sql
docs/architecture.md
```

Brug Dag03-undervisningsslides i LMS til forklaring og repetition. Brug [20556_Laerling_Reference_DuckDB_SQL.md](20556_Laerling_Reference_DuckDB_SQL.md) som hurtigt opslag og de manualsider, ugecasen henviser til.

## Materialer til Dag02

Genfind Dag02-undervisningsslides i LMS. Brug [20556_Laerling_Ugecase_NYC_Taxi.md](../../Case/20556_Laerling_Ugecase_NYC_Taxi.md#3-dag02--grain-og-analytisk-datamodel) og arbejdsfilerne i dit eksisterende starterprojekt:

```text
docs/model.md
sql/02_dimensions.sql
sql/03_fact_trip.sql
```

Læs opstartsbeskeden i ugecasens Dag02-afsnit, før du bruger [20556_Dag02_starter_patch.zip](../../Case/Dag02/20556_Dag02_starter_patch.zip). Brug [20556_Laerling_Reference_DuckDB_SQL.md](20556_Laerling_Reference_DuckDB_SQL.md), når du skal finde syntaks til tabeller, joins, datoarbejde eller aggregater.

Hvis jeres hold allerede har fået `sales.csv` til de tidligere korte Dag02-sammenligningsøvelser, kan filen fortsat bruges til repetition. Den er ikke et nyt krav, og Taxi-data er fortsat hovedcasen.

## Materialer til Dag01

Start med [20556_DuckDB_minilab.zip](../Dag01/Lærling/20556_DuckDB_minilab.zip), hvis du har brug for at gentage forskellen på fil, engine, database og tabel. Denne mini-lab bruger sit eget lille salgsdatasæt.

Fortsæt derefter med [20556_Laerling_Ugecase_NYC_Taxi.md](../../Case/20556_Laerling_Ugecase_NYC_Taxi.md#2-dag01--forstå-data-og-løsningen), og følg `README.md` i dit starterprojekt.

Brug Dag01-undervisningsslides i LMS og [20556_Laerling_Reference_DuckDB_SQL.md](20556_Laerling_Reference_DuckDB_SQL.md) under arbejdet. Ugecasen beskriver de præcise opgaver og det, du skal kunne forklare.

---

## Revisionshistorik

| Version | Dato | Hovedændring |
|---|---|---|
| 1.0 | 14. september 2026 | Første forløbsoversigt til 20556 NYC Taxi-ugen. |
| **1.1** | **14. september 2026** | Mandag udbygget med OLTP/OLAP, Parquet/DuckDB og DuckDB mini-lab. Sprog opdateret efter projektets dokumentstandard. |
| **1.2** | **15. september 2026** | Tirsdag udbygget med problemorienteret modelprogression, tydeligere checkpoint, fraværsvej og materialehinvisninger. |
| **1.3** | **15. september 2026** | Dag02's minimum ændret til to analysequeries; stabile materialelinks og opstart af patchen præciseret. |
| **1.4** | **15. september 2026** | Filnavn, DagNN-terminologi og Dag02-perspektiver afstemt med projektets gældende dokumentstandard. |
| 1.5 | **16. september 2026** | Dag03 udbygget med fire læringsblokke, samlet checkpoint, fraværsvej og links til ugecase, patch og arbejdsfiler. Oversigten samlet som ugefælles lærlingedokument. |
| **1.6** | **16. september 2026** | Dag03-link opdateret til ugecasens faktiske overskrift. Dag01-navigation peger nu på den kanoniske ugecase og SQL-reference. |
| **1.7** | **16. september 2026** | Tilføjer dagsspecifikke, frit tilgængelige faglige ressourcer til opslag og genlæsning. Præciserer at ressourcerne er støtte og ikke nye afleveringskrav. Dag01–Dag03-checkpoints ændres ikke. |
| **1.8** | **16. september 2026** | Dag04 udbygget med fem læringsblokke, præcist samlet checkpoint, fraværsvej og links til ugecase, patch og arbejdsfiler. Opdaterer de tekniske Dag04-kilder til aktuelle officielle referencesider. Dag01–Dag03 er uændrede. |
