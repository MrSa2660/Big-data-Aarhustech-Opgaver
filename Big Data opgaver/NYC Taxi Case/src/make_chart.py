"""20556 · Dag05 · simpel graf af eget datafund.

Spørgsmål: Hvilke 10 zoner har flest pickups i januar 2025?

Kør fra projektets rodmappe, efter at pipelinen har bygget tabellerne:
    .\\.venv\\Scripts\\python.exe -m pip install matplotlib
    .\\.venv\\Scripts\\python.exe src/make_chart.py

Resultat: output/top10_zoner.png
"""
import duckdb
import matplotlib.pyplot as plt

# 1. Hent data fra aggregatet (agg_trip_daily_zone) + dim_zone + dim_date.
SQL = """
SELECT z.zone_name,
       SUM(a.antal_ture) AS antal_ture
FROM agg_trip_daily_zone a
JOIN dim_zone z ON a.pickup_zone_key = z.zone_key
JOIN dim_date d ON a.pickup_date_key = d.date_key
WHERE d.year = 2025 AND d.month = 1
GROUP BY z.zone_name
ORDER BY antal_ture DESC
LIMIT 10
"""

con = duckdb.connect("data/warehouse/taxi_20556.duckdb", read_only=True)
data = con.execute(SQL).fetchall()
con.close()

# 2. Del resultatet op i navne og tal. [::-1] vender rækkefølgen,
#    så den største søjle står øverst i grafen.
zoner = [række[0] for række in data][::-1]
ture = [række[1] for række in data][::-1]

# 3. Tegn en vandret søjlegraf.
plt.figure(figsize=(9, 5))
plt.barh(zoner, ture, color="#2a78d6")
plt.title("10 zoner med flest pickups – januar 2025")
plt.xlabel("Antal ture")
plt.tight_layout()

# 4. Gem grafen som billede.
plt.savefig("output/top10_zoner.png", dpi=150)
print("Skrevet: output/top10_zoner.png")

# 5. Skriv også tallene i terminalen, så de kan læses op.
for zone, antal in zip(reversed(zoner), reversed(ture)):
    print(f"{zone:<32} {antal:>10,.0f}")