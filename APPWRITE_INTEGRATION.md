uy # Appwrite Server Integration - Survey Feature

## Overview

Survey feature fully integrated dengan Appwrite server untuk menyimpan dan mengambil data.

## Data Flow

### 1. Loading Questions (GET from Appwrite)

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│ Survey Page │ ──GET──>│ AppwriteService  │ ──API──>│   Appwrite  │
│             │         │ getSurveyQuest() │         │   Database  │
└─────────────┘         └──────────────────┘         └─────────────┘
                                  │
                                  v
                        ┌─────────────────────┐
                        │ Convert to          │
                        │ SurveyQuestion      │
                        │ objects with type,  │
                        │ options, scores     │
                        └─────────────────────┘
```

**Flow Detail:**

1. User membuka `SurveyPage`
2. `_loadQuestions()` dipanggil di `initState()`
3. Call `AppwriteService.getSurveyQuestions()`
4. AppwriteService connect ke Appwrite database
5. Fetch semua documents dari collection `SURVEY_COLLECTION_ID`
6. Convert documents ke `Map<String, dynamic>`
7. Parse ke `SurveyQuestion` objects dengan `fromMap()`
8. Display di UI dengan berbagai widget sesuai tipe

### 2. Submitting Responses (POST to Appwrite)

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│ Survey Page │ ──POST─>│ AppwriteService  │ ──API──>│   Appwrite  │
│ _submitSurv()│        │ submitSurveyResp()│        │   Database  │
└─────────────┘         └──────────────────┘         └─────────────┘
                                  │
                                  │
                        ┌─────────v──────────┐
                        │ Create document:   │
                        │ - questionId       │
                        │ - response/responses│
                        │ - score            │
                        │ - userId           │
                        │ - submissionId     │
                        │ - timestamp        │
                        └────────────────────┘
```

**Flow Detail:**

1. User menjawab semua pertanyaan
2. User klik "Kirim Survei"
3. Validasi semua pertanyaan sudah dijawab
4. Generate `submissionId` untuk grouping
5. Loop setiap pertanyaan:
   - Extract jawaban berdasarkan tipe (single/multiple/text)
   - Hitung score jika pertanyaan punya scoring
   - Call `AppwriteService.submitSurveyResponse()` dengan data lengkap
6. AppwriteService create document di `SURVEY_RESPONSES_COLLECTION_ID`
7. Show success message dengan total score

## Appwrite Collections

### Collection 1: Survey Questions (`SURVEY_COLLECTION_ID`)

**Purpose:** Menyimpan master data pertanyaan survey

**Schema:**

```json
{
  "$id": "auto-generated",
  "question": "string - Teks pertanyaan",
  "type": "string - singleChoice|multipleChoice|text",
  "options": "array of strings - Daftar pilihan jawaban",
  "hasScore": "boolean - Apakah pertanyaan ini punya score",
  "optionScores": "string (JSON) - Map option -> score value sebagai JSON string"
}
```

**Note:** Appwrite tidak support tipe `object/map` secara native, jadi `optionScores` disimpan sebagai **JSON string**.

**Cara Membuat di Appwrite Console:**

- `question`: Type = String, Size = 500, Required
- `type`: Type = String, Size = 50, Required
- `options`: Type = String, Size = 100, **Array = Yes**, Required = No
- `hasScore`: Type = Boolean, Required = No
- `optionScores`: Type = String, Size = 2000, Required = No (akan berisi JSON string)

**Example Document:**

```json
{
  "$id": "question_001",
  "question": "Seberapa sering Anda mengajarkan gizi?",
  "type": "singleChoice",
  "options": ["Setiap hari", "Seminggu sekali", "Sebulan sekali", "Jarang"],
  "hasScore": true,
  "optionScores": "{\"Setiap hari\":10,\"Seminggu sekali\":7,\"Sebulan sekali\":4,\"Jarang\":1}"
}
```

**Note:** `optionScores` adalah JSON string, bukan object. Di Dart akan di-parse otomatis dengan `jsonDecode()`.

### Collection 2: Survey Responses (`SURVEY_RESPONSES_COLLECTION_ID`)

**Purpose:** Menyimpan jawaban user untuk setiap pertanyaan

**Schema:**

