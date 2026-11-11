import os, glob
from getpass import getpass
import pandas as pd
from sqlalchemy import create_engine, URL, text

# Bu dosyanın bulunduğu klasörden bir üst klasöre çıkıp data'ya gidiyoruz
KLASOR = os.path.dirname(os.path.abspath(__file__))
VERI = os.path.join(KLASOR, "..", "data")

# 1. Veritabanına bağlan
sifre = getpass("PostgreSQL şifren: ")
url = URL.create(
    "postgresql+psycopg2",
    username="postgres",
    password=sifre,
    host="localhost",
    port=5432,
    database="olist",
)
engine = create_engine(url)

with engine.connect() as conn:
    print("Bağlantı başarılı:", conn.execute(text("SELECT version()")).scalar())

# 2. CSV'leri yükle
dosyalar = sorted(glob.glob(os.path.join(VERI, "*.csv")))
print(f"\n{len(dosyalar)} dosya bulundu\n")

for dosya in dosyalar:
    tablo = (os.path.basename(dosya)
             .replace("olist_", "")
             .replace("_dataset", "")
             .replace(".csv", ""))
    df = pd.read_csv(dosya)
    df.to_sql(tablo, engine, if_exists="replace", index=False,
              chunksize=5000, method="multi")
    print(f"{tablo:35} {len(df):>9,} satır yüklendi")

# 3. Kontrol et
print("\nVeritabanındaki tablolar:")
print(pd.read_sql(
    "SELECT table_name FROM information_schema.tables "
    "WHERE table_schema = 'public' ORDER BY table_name",
    engine,
))