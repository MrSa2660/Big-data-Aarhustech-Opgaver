from __future__ import annotations

import sys
from pathlib import Path

import duckdb

DB_PATH = Path("duckdb_lab.duckdb")
OUTPUT_DIR = Path("output")


def split_sql(sql: str) -> list[str]:
    """A small splitter for this mini-lab. It expects one statement per semicolon."""
    statements: list[str] = []
    current: list[str] = []
    in_single = False
    in_double = False
    i = 0
    while i < len(sql):
        ch = sql[i]
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        if ch == ";" and not in_single and not in_double:
            statement = "".join(current).strip()
            if statement and not all(line.strip().startswith("--") or not line.strip() for line in statement.splitlines()):
                statements.append(statement)
            current = []
        else:
            current.append(ch)
        i += 1
    tail = "".join(current).strip()
    if tail and not all(line.strip().startswith("--") or not line.strip() for line in tail.splitlines()):
        statements.append(tail)
    return statements


def main() -> int:
    if len(sys.argv) != 2:
        print("Brug: python run_duckdb_file.py duckdb_minilab.sql")
        return 2

    sql_path = Path(sys.argv[1])
    if not sql_path.exists():
        print(f"Filen findes ikke: {sql_path}")
        return 2

    OUTPUT_DIR.mkdir(exist_ok=True)
    sql = sql_path.read_text(encoding="utf-8")
    statements = split_sql(sql)

    print(f"DuckDB-database: {DB_PATH.resolve()}")
    print(f"SQL-fil: {sql_path.resolve()}")
    print(f"Statements: {len(statements)}")

    if not statements:
        print("Der er endnu ingen SQL-statements at køre.")
        return 0

    with duckdb.connect(str(DB_PATH)) as con:
        for index, statement in enumerate(statements, start=1):
            print("\n" + "=" * 80)
            print(f"Statement {index}")
            print("-" * 80)
            print(statement)
            print("-" * 80)
            try:
                result = con.execute(statement)
                if result.description is not None:
                    print(result.fetchdf().to_string(index=False))
                else:
                    print("OK")
            except Exception as exc:
                print(f"FEJL: {exc}")
                return 1

    print("\nFærdig.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
