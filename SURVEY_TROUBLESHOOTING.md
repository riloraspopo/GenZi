# Survey Troubleshooting Guide

## Masalah: Semua Pertanyaan Muncul Sebagai Single Choice

### Penyebab Umum

1. **Field `type` tidak diset dengan benar di Appwrite**
2. **Field `type` kosong/null di database**
3. **Typo di nilai `type` field**

### Solusi

#### 1. Periksa Data di Appwrite Console

Buka Appwrite Console → Databases → Survey Questions collection → Documents

Setiap document harus memiliki field `type` dengan nilai:

- `singleChoice` - untuk pilihan ganda (1 jawaban)
- `multipleChoice` - untuk pilihan ganda (banyak jawaban)
- `text` - untuk isian teks

**Contoh yang BENAR:**

```json
{
  "question": "Pertanyaan test?",
  "type": "multipleChoice",  ← Harus ada dan benar!
  "options": ["A", "B", "C"],
  "hasScore": true
}
```

**Contoh yang SALAH:**

```json
{
  "question": "Pertanyaan test?",
  "type": "",  ← KOSONG!
  "options": ["A", "B", "C"]
}
```

#### 2. Update Document yang Salah

Untuk setiap pertanyaan yang salah:

1. Klik document di Appwrite Console
2. Edit field `type`
3. Set value yang benar:
   - `singleChoice` (pilih satu)
   - `multipleChoice` (pilih banyak)
   - `text` (isian)
4. Save

#### 3. Buat Ulang Test Questions

Hapus semua pertanyaan test lama dan buat ulang:

1. Di Appwrite Console, hapus semua documents di Survey Questions collection
2. Di aplikasi, klik tombol ➕ di Survey page
3. Ini akan membuat 7 pertanyaan test dengan tipe yang benar

#### 4. Verifikasi dengan Debug Mode

Jalankan aplikasi dalam debug mode dan lihat console output:

```
Parsing type: "multiplechoice"  ← Harus muncul tipe yang benar
Building input for type: QuestionType.multipleChoice  ← Pastikan tipe benar
```

### Cara Membuat Pertanyaan Baru Manual

Jika membuat pertanyaan baru manual di Appwrite Console:

**Single Choice:**

```json
{
  "question": "Pilih satu jawaban:",
  "type": "singleChoice",
  "options": ["Pilihan A", "Pilihan B", "Pilihan C"],
  "hasScore": true,
  "optionScores": "{\"Pilihan A\":10,\"Pilihan B\":5,\"Pilihan C\":0}"
}
```

**Multiple Choice:**

```json
{
  "question": "Pilih semua yang sesuai:",
  "type": "multipleChoice",
  "options": ["Opsi 1", "Opsi 2", "Opsi 3"],
  "hasScore": true,
  "optionScores": "{\"Opsi 1\":3,\"Opsi 2\":4,\"Opsi 3\":5}"
}
```

**Text Input:**

```json
{
  "question": "Tulis jawaban Anda:",
  "type": "text",
  "options": [],
  "hasScore": false
}
```

### Checklist Debugging

Gunakan checklist ini untuk troubleshoot:

```
☐ 1. Field 'type' ada di setiap document?
☐ 2. Nilai 'type' salah satu dari: singleChoice, multipleChoice, text?
☐ 3. Tidak ada typo? (eg: "multiplechoice" BUKAN "multiple choice")
☐ 4. Case sensitive? (gunakan camelCase)
☐ 5. Field 'options' berisi array untuk single/multiple choice?
☐ 6. Field 'options' kosong untuk text questions?
☐ 7. Console log menampilkan tipe yang benar?
```

### Cara Cek di Console

Buka browser console (F12) saat load survey page, cari output:

```
✅ BENAR:
Converting map to SurveyQuestion: {...}
Parsing type: "multiplechoice"
Processed fields:
type: QuestionType.multipleChoice (raw: multipleChoice)
Building input for type: QuestionType.multipleChoice, options count: 5

❌ SALAH:
Parsing type: ""
Warning: type is null, defaulting to singleChoice
type: QuestionType.singleChoice (raw: null)
```

### Nilai Type yang Valid

Aplikasi sekarang mendukung berbagai format (case-insensitive):

**Single Choice:**

- `singleChoice` ✓ (recommended)
- `single_choice` ✓
- `single choice` ✓
- `singlechoice` ✓

**Multiple Choice:**

- `multipleChoice` ✓ (recommended)
- `multiple_choice` ✓
- `multiple choice` ✓
- `multiplechoice` ✓

**Text:**

- `text` ✓ (recommended)
- `textinput` ✓
- `text_input` ✓

**Namun sebaiknya gunakan format camelCase yang direkomendasikan!**

### Test Flow

1. **Delete all test questions** di Appwrite
2. **Klik ➕ button** di Survey page untuk create fresh test data
3. **Reload page**
4. **Verify** bahwa ada:
   - Pertanyaan dengan radio buttons (single choice)
   - Pertanyaan dengan checkboxes (multiple choice)
   - Pertanyaan dengan text field (text input)

### Screenshot Expected Result

Survey page seharusnya menampilkan:

```
┌─────────────────────────────────────────┐
│ 1. Single choice question?              │
│    Pilih satu jawaban                   │
│    ○ Option A           +10             │
│    ○ Option B           +5              │
│    ○ Option C           +0              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 2. Multiple choice question?            │
│    Pilih satu atau lebih jawaban        │
│    ☐ Choice 1           +3              │
│    ☐ Choice 2           +4              │
│    ☐ Choice 3           +5              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 3. Text question?                       │
│    Isian teks                           │
│    ┌───────────────────────────────┐   │
│    │ Ketik jawaban Anda di sini... │   │
│    └───────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Still Not Working?

Jika masih tidak berfungsi setelah semua langkah di atas:

1. **Clear app cache** dan reload
2. **Check Appwrite permissions** - pastikan read permission diset
3. **Verify network requests** di browser Network tab
4. **Check console errors** untuk error messages
5. **Contact developer** dengan screenshot console log

## Quick Fix Commands

### Buat Ulang Test Data (Recommended)

```dart
// Di Survey Page, klik tombol ➕ (Add Chart icon)
// Atau jalankan:
await AppwriteService.createTestSurveyQuestions();
```

### Verify Field Type di Appwrite

1. Appwrite Console
2. Databases → Your Database → Survey Questions
3. Klik setiap document
4. Check field `type` → harus ada nilai
5. Edit jika salah/kosong

## Prevention

Untuk mencegah masalah di masa depan:

1. **Selalu set field `type`** saat membuat pertanyaan baru
2. **Gunakan format camelCase**: `singleChoice`, `multipleChoice`, `text`
3. **Test setelah create** - buka survey page dan verify tampilan
4. **Gunakan createTestSurveyQuestions()** sebagai template
5. **Backup data** sebelum make bulk changes
