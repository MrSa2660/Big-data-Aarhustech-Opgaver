"""Check local data access. Students implement the analytical queries themselves."""
from pathlib import Path
import duckdb

raw = Path("data/raw")
files = [raw / "yellow_tripdata_2025-01.parquet", raw / "taxi_zone_lookup.csv"]
with duckdb.connect() as con:
    for file in files:
        if not file.is_file() or file.stat().st_size == 0:
            raise FileNotFoundError(f"Mangler data: {file}. Følg README eller kontakt underviseren.")
        reader = con.read_parquet if file.suffix == ".parquet" else con.read_csv
        if not reader(str(file)).limit(1).fetchall():
            raise ValueError(f"Datafilen er tom: {file}")
        print(f"Kan læses: {file}")
print("Setup OK.")
