# 🔍 DEBUGGING GUIDE - Video Generation 403 Error

## Current Status

We've added comprehensive logging and proper exception handling. Now we need to see the actual logs to understand why the 403 error is occurring.

---

## What Was Done

### 1. **Enhanced Logging** ✅
Added detailed logging at every step of the video generation flow:

```python
📥 Video generation request received
   Generation ID: xxx
   Video Style: xxx
   ...

👤 Authenticated user:
   UID: xxx
   Email: xxx
   Plan: xxx

📊 Usage: 0/0 videos used this month

📄 Generation found: userId in doc=xxx, current user=xxx
🔍 Match check: xxx == xxx = True/False
```

### 2. **Custom Exception Handling** ✅
Replaced all HTTPException with custom exceptions:
- `DocumentNotFoundError` - Generation not found
- `AppException` - Access denied (403)
- `ValidationError` - Invalid script data
- `DatabaseError` - Database errors

### 3. **Frontend-Compatible Error Format** ✅
All errors now return:
```json
{
  "error": "error_code",
  "message": "User-friendly message",
  "status_code": 403,
  "field": "optional_field",
  ...
}
```

---

## How to Debug

### Step 1: Check Backend Logs

When you click "Generate Video", watch the terminal running the backend. You should see:

```bash
INFO: 127.0.0.1:xxxxx - "POST /api/v1/generate/video-from-script HTTP/1.1" 403 Forbidden
```

**Look for these log lines:**

1. **Request Received:**
```
📥 Video generation request received
   Generation ID: gen_xxx
```
- ✅ If you see this: Request reached the endpoint
- ❌ If missing: Authentication failed BEFORE reaching endpoint

2. **User Authentication:**
```
🔐 Authenticated user: uid=854f96ec-14d2-4288-9626-8441d452b57b, email=xxx
👤 Authenticated user:
   UID: 854f96ec-14d2-4288-9626-8441d452b57b
   Email: mshakilawan735@gmail.com
   Plan: free
```
- ✅ If you see this: JWT token is valid
- ❌ If missing: Token validation failed

3. **Generation Document Check:**
```
📄 Generation found: userId in doc=854f96ec..., current user=854f96ec...
🔍 Match check: 854f96ec... == 854f96ec... = True
```
- ✅ If `= True`: IDs match, should work
- ❌ If `= False`: **THIS IS THE PROBLEM**

4. **Error Message:**
```
❌ Access denied: Generation belongs to abc123, but user is xyz789
```
- This tells us exactly which user IDs don't match

---

## Most Likely Issues

### Issue 1: User ID Mismatch
**Symptom:** `Match check: xxx == yyy = False`

**Cause:** The generation document was created with one user ID, but you're logged in as a different user.

**Solution:**
1. Check if you have multiple accounts
2. Make sure you're logged in with the same account that created the script
3. Or: Delete old generations and create a new script while logged in

### Issue 2: JWT Token Not Sent
**Symptom:** No authentication logs, straight to 403

**Cause:** Frontend not sending Authorization header

**Check Frontend:**
```dart
// In api_service.dart
final headers = {
  'Authorization': 'Bearer $token',  // ← This must be present
  'Content-Type': 'application/json',
};
```

**Solution:** Check browser DevTools → Network → Request Headers

### Issue 3: Generation ID is Wrong
**Symptom:** `❌ Generation document not found`

**Cause:** Frontend sending wrong generation_id

**Solution:** Check what generation_id is being sent vs what's in Firestore

### Issue 4: User Not Fetched from Database
**Symptom:** `User not found` error

**Cause:** JWT has user_id but user document doesn't exist in Firestore

**Solution:** Check Firestore → users collection → verify your user document exists

---

## Testing Steps

### 1. Fresh Test (Recommended)

```bash
# 1. Open browser DevTools (F12)
# 2. Go to Network tab
# 3. Keep it open

# 4. In your app:
#    a) Logout
#    b) Login again
#    c) Generate a NEW script
#    d) Try to generate video from that NEW script

# 5. Check backend terminal for logs
# 6. Check DevTools Network tab for request/response
```

### 2. Check Request in DevTools

In the Network tab, find the POST request to `/api/v1/generate/video-from-script`:

**Request Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
- ✅ Must be present
- ❌ If missing: Frontend auth issue

**Request Payload:**
```json
{
  "generation_id": "abc123...",
  "video_style": "modern",
  ...
}
```
- Copy the `generation_id`
- Check Firestore to see if it exists
- Check the `userId` field in that document

**Response:**
```json
{
  "error": "access_denied",
  "message": "You don't have permission...",
  "status_code": 403
}
```

---

## Quick Diagnostic Commands

### Check Firestore Data:

1. Open Firebase Console
2. Go to Firestore Database
3. Find `generations` collection
4. Search for your generation_id
5. Check the `userId` field
6. Compare with your actual user UID

### Check User UID:

1. Open Firebase Console
2. Go to Authentication
3. Find your email
4. Copy the UID
5. Compare with what's in the logs

---

## Expected Working Flow

```
1. User logs in
   → JWT created with user_id = "854f96ec-14d2-4288-9626-8441d452b57b"

2. User generates script
   → Saved to Firestore with userId = "854f96ec-14d2-4288-9626-8441d452b57b"
   → Returns generation_id = "abc123"

3. User clicks "Generate Video"
   → Frontend sends: {generation_id: "abc123"} + JWT token
   → Backend extracts user_id from JWT = "854f96ec-14d2-4288-9626-8441d452b57b"
   → Backend fetches generation "abc123"
   → Backend checks: generation.userId == current_user.uid
   → Should match! ✅

4. Video generation proceeds...
```

---

## What to Send Me

After testing, please send:

1. **Backend logs** (copy the entire terminal output from when you click "Generate Video")

2. **DevTools Network info:**
   - Request Headers (Authorization header)
   - Request Payload (generation_id value)
   - Response body

3. **Firestore screenshot:**
   - Show the generation document
   - Show the userId field value

4. **Your user UID:**
   - From Firebase Console → Authentication

With this information, I can pinpoint the exact issue!

---

## Current Code Location

All updates are in:
- `/backend/app/api/generate.py` - Lines 1485-1600 (video-from-script endpoint)
- `/backend/app/dependencies.py` - Lines 107-145 (get_current_user)
- `/backend/app/exceptions/__init__.py` - Custom exceptions

Backend is currently running on port 8000 (PID: 89259).

---

## Next Step

**Please try generating a video now and send me the backend terminal output!**

The logs will tell us exactly what's happening. 🔍
