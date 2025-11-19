# 🚀 Quick Setup Guide - Appwrite Collections untuk Survey

## ⚠️ PENTING: Appwrite Tidak Support Tipe "Object"

Appwrite **tidak memiliki** tipe data `object` atau `map`. Untuk menyimpan data kompleks seperti `optionScores`, gunakan **String** dan simpan sebagai **JSON string**.

## 📋 Checklist Setup

### Collection 1: Survey Questions

```
☐ 1. Create Collection "Survey Questions"
☐ 2. Add attribute: question (String, 500)
☐ 3. Add attribute: type (String, 50)
☐ 4. Add attribute: options (String, 100, ARRAY ✓)
☐ 5. Add attribute: hasScore (Boolean)
☐ 6. Add attribute: optionScores (String, 2000)
☐ 7. Set permissions (Read: Any, Create: Admin)
```

### Collection 2: Survey Responses

```
☐ 1. Create Collection "Survey Responses"
☐ 2. Add attribute: questionId (String, 100)
☐ 3. Add attribute: userId (String, 100)
☐ 4. Add attribute: question (String, 500)
☐ 5. Add attribute: response (String, 1000)
☐ 6. Add attribute: responses (String, 200, ARRAY ✓)
☐ 7. Add attribute: score (Integer)
☐ 8. Add attribute: submissionId (String, 100)
☐ 9. Add attribute: timestamp (DateTime)
☐ 10. Set permissions (Read: User, Create: Any)
```

## 📝 Detailed Steps

### Step 1: Login & Navigate

1. Go to https://cloud.appwrite.io/console
2. Login to your account
3. Select your project
4. Click **Databases** in left sidebar
5. Select your database (or create new)

### Step 2: Create Survey Questions Collection

#### 2.1 Create Collection

1. Click **"Add Collection"** button
2. Enter name: `Survey Questions`
3. Collection ID: (leave auto-generate or set: `survey_questions`)
4. Click **"Create"**

#### 2.2 Add Attributes

**📌 Attribute 1: question**

```
Click "Add Attribute" → "String"
Key: question
Size: 500
Required: ✓ (checked)
Array: ☐ (unchecked)
→ Click "Create"
```

**📌 Attribute 2: type**

```
Click "Add Attribute" → "String"
Key: type
Size: 50
Required: ✓
Default Value: singleChoice
Array: ☐
→ Click "Create"
```

**📌 Attribute 3: options** ⚠️ IMPORTANT

```
Click "Add Attribute" → "String"
Key: options
Size: 100 (per item in array)
Required: ☐ (unchecked - some questions like 'text' have no options)
Array: ✓ (CHECKED!) ← This makes it an array of strings
→ Click "Create"
```

**📌 Attribute 4: hasScore**

```
Click "Add Attribute" → "Boolean"
Key: hasScore
Required: ☐
Default Value: false
→ Click "Create"
```

**📌 Attribute 5: optionScores** ⚠️ CRITICAL

```
Click "Add Attribute" → "String" ← NOT object! Use String!
Key: optionScores
Size: 2000 (untuk JSON string yang panjang)
Required: ☐
Array: ☐
→ Click "Create"

NOTE: Akan menyimpan JSON string seperti:
{"Setiap hari":10,"Seminggu sekali":7}
```

#### 2.3 Set Permissions

1. Go to **"Settings"** tab in collection
2. Click **"Permissions"**
3. Add permissions:

```
Read Access:
- Click "Add Role"
- Select "Any" or "Users" (role:member)
- Click "Add"

Create Access:
- Click "Add Role"
- Select "Admin" or leave empty for testing
- Click "Add"

Update & Delete:
- Add "Admin" role for both
```

### Step 3: Create Survey Responses Collection

#### 3.1 Create Collection

```
Click "Add Collection"
Name: Survey Responses
Collection ID: (auto or: survey_responses)
Click "Create"
```

#### 3.2 Add Attributes (Quick List)

