# 🗑️ ACCOUNT DELETION SYSTEM - COMPLETE GUIDE

**Professional Account Deletion with Data Retention Compliance**

---

## 📋 OVERVIEW

This system implements a **professional, compliant account deletion process** that:

1. ✅ **Respects subscription periods** - Deletes 1 day before subscription ends
2. ✅ **Preserves financial records** - Keeps payment data for legal/tax compliance
3. ✅ **Allows cancellation** - Users can cancel deletion before scheduled date
4. ✅ **Automated processing** - Nightly Firebase Cloud Function handles deletions
5. ✅ **Comprehensive cleanup** - Removes user data and storage files
6. ✅ **Audit trail** - Logs all deletions for compliance

---

## 🏗️ ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER INITIATES DELETION                      │
│              POST /api/v1/users/account/delete                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND PROCESSING                            │
│  1. Verify password                                              │
│  2. Cancel Stripe subscription                                   │
│  3. Calculate deletion date (subscription_end - 1 day)           │
│  4. Mark account as "pending_deletion"                           │
│  5. Return scheduled deletion date                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              NIGHTLY FIREBASE CLOUD FUNCTION                     │
│              (Runs at 2:00 AM UTC Daily)                         │
│                                                                   │
│  1. Query users with status = "pending_deletion"                 │
│  2. Check if deletion_scheduled_for <= now                       │
│  3. For each account ready for deletion:                         │
│     ├─ DELETE: User profile & settings                           │
│     ├─ DELETE: Generated content history                         │
│     ├─ DELETE: Brand voice configurations                        │
│     ├─ DELETE: Firebase Storage files (images/videos)            │
│     ├─ DELETE: Firebase Authentication account                   │
│     ├─ PRESERVE: Payment records (marked as user_deleted)        │
│     ├─ PRESERVE: Billing history (marked as user_deleted)        │
│     └─ LOG: Deletion in audit_log collection                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📡 API ENDPOINTS

### 1. Request Account Deletion

**Endpoint:** `POST /api/v1/users/account/delete`

**Request:**
```json
{
  "password": "user_password",
  "reason": "No longer need the service"
}
```

**Response:**
```json
{
  "message": "Your account deletion has been scheduled. You can cancel anytime before 2025-12-31.",
  "deletion_scheduled_for": "2025-12-30T23:59:59Z",
  "days_until_deletion": 7,
  "cancellation_possible": true
}
```

**Business Logic:**
- If user has active subscription → Delete 1 day before subscription ends
- If no subscription → Delete in 7 days
- Cancels Stripe subscription immediately
- Marks account as `pending_deletion`

---

### 2. Cancel Scheduled Deletion

**Endpoint:** `POST /api/v1/users/account/delete/cancel`

**Request:**
```json
{
  "password": "user_password"
}
```

**Response:**
```json
{
  "message": "Account deletion has been cancelled successfully",
  "status": "active"
}
```

**Requirements:**
- Account must have `status = "pending_deletion"`
- Deletion date must not have passed
- Password confirmation required

---

## 🗄️ DATABASE SCHEMA UPDATES

### User Document (Firestore: `users/{userId}`)

**New Fields Added:**
```javascript
{
  // Existing fields...
  "account_status": "active" | "pending_deletion" | "deleted",
  "deletion_requested_at": Timestamp | null,
  "deletion_scheduled_for": Timestamp | null,
  "deletion_reason": string | null,
}
```

### Deletion Audit Log (Firestore: `deletion_audit_log/{batchId}`)

```javascript
{
  "batch_date": Timestamp,
  "processed_count": number,
  "deletions": [
    {
      "userId": string,
      "email": string,
      "deletedAt": Timestamp,
      "reason": string,
      "status": "success" | "failed",
      "error": string (if failed)
    }
  ],
  "created_at": Timestamp
}
```

### Payment Records (Firestore: `payments/{paymentId}`)

**Preserved with Marker:**
```javascript
{
  // Original payment data preserved...
  "user_deleted": true,
  "user_deleted_at": Timestamp
}
```

