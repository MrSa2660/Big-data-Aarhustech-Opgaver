"""20556 · Dag04 · reproducerbar batch-pipeline.

Kør fra projektets rodmappe:
    .\\.venv\\Scripts\\python.exe src/pipeline.py

Rækkefølgen følger tabellernes afhængigheder:
    02_dimensions.sql  ->  dim_zone og dim_date
    03_fact_trip.sql   ->  fact_trip, som refererer til dimensionerne
    04_aggregates.sql  ->  agg_trip_daily_zone, som bygger på fact_trip

01_explore.sql er udforskning og indgår ikke i en rebuild.

Egenskaber:
- stopper med en tydelig fejl, hvis en SQL-fil mangler eller ikke har kørbar SQL
- viser hvilket trin og hvilket statement der kører
- kører hele buildet i én transaktion og ruller tilbage ved fejl,
  så der ikke efterlades et halvt bygget resultat
- kan køres igen med samme input uden at fordoble data,
  fordi SQL-filerne bruger CREATE OR REPLACE TABLE
- lukker forbindelsen både ved succes og ved fejl

Kilder:
- DuckDB Python API: https://duckdb.org/docs/current/api/python/overview
- extract_statements: https://duckdb.org/docs/current/api/python/reference/
- Transaktioner: https://duckdb.org/docs/current/sql/statements/transactions
"""
from pathlib import Path
import sys

import duckdb

DB_PATH = Path("data/warehouse/taxi_20556.duckdb")

# Rækkefølgen er selve afhængighedskæden – den må ikke byttes om.
STEPS = [
    ("Dimensions", Path("sql/02_dimensions.sql")),
    ("Fact", Path("sql/03_fact_trip.sql")),
    ("Aggregate", Path("sql/04_aggregates.sql")),
]

# Tabeller der skal findes, når pipelinen er kørt færdig.
EXPECTED_TABLES = ["dim_zone", "dim_date", "fact_trip", "agg_trip_daily_zone"]


class PipelineError(Exception):
    """Fejl som pipelinen selv opdager (manglende fil, tom fil, SQL-fejl)."""


def read_statements(con: duckdb.DuckDBPyConnection, sql_path: Path) -> list[str]:
    """Læs en SQL-fil og returnér dens statements.

    DuckDBs egen parser bruges, så kommentarer og semikolon inde i tekst
    håndteres korrekt i stedet for en blind split på ';'.
    """
    if not sql_path.exists():
        raise PipelineError(f"SQL-filen mangler: {sql_path}")

    sql = sql_path.read_text(encoding="utf-8")
    statements = [item.query for item in con.extract_statements(sql)]

    if not statements:
        raise PipelineError(
            f"{sql_path} indeholder ingen kørbar SQL (kun kommentarer). "
            "Skriv din SQL i filen, og gem den, før du kører pipelinen."
        )
    return statements


def first_sql_line(statement: str) -> str:
    """Find den første linje med rigtig SQL, så visningen ikke bare er en kommentar."""
    for line in statement.strip().splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith("--"):
            return stripped[:70]
    return statement.strip().splitlines()[0][:70]


def run_step(con: duckdb.DuckDBPyConnection, name: str, sql_path: Path, step_no: int, total: int) -> None:
    """Kør ét trin og vis, hvor langt pipelinen er nået."""
    print(f"\n[{step_no}/{total}] {name}: {sql_path}")
    statements = read_statements(con, sql_path)

    for i, statement in enumerate(statements, start=1):
        first_line = first_sql_line(statement)
        print(f"    statement {i}/{len(statements)}: {first_line} ...")
        try:
            con.execute(statement)
        except duckdb.Error as exc:
            raise PipelineError(
                f"Fejl i {sql_path}, statement {i}:\n    {first_line}\n    {exc}"
            ) from exc

    print(f"    OK: {name} færdig ({len(statements)} statements)")


def scalar(con: duckdb.DuckDBPyConnection, sql: str) -> int:
    """Hent ét enkelt tal fra en query.

    fetchone() kan returnere None (hvis der slet ingen rækker er), og SUM()
    returnerer NULL på en tom tabel. Begge dele håndteres her, så resten af
    koden altid får et tal.
    """
    row = con.execute(sql).fetchone()
    if row is None or row[0] is None:
        return 0
    return int(row[0])


def verify(con: duckdb.DuckDBPyConnection) -> None:
    """Kontrollér resultatet efter et build og vis rækketal pr. tabel."""
    print("\nKontrol efter build:")
    existing = {row[0] for row in con.execute("SHOW TABLES").fetchall()}

    missing = [t for t in EXPECTED_TABLES if t not in existing]
    if missing:
        raise PipelineError(f"Disse tabeller blev ikke bygget: {', '.join(missing)}")

    for table in EXPECTED_TABLES:
        antal = scalar(con, f"SELECT COUNT(*) FROM {table}")
        print(f"    {table:<22} {antal:>12,} rækker")

    # Afstemning: aggregatet skal indeholde lige så mange ture som fact_trip.
    ture_fact = scalar(con, "SELECT COUNT(*) FROM fact_trip")
    ture_agg = scalar(con, "SELECT SUM(antal_ture) FROM agg_trip_daily_zone")
    status = "OK" if ture_fact == ture_agg else "AFVIGELSE"
    print(f"    ture i fact = {ture_fact:,} / ture i aggregate = {ture_agg:,}  -> {status}")
    if ture_fact != ture_agg:
        raise PipelineError("Aggregatet stemmer ikke med fact_trip.")


def main() -> int:
    if not Path("sql").is_dir():
        print("FEJL: kør pipelinen fra projektets rodmappe (hvor sql/ og data/ ligger).")
        return 1

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    print(f"Database: {DB_PATH}")

    con = duckdb.connect(str(DB_PATH))
    try:
        # Hele buildet kører i én transaktion: enten bliver alle tabeller
        # opdateret, eller også rulles ændringerne tilbage.
        con.execute("BEGIN TRANSACTION")
        for step_no, (name, path) in enumerate(STEPS, start=1):
            run_step(con, name, path, step_no, len(STEPS))
        verify(con)
        con.execute("COMMIT")
        print("\nPipeline færdig. Alle trin gennemført.")
        return 0

    except PipelineError as exc:
        con.execute("ROLLBACK")
        print(f"\nPIPELINE STOPPET: {exc}")
        print("Efterfølgende trin blev ikke kørt, og databasen er rullet tilbage")
        print("til tilstanden før denne kørsel. Raw-data er urørt.")
        return 1

    finally:
        con.close()
        print("Databaseforbindelsen er lukket.")


if __name__ == "__main__":
    sys.exit(main())