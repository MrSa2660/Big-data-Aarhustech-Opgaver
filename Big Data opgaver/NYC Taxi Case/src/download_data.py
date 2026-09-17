"""Download public NYC TLC input data for 20556."""
from pathlib import Path
from urllib.request import urlretrieve

DATA_DIR = Path("data/raw")
DATA_DIR.mkdir(parents=True, exist_ok=True)

FILES = {
    "yellow_tripdata_2025-01.parquet": "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-01.parquet",
    "taxi_zone_lookup.csv": "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv",
}

for filename, url in FILES.items():
    target = DATA_DIR / filename
    if target.exists() and target.stat().st_size > 0:
        print(f"OK: {target} already exists")
        continue

    partial = target.with_suffix(target.suffix + ".part")
    if partial.exists():
        partial.unlink()

    print(f"Downloading {filename} ...")
    urlretrieve(url, partial)
    partial.replace(target)
    print(f"Saved {target} ({target.stat().st_size:,} bytes)")

print("Done.")