```json
{
  "$id": "auto-generated",
  "questionId": "string - Reference ke question",
  "userId": "string - User yang menjawab",
  "question": "string - Copy teks pertanyaan",
  "response": "string - Jawaban (single/joined multiple/text)",
  "responses": "array - Jawaban multiple choice (optional)",
  "score": "number - Score yang didapat (optional)",
  "submissionId": "string - Group ID untuk satu submit",
  "timestamp": "string - ISO 8601 datetime"
}
```

**Example Document (Single Choice):**

```json
{
  "$id": "response_001",
  "questionId": "question_001",
  "userId": "user_123",
  "question": "Seberapa sering Anda mengajarkan gizi?",
  "response": "Setiap hari",
  "score": 10,
  "submissionId": "1700000000000",
  "timestamp": "2025-11-18T10:30:00.000Z"
}
```

**Example Document (Multiple Choice):**

```json
{
  "$id": "response_002",
  "questionId": "question_002",
  "userId": "user_123",
  "question": "Metode pembelajaran yang digunakan?",
  "response": "Ceramah interaktif, Diskusi kelompok, Video pembelajaran",
  "responses": ["Ceramah interaktif", "Diskusi kelompok", "Video pembelajaran"],
  "score": 8,
  "submissionId": "1700000000000",
  "timestamp": "2025-11-18T10:30:05.000Z"
}
```

**Example Document (Text Input):**

```json
{
  "$id": "response_003",
  "questionId": "question_003",
  "userId": "user_123",
  "question": "Apa tantangan terbesar dalam mengajar gizi?",
  "response": "Kurangnya fasilitas praktikum dan keterbatasan waktu pembelajaran",
  "submissionId": "1700000000000",
  "timestamp": "2025-11-18T10:30:10.000Z"
}
```

## API Methods

### `AppwriteService.getSurveyQuestions()`

**Purpose:** Mengambil semua pertanyaan survey dari Appwrite

**Returns:** `Future<List<Map<String, dynamic>>>`

**Process:**

1. Create Appwrite client
2. Call `databases.listDocuments()` pada `SURVEY_COLLECTION_ID`
3. Convert each document ke Map dengan proper type checking
4. Extract dan validate fields: question, type, options, optionScores, hasScore
5. Return list of maps

**Usage:**

```dart
final questions = await AppwriteService.getSurveyQuestions();
```

### `AppwriteService.submitSurveyResponse()`

**Purpose:** Menyimpan jawaban user ke Appwrite

**Parameters:**

- `questionId`: String - ID pertanyaan
- `response`: String - Jawaban utama (single/joined/text)
- `userId`: String - ID user yang menjawab
- `question`: String - Teks pertanyaan (untuk history)
- `submissionId`: String - Group ID untuk batch submit
- `responses`: List<String>? - Optional, untuk multiple choice
- `score`: int? - Optional, score yang didapat

**Returns:** `Future<void>`

**Process:**

1. Build data map dengan required fields
2. Add optional `responses` jika multiple choice
3. Add optional `score` jika pertanyaan punya scoring
4. Call `databases.createDocument()` pada `SURVEY_RESPONSES_COLLECTION_ID`
5. Log hasil submit

**Usage:**

```dart
await AppwriteService.submitSurveyResponse(
  'question_001',
  'Setiap hari',
  'user_123',
  'Seberapa sering Anda mengajarkan gizi?',
  '1700000000000',
  score: 10,
);
```

## Key Features

### ✅ Fully Server-Based

- **TIDAK** ada hardcoded questions di frontend
- **SEMUA** questions dimuat dari Appwrite database
- **SEMUA** responses disimpan ke Appwrite database

### ✅ Type Safety

- Proper type checking saat parse dari Appwrite
- Handle null values dengan graceful fallback
- Validate data structure sebelum simpan

### ✅ Error Handling

- Try-catch di semua API calls
- Log errors untuk debugging
- Show user-friendly error messages
- Rethrow untuk upstream handling

### ✅ Logging

- Debug logs untuk development
- Info logs untuk production
- Track success/failure operations
- Monitor data flow

## Testing

### Create Test Questions

```dart
// Debug mode only
await AppwriteService.createTestSurveyQuestions();
```

Creates 7 test questions:

1. Single choice + score (frekuensi mengajar)
2. Multiple choice + score (metode pembelajaran)
3. Single choice + score (tingkat pemahaman)
4. Text input no score (tantangan)
5. Multiple choice no score (topik diminati)
6. Single choice + score (partisipasi)
7. Text input no score (saran)

### Verify Data Flow

**Check Questions Loaded:**

