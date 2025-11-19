# Fitur Survey dengan Berbagai Jenis Pertanyaan dan Scoring Realtime

## Overview

Halaman survey telah dirombak untuk mendukung berbagai jenis pertanyaan dengan sistem scoring realtime.

## Jenis Pertanyaan yang Didukung

### 1. Single Choice (Pilihan Ganda - Satu Jawaban)

- User hanya bisa memilih satu jawaban
- Cocok untuk pertanyaan dengan jawaban tunggal
- Dapat memiliki score atau tidak

**Contoh:**

```
Seberapa sering Anda mengajarkan materi gizi seimbang?
○ Setiap hari (10 poin)
○ Seminggu sekali (7 poin)
○ Sebulan sekali (4 poin)
○ Jarang (1 poin)
```

### 2. Multiple Choice (Pilihan Ganda - Banyak Jawaban)

- User bisa memilih lebih dari satu jawaban
- Cocok untuk pertanyaan dengan multiple answers
- Score akan dijumlahkan dari semua pilihan yang dipilih

**Contoh:**

```
Metode pembelajaran apa yang Anda gunakan?
☑ Ceramah interaktif (2 poin)
☑ Diskusi kelompok (3 poin)
☐ Game edukatif (4 poin)
☑ Video pembelajaran (3 poin)
☐ Praktik langsung (5 poin)
Total: 8 poin
```

### 3. Text Input (Isian Teks)

- User bisa mengetik jawaban bebas
- Cocok untuk pertanyaan terbuka
- Biasanya tidak memiliki score

**Contoh:**

```
Apa tantangan terbesar dalam mengajar gizi?
[Ketik jawaban Anda di sini...]
```

## Sistem Scoring

### Pertanyaan dengan Score

- Setiap option bisa memiliki score (positif atau negatif)
- Score ditampilkan di samping setiap option
- Score per pertanyaan ditampilkan di badge atas kanan card pertanyaan
- Total score ditampilkan realtime di card score bagian atas

### Pertanyaan tanpa Score

- Tidak semua pertanyaan harus memiliki score
- Pertanyaan tanpa score tidak akan menambah total score
- Cocok untuk pertanyaan feedback atau data gathering

## Tampilan Score Realtime

### Score Card

Ditampilkan di bagian atas halaman dengan informasi:

- **Skor Saat Ini**: Menampilkan total score yang sudah diperoleh
- **Maksimal Score**: Total score maksimal yang bisa diperoleh
- **Persentase**: Persentase score yang sudah diraih

```
┌─────────────────────────────────────┐
│ Skor Saat Ini                  45%  │
│ 18 / 40                             │
└─────────────────────────────────────┘
```

### Badge Score per Pertanyaan

Setiap pertanyaan yang memiliki score akan menampilkan badge di pojok kanan atas menunjukkan score yang didapat dari jawaban saat ini.

### Badge Score per Option

Setiap option yang memiliki score akan menampilkan badge kecil di samping text menunjukkan nilai score (+/- poin).

## Struktur Data

### Model SurveyQuestion

```dart
{
  "id": "unique-id",
  "question": "Pertanyaan survey?",
  "type": "singleChoice|multipleChoice|text",
  "options": ["Option 1", "Option 2", "Option 3"],
  "hasScore": true|false,
  "optionScores": {
    "Option 1": 10,
    "Option 2": 7,
    "Option 3": 3
  }
}
```

### QuestionType Enum

- `singleChoice`: Pilihan ganda satu jawaban
- `multipleChoice`: Pilihan ganda banyak jawaban
- `text`: Isian teks bebas

## Cara Membuat Pertanyaan Baru

### 1. Via Database Appwrite

Tambahkan document di collection survey dengan struktur:

```json
{
  "question": "Pertanyaan Anda?",
  "type": "singleChoice",
  "options": ["Jawaban A", "Jawaban B", "Jawaban C"],
  "hasScore": true,
  "optionScores": {
    "Jawaban A": 10,
    "Jawaban B": 5,
    "Jawaban C": 0
  }
}
```

