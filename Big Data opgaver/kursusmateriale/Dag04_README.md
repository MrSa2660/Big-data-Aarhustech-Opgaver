# Dag04 – reproducerbar pipeline og arkitekturtillæg

**Revision 1.0 · 16. september 2026 · Lærling**

## Indhold

1. [Overfør til dit eksisterende projekt](#overfør-til-dit-eksisterende-projekt)
2. [Arbejd og kør](#arbejd-og-kør)
3. [Det skal du kunne vise](#det-skal-du-kunne-vise)

## Overfør til dit eksisterende projekt

Pak arkivet ud i en separat mappe. Pakken indeholder en ny Dag04-arbejdsfil til `src/pipeline.py` og et tillæg til dit eksisterende `docs/architecture.md`.

1. Gem en kopi af din nuværende `src/pipeline.py`, hvis du allerede har skrevet i den.
2. Overfør pakkens `src/pipeline.py` til projektets `src`-mappe. Den erstatter den tidligere Dag04-placeholder, men indeholder stadig kun rammer og TODO'er – ikke løsningen.
3. Åbn `docs/architecture_Dag04_tilfoejelse.md`. Kopiér afsnittet fra overskriften **Dag04 – processing og pipeline** til slutningen af dit eksisterende `docs/architecture.md`. Indsæt det kun én gang, og føj afsnittet til din indholdsfortegnelse.

Behold alle raw-filer og dit arbejde fra Dag01–Dag03. Tillægget er ikke en separat aflevering.

## Arbejd og kør

Dag04-afsnittet i `20556_Laerling_Ugecase_NYC_Taxi.md` ejer opgaven. Du skal selv implementere løsningen og bruge Python- og DuckDB-dokumentationen, når du mangler syntaks eller API-detaljer.

Pipeline-rækkefølgen skal følge tabellernes afhængigheder:

```text
02_dimensions.sql
→ 03_fact_trip.sql
→ 04_aggregates.sql
```

`01_explore.sql` er udforskende arbejde og indgår ikke i den reproducerbare rebuild-pipeline.

Kør fra rodmappen af dit eksisterende Taxi-projekt:

```powershell
.\.venv\Scripts\python.exe src/pipeline.py
```

På macOS/Linux bruger du miljøets Python-sti fra projektets `README.md`.

Kør pipelinen to gange og sammenlign de centrale kontroller. Afprøv derefter mindst ét fejlscenarie i en øvelseskopi eller ved midlertidigt at pege på en ufarlig testfil. Ret altid arbejdsfilerne tilbage bagefter. Slet ikke raw-data.

## Det skal du kunne vise

- en fuld, vellykket kørsel fra dimensions til aggregate;
- tydelig visning af aktuelt trin og en fejl, der stopper senere afhængige trin;
- en anden kørsel uden fordobling af afledte data;
- en forklaring af ETL/ELT med navngivet destination;
- et arkitekturdiagram for en tænkt streamingvariant;
- et konceptuelt paralleliseringsdesign med udløser, partitionering, workers, combine-trin og trade-off.

Der kræves ikke installation af Kafka, RabbitMQ, Airflow eller Spark.

