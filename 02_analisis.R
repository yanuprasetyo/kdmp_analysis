# ============================================================
# 02_analisis.R
# Analisis regresi dan visualisasi:
# Hubungan kemiskinan dengan aktivitas transaksi Kopdes
#
# Penulis: Yanu Endar Prasetyo, Nimas Maninggar, Shabilla Rossinda
# Data: Simkopdes 2 Juni 2026 + BPS 2025
# ============================================================

library(readxl)
library(ggplot2)
library(dplyr)

# ── 1. Load data ──────────────────────────────────────────────
df <- read_excel("data/data_kopdes_kemiskinan_merged_v2.xlsx")

cat("Total observasi :", nrow(df), "\n")
cat("Kabupaten unik  :", n_distinct(df$kabupaten_kota), "\n")

# ── 2. Statistik deskriptif ───────────────────────────────────
cat("\n── Statistik Deskriptif ──\n")
summary(df[, c("pct_penduduk_miskin", "pct_kopdes_bertransaksi",
               "jumlah_kopdes", "rata_kopdes_per_kecamatan",
               "simpanan_pokok", "simpanan_wajib")])

# ── 3. Regresi 1: Sederhana ───────────────────────────────────
cat("\n── Model 1: Regresi Sederhana ──\n")
model1 <- lm(pct_kopdes_bertransaksi ~ pct_penduduk_miskin, data = df)
summary(model1)

# ── 4. Regresi 2: Multivariat ─────────────────────────────────
cat("\n── Model 2: Regresi Multivariat ──\n")
model2 <- lm(pct_kopdes_bertransaksi ~ pct_penduduk_miskin +
               jumlah_kopdes +
               rata_kopdes_per_kecamatan +
               kopdes_telah_rat +
               simpanan_pokok +
               simpanan_wajib,
             data = df)
summary(model2)

# ── 5. Analisis kuartil ───────────────────────────────────────
df <- df %>%
  mutate(
    kuartil_miskin = ntile(pct_penduduk_miskin, 4),
    kuartil_label = case_when(
      kuartil_miskin == 1 ~ "Q1 Terkaya",
      kuartil_miskin == 2 ~ "Q2",
      kuartil_miskin == 3 ~ "Q3",
      kuartil_miskin == 4 ~ "Q4 Termiskin"
    ),
    kuartil_label = factor(kuartil_label,
                           levels = c("Q1 Terkaya", "Q2", "Q3", "Q4 Termiskin"))
  )

cat("\n── Rata-rata % Kopdes Bertransaksi per Kuartil Kemiskinan ──\n")
df %>%
  group_by(kuartil_label) %>%
  summarise(
    n_kab             = n(),
    rata_pct_miskin   = round(mean(pct_penduduk_miskin), 2),
    rata_transaksi    = round(mean(pct_kopdes_bertransaksi), 2),
    pct_nol_transaksi = round(mean(pct_kopdes_bertransaksi == 0) * 100, 1)
  ) %>%
  print()

# ── 6. Kabupaten kemiskinan ekstrem ───────────────────────────
cat("\n── Kabupaten dengan kemiskinan > 25% ──\n")
miskin_tinggi <- df %>% filter(pct_penduduk_miskin > 25)
cat("Jumlah kabupaten         :", nrow(miskin_tinggi), "\n")
cat("Tidak ada transaksi sama sekali:",
    sum(miskin_tinggi$pct_kopdes_bertransaksi == 0), "kabupaten (",
    round(mean(miskin_tinggi$pct_kopdes_bertransaksi == 0) * 100), "%)\n")

# ── 7. Visualisasi ────────────────────────────────────────────
p1 <- ggplot(df, aes(x = pct_penduduk_miskin, y = pct_kopdes_bertransaksi)) +
  geom_point(aes(color = kuartil_label), alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", color = "black", se = TRUE, linewidth = 0.8) +
  scale_color_manual(values = c("#2ecc71", "#f39c12", "#e67e22", "#e74c3c")) +
  labs(
    title    = "Kemiskinan vs Aktivitas Transaksi Koperasi Desa",
    subtitle = "484 kabupaten/kota, data Simkopdes & BPS 2025\u20132026",
    x        = "Persentase Penduduk Miskin (%)",
    y        = "Persentase Kopdes Bertransaksi (%)",
    color    = "Kuartil Kemiskinan",
    caption  = "Sumber: Simkopdes, 2 Juni 2026; BPS, 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

print(p1)

ggsave("output/kopdes_kemiskinan.png",
       plot   = p1,
       width  = 10,
       height = 6,
       dpi    = 300,
       bg     = "white")

cat("\nVisualisasi disimpan: output/kopdes_kemiskinan.png\n")
