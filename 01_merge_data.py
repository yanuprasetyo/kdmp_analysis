# ============================================================
# 01_merge_data.py
# Merge data Simkopdes dengan data kemiskinan BPS
# per kabupaten/kota
#
# Penulis: Yanu Endar Prasetyo, Nimas Maninggar, Shabilla Rossinda
# Data: Simkopdes 2 Juni 2026 + BPS 2025
# ============================================================

import pandas as pd

# ── 1. Load data ─────────────────────────────────────────────
df_kop = pd.read_excel("data/Data_Koperasi_Desa_dengan_Koordinat.xlsx")
df_mis = pd.read_excel("data/Jumlah_Persentase_Penduduk_Miskin_2025.xlsx")

# ── 2. Bersihkan kolom numerik yang tersimpan sebagai string ──
df_kop["Volume Transaksi (2026)"] = pd.to_numeric(
    df_kop["Volume Transaksi (2026)"], errors="coerce"
).fillna(0)

def clean_num(s):
    try:
        return float(str(s).replace(".", "").replace(",", "."))
    except:
        return 0.0

for col in ["Simpanan Pokok", "Simpanan Wajib"]:
    df_kop[col] = df_kop[col].apply(clean_num)

# ── 3. Agregasi ke level kabupaten/kota ──────────────────────
kab = df_kop.groupby(["Provinsi", "Kabupaten/Kota"]).agg(
    jumlah_kopdes=("Jumlah Koperasi", "sum"),
    kopdes_memiliki_nib=("Koperasi Memiliki NIB", "sum"),
    kopdes_memiliki_npwp=("Koperasi Memiliki NPWP", "sum"),
    kopdes_telah_rat=("Koperasi Telah RAT (2025)", "sum"),
    simpanan_pokok=("Simpanan Pokok", "sum"),
    simpanan_wajib=("Simpanan Wajib", "sum"),
    kopdes_bertransaksi=("Volume Transaksi (2026)", lambda x: (x > 0).sum()),
    total_volume_transaksi=("Volume Transaksi (2026)", "sum"),
    jumlah_kecamatan=("Kecamatan", "count"),
).reset_index()

kab["pct_kopdes_bertransaksi"] = (
    kab["kopdes_bertransaksi"] / kab["jumlah_kopdes"] * 100
).round(2)
kab["rata_kopdes_per_kecamatan"] = (
    kab["jumlah_kopdes"] / kab["jumlah_kecamatan"]
).round(2)

# ── 4. Normalisasi nama untuk merge ──────────────────────────
def normalize_kab(s):
    """Tambahkan prefix KAB. jika belum ada KOTA di depan."""
    n = str(s).upper().strip()
    if n.startswith("KOTA "):
        return n
    return "KAB. " + n

def normalize_prov(s):
    """Harmonisasi nama provinsi antara Simkopdes dan BPS."""
    s = str(s).upper().strip()
    s = s.replace("DAERAH ISTIMEWA YOGYAKARTA", "DI YOGYAKARTA")
    s = s.replace("KEPULAUAN BANGKA BELITUNG", "BANGKA BELITUNG")
    return s

kab["full_kab"] = kab["Kabupaten/Kota"].str.upper().str.strip()
kab["key_prov"] = kab["Provinsi"].apply(normalize_prov)

df_mis["full_kab"] = df_mis["Kabupaten/Kota"].apply(normalize_kab)
df_mis["key_prov"] = df_mis["Provinsi"].apply(normalize_prov)

# ── 5. Merge pada dua key: provinsi + kabupaten ───────────────
merged = pd.merge(
    kab,
    df_mis[[
        "key_prov", "full_kab",
        "Jumlah penduduk miskin",
        "Persentase Penduduk Miskin (%)",
        "Persentase Balita Stunting (%)"
    ]],
    on=["key_prov", "full_kab"],
    how="inner"
).drop(columns=["full_kab", "key_prov"])

merged = merged.rename(columns={
    "Provinsi": "provinsi",
    "Kabupaten/Kota": "kabupaten_kota",
    "Jumlah penduduk miskin": "jumlah_penduduk_miskin",
    "Persentase Penduduk Miskin (%)": "pct_penduduk_miskin",
    "Persentase Balita Stunting (%)": "pct_balita_stunting",
})

# ── 6. Validasi ───────────────────────────────────────────────
print(f"Total baris    : {len(merged)}")
print(f"Kabupaten unik : {merged['kabupaten_kota'].nunique()}")
print(f"Duplikat       : {merged.duplicated(subset=['provinsi','kabupaten_kota']).sum()}")

# ── 7. Simpan ─────────────────────────────────────────────────
merged.to_excel("data/data_kopdes_kemiskinan_merged_v2.xlsx", index=False)
print("File disimpan: data/data_kopdes_kemiskinan_merged_v2.xlsx")