---

## 🔥 FIREBASE CLOUD FUNCTION

### Setup & Deployment

**1. Navigate to functions directory:**
```bash
cd backend/firebase_functions
```

**2. Install dependencies:**
```bash
npm install
```

**3. Login to Firebase:**
```bash
firebase login
```

**4. Deploy functions:**
```bash
firebase deploy --only functions
```

**5. Verify deployment:**
```bash
firebase functions:log
```

---

### Function: `processScheduledAccountDeletions`

**Trigger:** Scheduled (Cron)  
**Schedule:** `0 2 * * *` (2:00 AM UTC daily)  
**Timeout:** 540 seconds (9 minutes)  

**Process:**

1. **Query Pending Deletions**
   ```javascript
   const usersSnapshot = await db.collection('users')
     .where('account_status', '==', 'pending_deletion')
     .get();
   ```

2. **Check Deletion Date**
   ```javascript
   if (scheduledFor.toMillis() > now.toMillis()) {
     console.log('Skipping - not yet time');
     continue;
   }
   ```

3. **Delete User Data**
   - ✅ User profile (`users/{userId}`)
   - ✅ Generated content (`generations` where `user_id == userId`)
   - ✅ Brand voices (`brand_voices` where `user_id == userId`)
   - ✅ Favorites (`favorites` where `user_id == userId`)
   - ✅ Sessions (`sessions` where `user_id == userId`)
   - ✅ Storage files (`users/{userId}/*`)
   - ✅ Firebase Auth account

4. **Preserve Financial Data**
   - 💰 Payment records (marked as `user_deleted: true`)
   - 💰 Billing history (marked as `user_deleted: true`)
   - 💰 Stripe subscription logs
   - 💰 Transaction records

5. **Log Deletion**
   ```javascript
   await db.collection('deletion_audit_log').add({
     batch_date: now,
     deletions: [...]
   });
   ```

---

### Manual Deletion (Admin Only)

**Endpoint:** `manualAccountDeletion` (HTTP Callable)

**Usage:**
```javascript
const functions = getFunctions();
const deleteAccount = httpsCallable(functions, 'manualAccountDeletion');

const result = await deleteAccount({ 
  userId: 'user123' 
});
```

**Requirements:**
- Admin authentication token
- User must exist
- Bypasses scheduled deletion (immediate)

---

## 📊 DATA RETENTION POLICY

### ✅ WHAT GETS DELETED

| Data Type | Location | Deleted |
|-----------|----------|---------|
| User Profile | `users/{userId}` | ✅ Yes |
| Generated Content | `generations` collection | ✅ Yes |
| Brand Voice | `brand_voices` collection | ✅ Yes |
| Favorites | `favorites` collection | ✅ Yes |
| Sessions | `sessions` collection | ✅ Yes |
| Profile Images | Storage: `users/{userId}/profile/*` | ✅ Yes |
| Generated Images | Storage: `users/{userId}/images/*` | ✅ Yes |
| Videos | Storage: `users/{userId}/videos/*` | ✅ Yes |
| Firebase Auth | Authentication system | ✅ Yes |

### 💰 WHAT GETS PRESERVED

| Data Type | Location | Preserved | Reason |
|-----------|----------|-----------|--------|
| Payment Records | `payments` collection | ✅ Yes | Tax compliance (7 years) |
| Billing History | `billing_history` collection | ✅ Yes | Legal requirement |
| Stripe Subscriptions | Stripe dashboard | ✅ Yes | Audit trail |
| Transaction Logs | `transactions` collection | ✅ Yes | Financial records |
| Invoices | `invoices` collection | ✅ Yes | Accounting |

**Preservation Method:**
- Add `user_deleted: true` marker
- Add `user_deleted_at: Timestamp` marker
- Keep all original financial data intact
- Can be queried for tax/legal purposes

**Legal Basis:**
- **GDPR Article 17**: Right to erasure with exceptions for legal obligations
- **Tax Law**: Financial records must be retained for 7 years
- **Accounting Standards**: Billing history must be preserved

