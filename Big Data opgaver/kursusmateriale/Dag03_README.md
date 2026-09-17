# Dag03 – aggregate og arkitekturtillæg

**Revision 1.0 · 15. september 2026 · Lærling**

## Indhold

1. [Overfør til dit eksisterende projekt](#overfør-til-dit-eksisterende-projekt)
2. [Arbejd og kør](#arbejd-og-kør)

## Overfør til dit eksisterende projekt

Pak først arkivet ud i en separat mappe. Pakken indeholder opgavekommentarer til `04_aggregates.sql` og et Dag03-tillæg til dit eksisterende `architecture.md`.

1. Overfør `sql/04_aggregates.sql` til projektets `sql`-mappe. Hvis du allerede har skrevet SQL i filen, indarbejder du opgavekommentarerne i din fil, så dit arbejde bevares.
2. Åbn `docs/architecture_Dag03_tilfoejelse.md`. Kopiér afsnittet fra overskriften **Dag03 – aggregate, lagring og genskabelse** til slutningen af dit eksisterende `docs/architecture.md`. Indsæt det kun én gang, og tilføj afsnittet til din indholdsfortegnelse.

Tillægget erstatter ikke dit arkitekturdokument. Fortsæt i de to eksisterende arbejdsfiler; der er ingen ekstra aflevering. Skabelonens Dag03-afsnit og tillægget har samme opgaveindhold.

## Arbejd og kør

Dag03-afsnittet i `20556_Laerling_Ugecase_NYC_Taxi.md` ejer opgaven. Skriv selv løsningen og brug DuckDB-manualen. TODO-filen indeholder ingen kørbar SQL, før du tilføjer din egen.

Fra rodmappen af dit eksisterende Taxi-projekt:

```powershell
.\.venv\Scripts\python.exe src/run_sql_file.py sql/04_aggregates.sql
```

Forudsætning: dine fungerende dimensioner og `fact_trip` fra Dag02. Ved genopbygning køres først `02_dimensions.sql`, derefter `03_fact_trip.sql` og til sidst `04_aggregates.sql` med samme runner. Brug Python-stien fra projektets `README.md` på macOS/Linux.

Raw-data, tidligere SQL, `model.md` og dit Dag01-arbejde skal bevares. Pipeline-implementeringen hører til Dag04.