### 2. Via Debug Button (Development Mode)

- Buka halaman survey
- Klik icon ➕ di app bar
- Akan membuat 7 pertanyaan test otomatis dengan berbagai jenis

## Contoh Pertanyaan Test

Sistem menyediakan 7 pertanyaan test yang mencakup semua jenis:

1. **Single Choice dengan Score**: Frekuensi pengajaran
2. **Multiple Choice dengan Score**: Metode pembelajaran
3. **Single Choice dengan Score**: Tingkat pemahaman siswa
4. **Text Input tanpa Score**: Tantangan mengajar
5. **Multiple Choice tanpa Score**: Topik yang diminati
6. **Single Choice dengan Score**: Partisipasi siswa
7. **Text Input tanpa Score**: Saran improvement

## Validasi

### Sebelum Submit

- Semua pertanyaan harus dijawab
- Single choice: minimal 1 pilihan
- Multiple choice: minimal 1 pilihan
- Text input: tidak boleh kosong

### Notifikasi

- Warning jika ada pertanyaan yang belum dijawab
- Success message dengan total score saat submit berhasil

## UI/UX Features

### Visual Feedback

- Pilihan yang dipilih highlight dengan warna primary
- Score badge berubah warna:
  - Hijau untuk score positif yang terpilih
  - Merah untuk score negatif yang terpilih
  - Abu-abu untuk yang belum terpilih

### Responsiveness

- Semua perubahan jawaban langsung update score realtime
- Smooth animation saat memilih/membatalkan pilihan
- Auto scroll untuk pertanyaan panjang

### Accessibility

- Clear labeling untuk setiap jenis pertanyaan
- Indicator tipe pertanyaan (pilih satu/banyak/isian)
- Score badge untuk transparansi nilai

## Technical Implementation

### State Management

- `setState()` untuk update realtime score
- TextEditingController untuk text input
- List tracking untuk multiple choice

### Score Calculation

```dart
// Single Choice
score = optionScores[selectedOption]

// Multiple Choice
score = selectedOptions.sum(option => optionScores[option])

// Text
score = 0 (no scoring)
```

### Disposal

- Proper cleanup untuk TextEditingController
- Memory leak prevention

## Best Practices

### Untuk Membuat Survey Efektif

1. **Gunakan Single Choice** untuk:

   - Rating scale (1-5, Sangat Baik - Kurang)
   - Yes/No questions
   - Pertanyaan dengan jawaban eksklusif

2. **Gunakan Multiple Choice** untuk:

   - "Pilih semua yang sesuai"
   - Pengumpulan preferensi multiple
   - Skills/competencies assessment

3. **Gunakan Text Input** untuk:
   - Feedback terbuka
   - Saran dan kritik
   - Informasi detail yang tidak bisa di-list

### Untuk Scoring

1. **Gunakan Score** untuk:

   - Assessment/evaluation
   - Quiz/test
   - Performance measurement

2. **Tanpa Score** untuk:
   - Feedback gathering
   - Opinion polling
   - Open-ended research

## Troubleshooting

### Score tidak muncul

- Pastikan `hasScore: true`
- Pastikan `optionScores` tidak null
- Check bahwa option key match dengan options array

### Text input tidak tersimpan

- Pastikan TextController ter-initialize
- Check disposal di dispose() method
- Verify textAnswer ter-update di onChanged

### Multiple choice tidak bisa dipilih banyak

- Pastikan type = "multipleChoice"
- Check selectedOptions adalah List bukan String
- Verify setState dipanggil saat add/remove

## Future Enhancements

Potential improvements:

- [ ] Conditional questions (show based on previous answer)
- [ ] Required vs optional questions
- [ ] File upload questions
- [ ] Date/time picker questions
- [ ] Matrix/grid questions
- [ ] Weighted scoring
- [ ] Score ranges with labels (0-20: Poor, 21-40: Fair, etc.)
- [ ] Export results to Excel/PDF
- [ ] Analytics dashboard for survey results