---

## 🔒 SECURITY & COMPLIANCE

### Password Verification

All deletion operations require password confirmation:

```python
# Verify password before deletion
if not pwd_context.verify(request.password, user_data.get('password_hash')):
    raise HTTPException(401, "Invalid password")
```

### Admin Access Control

Manual deletions restricted to administrators:

```javascript
if (!context.auth || !context.auth.token.admin) {
  throw new functions.https.HttpsError('permission-denied');
}
```

### Audit Logging

All deletions logged with:
- User ID & email
- Deletion timestamp
- Reason for deletion
- Success/failure status
- Error details (if failed)

---

## 🧪 TESTING GUIDE

### 1. Test Deletion Request (Postman)

**POST** `http://localhost:8000/api/v1/users/account/delete`

```json
{
  "password": "test_password",
  "reason": "Testing deletion flow"
}
```

**Expected Response:**
```json
{
  "message": "Your account deletion has been scheduled...",
  "deletion_scheduled_for": "2025-12-30T23:59:59Z",
  "days_until_deletion": 7,
  "cancellation_possible": true
}
```

---

### 2. Verify Database State

**Check Firestore:**
```javascript
const userDoc = await db.collection('users').doc(userId).get();
const data = userDoc.data();

console.log(data.account_status); // "pending_deletion"
console.log(data.deletion_scheduled_for); // Future timestamp
console.log(data.deletion_reason); // "Testing deletion flow"
```

---

### 3. Test Cancellation

**POST** `http://localhost:8000/api/v1/users/account/delete/cancel`

```json
{
  "password": "test_password"
}
```

**Expected Response:**
```json
{
  "message": "Account deletion has been cancelled successfully",
  "status": "active"
}
```

**Verify:**
- `account_status` = `"active"`
- `deletion_scheduled_for` = `null`
- `deletion_requested_at` = `null`

---

### 4. Test Cloud Function Locally

**Install Firebase Emulator:**
```bash
npm install -g firebase-tools
firebase init emulators
```

**Start Emulator:**
```bash
cd backend/firebase_functions
firebase emulators:start
```

**Trigger Function:**
```bash
# Will process all pending deletions
curl -X POST http://localhost:5001/<project-id>/us-central1/processScheduledAccountDeletions
```

**Check Logs:**
```bash
firebase functions:log
```

---

### 5. Test Manual Deletion (Admin)

```javascript
const functions = getFunctions();
const deleteAccount = httpsCallable(functions, 'manualAccountDeletion');

try {
  const result = await deleteAccount({ 
    userId: 'test_user_123' 
  });
  
  console.log(result.data);
  // { success: true, message: "Account test_user_123 deleted successfully" }
  
} catch (error) {
  console.error('Deletion failed:', error);
}
```

---

## 📅 DELETION TIMELINE

### Example Scenario

**User has Hobby Plan ($9.99/month)**
- Subscription started: Jan 1, 2025
- Current period ends: Jan 31, 2025
- User requests deletion: Jan 15, 2025

**Timeline:**
1. **Jan 15, 2025** - User requests deletion
   - Subscription cancelled immediately (no more billing)
   - Deletion scheduled for: **Jan 30, 2025** (1 day before period end)
   - User can still access service until Jan 30
   - User can cancel deletion anytime before Jan 30

2. **Jan 30, 2025, 2:00 AM UTC** - Nightly function runs
   - Checks if `deletion_scheduled_for` <= `now`
   - Processes deletion:
     - Deletes user data
     - Deletes storage files
     - Preserves payment records
     - Logs deletion in audit log

3. **Jan 30, 2025, 2:05 AM UTC** - Deletion complete
   - User cannot login
   - Data removed from database
   - Files removed from storage
   - Payment history preserved for 7 years

---

## 🚨 ERROR HANDLING

### Backend Errors

