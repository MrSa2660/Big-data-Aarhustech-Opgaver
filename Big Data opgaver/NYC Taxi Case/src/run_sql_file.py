"""Run a SQL file against the local DuckDB database.

Usage:
    python src/run_sql_file.py sql/01_explore.sql
"""
from pathlib import Path
import sys
import duckdb

if len(sys.argv) != 2:
    print("Usage: python src/run_sql_file.py <path-to-sql-file>")
    sys.exit(1)

sql_path = Path(sys.argv[1])
if not sql_path.exists():
    raise FileNotFoundError(sql_path)

db_path = Path("data/warehouse/taxi_20556.duckdb")
db_path.parent.mkdir(parents=True, exist_ok=True)

sql = sql_path.read_text(encoding="utf-8")
con = duckdb.connect(str(db_path))

# DuckDBs parser håndterer kommentarer og semikolon inde i tekst korrekt.
statements = [item.query for item in con.extract_statements(sql)]

if not statements:
    print("Ingen SQL at køre endnu. Skriv dine queries under opgavekommentarerne, og gem filen.")

for i, statement in enumerate(statements, start=1):
    print(f"\n--- Statement {i} ---")
    print(statement[:500] + ("..." if len(statement) > 500 else ""))
    result = con.execute(statement)

    if result is not None and result.description:
        df = result.fetchdf()
        print(df.to_string(index=False))
    else:
        print("OK")

con.close()