| Attribute    | Type     | Size | Required | Array | Note                  |
| ------------ | -------- | ---- | -------- | ----- | --------------------- |
| questionId   | String   | 100  | ✓        | ☐     | Reference to question |
| userId       | String   | 100  | ✓        | ☐     | Who answered          |
| question     | String   | 500  | ✓        | ☐     | Question text copy    |
| response     | String   | 1000 | ✓        | ☐     | Main answer           |
| responses    | String   | 200  | ☐        | ✓     | For multiple choice   |
| score        | Integer  | -    | ☐        | ☐     | Points earned         |
| submissionId | String   | 100  | ✓        | ☐     | Group ID              |
| timestamp    | DateTime | -    | ✓        | ☐     | When submitted        |

#### 3.3 Set Permissions

```
Read: Users (users can read own responses)
Create: Any or Users
Update: (leave empty)
Delete: (leave empty)
```

### Step 4: Update Constants in Code

Edit `/lib/constant.dart`:

```dart
class AppwriteConstants {
  static const APPWRITE_PUBLIC_ENDPOINT = 'https://cloud.appwrite.io/v1';
  static const APPWRITE_PROJECT_ID = 'your-project-id-here';
  static const DATABASE_ID = 'your-database-id-here';

  // Collection IDs from Appwrite console
  static const SURVEY_COLLECTION_ID = 'copy-from-appwrite-console';
  static const SURVEY_RESPONSES_COLLECTION_ID = 'copy-from-appwrite-console';
}
```

**Where to find IDs:**

- Project ID: Dashboard → Settings
- Database ID: Databases → Select database → Settings
- Collection IDs: Each collection → Settings → Collection ID

### Step 5: Test with Sample Data

Run the app and click the **➕** button in Survey page to create test questions.

Or manually create a document:

1. Go to Survey Questions collection
2. Click **"Add Document"**
3. Fill in:

```json
{
  "question": "Test question?",
  "type": "singleChoice",
  "options": ["Option A", "Option B"],
  "hasScore": true,
  "optionScores": "{\"Option A\":10,\"Option B\":5}"
}
```

## 🔧 Troubleshooting

### ❌ "Can't find object type"

**Solution:** Use `String` type instead. Appwrite doesn't have object/map type.

### ❌ "optionScores not working"

**Check:**

1. Is it a String attribute? ✓
2. Is the value a valid JSON string? `{"key":value}` ✓
3. Is jsonEncode() used when creating? ✓
4. Is jsonDecode() used when reading? ✓

### ❌ "options array empty"

**Check:**

1. Is Array checkbox checked? ✓
2. Is it String type (not just "String")? ✓
3. Are you passing a List when creating? ✓

### ❌ "Permission denied"

**Check:**

1. Collection permissions set? ✓
2. User is authenticated? ✓
3. Read permission includes "Any" or "Users"? ✓

### ❌ "Attribute size too small"

**Solution:**

- question: increase to 500-1000
- optionScores: increase to 2000-5000
- response: increase to 1000-2000

## 🎯 Verification Checklist

After setup, verify:

```
☐ Survey Questions collection exists
☐ All 5 attributes created correctly
☐ "options" is Array type
☐ "optionScores" is String type (NOT object)
☐ Permissions set for reading
☐ Survey Responses collection exists
☐ All 8 attributes created
☐ "responses" is Array type
☐ Constants updated in code
☐ Test data created successfully
☐ App can read questions
☐ App can save responses
```

## 📱 Testing Flow

1. **Test Load Questions:**

   ```
   Open app → Survey page
   Should show: "📥 Loaded X questions from Appwrite server"
   ```

2. **Test Create Questions:**

   ```
   Click ➕ button in app bar
   Should create 7 test questions
   Refresh → should see all questions
   ```

3. **Test Submit Response:**
   ```
   Answer all questions
   Click "Kirim Survei"
   Should show: "Survei berhasil disimpan"
   Check Appwrite console → Survey Responses → should have new documents
   ```

## 💡 Tips

1. **Use JSON Viewer** untuk check optionScores string di console
2. **Start simple** - create 1 question manually first
3. **Check browser console** untuk debug errors
4. **Enable logging** di Appwrite settings untuk troubleshooting
5. **Backup data** sebelum make changes ke schema

## 📚 Reference

- Appwrite Docs: https://appwrite.io/docs
- JSON Validator: https://jsonlint.com/
- This project docs: See `APPWRITE_INTEGRATION.md`

## 🆘 Need Help?

Common issues dan solutions ada di `APPWRITE_INTEGRATION.md` bagian Troubleshooting.