| Error | Status | Reason |
|-------|--------|--------|
| Invalid password | 401 | Password verification failed |
| User not found | 404 | User doesn't exist |
| No deletion scheduled | 404 | Account not marked for deletion |
| Internal error | 500 | Database/storage error |

### Cloud Function Errors

| Error | Handling |
|-------|----------|
| Storage deletion fails | Log error, continue with other deletions |
| Auth deletion fails | Log warning (user may be already deleted) |
| Firestore error | Retry batch, log failure |
| No users to delete | Success (nothing to do) |

---

## 📈 MONITORING & ALERTS

### Metrics to Track

1. **Deletion Requests:**
   - Daily count of deletion requests
   - Reasons for deletion
   - Cancellation rate

2. **Nightly Processing:**
   - Accounts processed per night
   - Success rate
   - Average processing time
   - Errors encountered

3. **Audit Compliance:**
   - Payment records preserved
   - Deletion logs maintained
   - Admin manual deletions

### Firebase Console Monitoring

**Check Function Logs:**
```bash
firebase functions:log --only processScheduledAccountDeletions
```

**Check Metrics:**
- Go to Firebase Console → Functions
- View invocations, errors, execution time
- Set up alerts for failures

---

## 🔗 INTEGRATION WITH FRONTEND

### Flutter Example

```dart
// Request account deletion
Future<void> requestAccountDeletion(String password, String reason) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/users/account/delete'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'password': password,
      'reason': reason,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Deletion Scheduled'),
        content: Text(
          'Your account will be deleted on ${data['deletion_scheduled_for']}\n\n'
          'Days remaining: ${data['days_until_deletion']}\n\n'
          'You can cancel this deletion anytime before the scheduled date.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Cancel deletion
Future<void> cancelAccountDeletion(String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/users/account/delete/cancel'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account deletion cancelled successfully')),
    );
  }
}
```

---

## 📜 COMPLIANCE CHECKLIST

- [x] **GDPR Article 17** - Right to erasure implemented
- [x] **GDPR Article 17(3)(b)** - Legal obligation exception (financial records)
- [x] **Tax Law Compliance** - 7-year retention of payment records
- [x] **User Consent** - Password confirmation required
- [x] **Data Minimization** - Only necessary data preserved
- [x] **Audit Trail** - All deletions logged
- [x] **Transparency** - User informed of deletion date
- [x] **Right to Cancel** - Cancellation possible before deletion
- [x] **Automated Processing** - Nightly function handles deletions
- [x] **Error Handling** - Failures logged and audited

---

## 🚀 DEPLOYMENT STEPS

### 1. Deploy Backend API

```bash
cd /Users/muhammadshakil/Projects/ai_content_generator/backend
source .venv/bin/activate
# Server should already be running
```

### 2. Deploy Firebase Cloud Functions

```bash
cd /Users/muhammadshakil/Projects/ai_content_generator/backend/firebase_functions
npm install
firebase login
firebase deploy --only functions
```

### 3. Update Frontend

Add deletion endpoints to Flutter app:
- Account settings page with "Delete Account" button
- Confirmation dialog with password input
- Display scheduled deletion date
- Show cancellation option

### 4. Test End-to-End

1. Request deletion via API
2. Verify database state
3. Wait for scheduled time (or trigger manually)
4. Verify deletion completed
5. Check audit logs
6. Verify payment records preserved

---

## 📞 SUPPORT & TROUBLESHOOTING

### Common Issues

**1. Function not triggering at scheduled time**
- Check Firebase Console → Functions → Logs
- Verify cron expression: `0 2 * * *`
- Ensure project billing is enabled

**2. Storage deletion fails**
- Check Firebase Storage permissions
- Verify bucket exists
- Check file paths match pattern: `users/{userId}/*`

**3. Payment records not preserved**
- Verify Firestore rules allow updates
- Check batch commit completed
- Verify `user_deleted` marker added

### Getting Help

- **Firebase Issues**: Check Firebase Console logs
- **Backend Issues**: Check FastAPI logs
- **Function Issues**: Run `firebase functions:log`

---

**Last Updated:** November 25, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
