# Analisis Koperasi Desa Merah Putih (KDMP) dan Kemiskinan

Repositori ini berisi data dan script analisis untuk artikel:
**"Celah Kegagalan Koperasi Desa Merah Putih: Kapasitas Ekonomi Desa yang Tidak Merata"**
diterbitkan di *The Conversation Indonesia*.

## Penulis
- Yanu Endar Prasetyo (Pusat Riset Kependudukan, BRIN)
- Nimas Maninggar (Pusat Riset Kependudukan, BRIN)
- Shabilla Rossinda (Mahasiswa Administrasi Publik, Universitas Brawijaya)

---

## Struktur Repositori

```
kdmp_analysis/
├── data/
│   ├── Data_Koperasi_Desa_dengan_Koordinat.xlsx        # Data Simkopdes per kecamatan
│   ├── Jumlah_Persentase_Penduduk_Miskin_2025.xlsx     # Data kemiskinan BPS 2025
│   └── data_kopdes_kemiskinan_merged_v2.xlsx           # Data gabungan siap analisis
├── script/
│   ├── 01_merge_data.py                                # Script merge data (Python)
│   └── 02_analisis.R                                   # Script analisis & visualisasi (R)
├── output/
│   └── kopdes_kemiskinan.png                           # Visualisasi hasil analisis
└── README.md
```

---

## Sumber Data

| Data | Sumber | Periode |
|------|--------|---------|
| Data Koperasi Desa (Simkopdes) | [simkopdes.go.id](https://simkopdes.go.id) | 2 Juni 2026 |
| Kemiskinan Kabupaten/Kota | Badan Pusat Statistik (BPS) | 2025 |
| Koordinat Kecamatan | GADM v4.1 | - |

---

## Deskripsi Data Gabungan (`data_kopdes_kemiskinan_merged_v2.xlsx`)

| Variabel | Deskripsi |
|----------|-----------|
| `provinsi` | Nama provinsi |
| `kabupaten_kota` | Nama kabupaten/kota |
| `jumlah_kopdes` | Total kopdes terdaftar per kabupaten |
| `kopdes_memiliki_nib` | Kopdes yang memiliki NIB |
| `kopdes_memiliki_npwp` | Kopdes yang memiliki NPWP |
| `kopdes_telah_rat` | Kopdes yang telah melaksanakan RAT 2025 |
| `simpanan_pokok` | Total simpanan pokok anggota (Rp) |
| `simpanan_wajib` | Total simpanan wajib anggota (Rp) |
| `kopdes_bertransaksi` | Jumlah kopdes yang mencatatkan transaksi |
| `total_volume_transaksi` | Total volume transaksi 2026 |
| `jumlah_kecamatan` | Jumlah kecamatan dalam kabupaten |
| `pct_kopdes_bertransaksi` | Persentase kopdes yang bertransaksi (%) |
| `rata_kopdes_per_kecamatan` | Rata-rata jumlah kopdes per kecamatan |
| `jumlah_penduduk_miskin` | Jumlah penduduk miskin |
| `pct_penduduk_miskin` | Persentase penduduk miskin (%) |
| `pct_balita_stunting` | Persentase balita stunting (%) |

**Total observasi: 484 kabupaten/kota**

---

## Temuan Utama

1. Tingkat kemiskinan berkorelasi negatif dan signifikan dengan aktivitas transaksi kopdes (β = -0,045, p < 0,001) setelah dikontrol faktor kelembagaan.
2. Kabupaten di kuartil terkaya mencatat rata-rata aktivitas transaksi **enam kali lebih tinggi** dibanding kuartil termiskin (1,51% vs 0,25%).
3. Dari 34 kabupaten dengan kemiskinan >25%, 33 di antaranya (97%) tidak mencatatkan transaksi.
4. Kepadatan kopdes per kecamatan yang tinggi justru menekan aktivitas transaksi — indikasi dilusi pasar.
5. Variabel paling menentukan aktivitas kopdes adalah simpanan pokok dan simpanan wajib anggota, bukan kepatuhan administratif (RAT).

---

## Cara Reproduksi

### Prasyarat
- Python 3.x dengan library: `pandas`, `openpyxl`
- R 4.x dengan package: `readxl`, `ggplot2`, `dplyr`

### Langkah

```bash
# 1. Merge data (Python)
python script/01_merge_data.py

# 2. Analisis dan visualisasi (R)
Rscript script/02_analisis.R
```

---

## Lisensi
Data BPS dan Simkopdes adalah data publik pemerintah Indonesia.
Script analisis dalam repositori ini bebas digunakan dengan menyebutkan sumber.