```dart
// In _loadQuestions()
print('📥 Loaded ${questionsData.length} questions from Appwrite server');
```

**Check Response Saved:**

```dart
// In _submitSurvey()
print('📤 Saved response to Appwrite: ${question.question}... (score: $score)');
```

## Configuration

### Setup Appwrite Collections (Step-by-Step)

#### Step 1: Create Survey Questions Collection

1. Login ke Appwrite Console
2. Navigate ke **Databases** → Select your database
3. Click **"Add Collection"**

   - Name: `Survey Questions`
   - Collection ID: (auto-generate atau custom)
   - Click Create

4. **Add Attributes** (Click "Add Attribute" for each):

   **Attribute: question**

   - Type: `String`
   - Size: `500`
   - Required: `✓ Yes`
   - Array: `☐ No`
   - Default: (empty)

   **Attribute: type**

   - Type: `String`
   - Size: `50`
   - Required: `✓ Yes`
   - Array: `☐ No`
   - Default: `singleChoice`

   **Attribute: options**

   - Type: `String`
   - Size: `100` (per item)
   - Required: `☐ No`
   - Array: `✓ Yes` ← **PENTING: Centang ini!**
   - Default: (empty)

   **Attribute: hasScore**

   - Type: `Boolean`
   - Required: `☐ No`
   - Default: `false`

   **Attribute: optionScores**

   - Type: `String` ← **BUKAN object, gunakan String!**
   - Size: `2000`
   - Required: `☐ No`
   - Array: `☐ No`
   - Default: (empty)
   - **Note**: Akan menyimpan JSON string seperti `{"Option A": 10, "Option B": 5}`

5. **Set Permissions**:
   - Read: `Any` atau `role:member`
   - Create: `role:admin` (atau biarkan kosong untuk testing)
   - Update: `role:admin`
   - Delete: `role:admin`

#### Step 2: Create Survey Responses Collection

1. Click **"Add Collection"** lagi

   - Name: `Survey Responses`
   - Collection ID: (auto-generate)
   - Click Create

2. **Add Attributes**:

   **Attribute: questionId**

   - Type: `String`, Size: `100`, Required: `✓ Yes`

   **Attribute: userId**

   - Type: `String`, Size: `100`, Required: `✓ Yes`

   **Attribute: question**

   - Type: `String`, Size: `500`, Required: `✓ Yes`

   **Attribute: response**

   - Type: `String`, Size: `1000`, Required: `✓ Yes`

   **Attribute: responses**

   - Type: `String`, Size: `200`, Array: `✓ Yes`, Required: `☐ No`

   **Attribute: score**

   - Type: `Integer`, Required: `☐ No`

   **Attribute: submissionId**

   - Type: `String`, Size: `100`, Required: `✓ Yes`

   **Attribute: timestamp**

   - Type: `DateTime`, Required: `✓ Yes`

3. **Set Permissions**:
   - Read: `User` (users can read their own)
   - Create: `Any` atau `role:member`
   - Update: (kosongkan)
   - Delete: (kosongkan)

### Appwrite Constants

Pastikan sudah set di `AppwriteConstants`:

```dart
static const APPWRITE_PUBLIC_ENDPOINT = 'https://cloud.appwrite.io/v1';
static const APPWRITE_PROJECT_ID = 'your-project-id';
static const DATABASE_ID = 'your-database-id';
static const SURVEY_COLLECTION_ID = 'survey-questions-collection-id';
static const SURVEY_RESPONSES_COLLECTION_ID = 'survey-responses-collection-id';
```

### Required Permissions

**Survey Questions Collection:**

- Read: Any authenticated user
- Create: Admin only (untuk test questions)

**Survey Responses Collection:**

- Read: User can read own responses
- Create: Any authenticated user
- Update/Delete: Not needed

## Monitoring & Analytics

### What Gets Saved

- Complete question text
- User's selected answers
- Calculated scores
- Timestamp of submission
- User identification
- Grouping by submission

### Query Capabilities

- Get all questions
- Get user's response history
- Get responses by submission
- Calculate aggregate scores
- Track response patterns

## Future Enhancements

- [ ] Cache questions locally untuk offline support
- [ ] Batch submit dengan retry logic
- [ ] Real-time sync dengan Appwrite Realtime
- [ ] Analytics dashboard untuk admin
- [ ] Export responses to Excel/CSV
- [ ] Question versioning
- [ ] Conditional questions flow
- [ ] Response validation rules dari server
