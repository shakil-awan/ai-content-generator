# Frontend Video Generation - Quick Testing Guide

## Prerequisites
1. ✅ Backend server running on `http://127.0.0.1:8000`
2. ✅ User logged in with valid JWT token
3. ✅ Replicate API key configured in backend

## Step-by-Step Testing

### Step 1: Start Backend Server
```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected Output**:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

### Step 2: Start Flutter App
```bash
cd /Users/muhammadshakil/Projects/ai_content_generator
flutter run
```

Or run from VS Code:
- Open Run & Debug panel (⌘+Shift+D)
- Select "Flutter: Run"
- Press F5

### Step 3: Login to App
1. Open the app
2. Navigate to Login screen
3. Enter credentials
4. Verify successful login

### Step 4: Generate Script
1. Navigate to **Video Script Generation** feature
2. Fill in the form:
   - **Topic**: "How to master content marketing"
   - **Platform**: YouTube
   - **Duration**: 60s
   - **Tone**: Professional
   - **Include Hooks**: Yes
   - **Include CTA**: Yes
3. Click **Generate Script**
4. Wait ~12 seconds for script generation

**Expected Result**:
- ✅ Script displays successfully
- ✅ Hook section visible
- ✅ Multiple script sections visible
- ✅ "Generate Video 🎬" button appears at bottom

### Step 5: Generate Video (THE KEY TEST!)
1. Scroll to bottom of generated script
2. Click **"Generate Video 🎬"** button

**Expected Behavior**:
- ✅ Button becomes disabled
- ✅ Progress card appears with:
  - Circular spinner
  - Status message: "Starting video generation..."
  - Progress bar at 0%
  - Progress percentage: "0% complete"

### Step 6: Watch Progress Updates
Wait and observe progress updates (every 3 seconds):

**Expected Progress Sequence**:
```
0%   → "Starting video generation..."
10%  → "Processing video..."
25%  → "Processing video..."
50%  → "Processing video..."
75%  → "Processing video..."
100% → "Video ready!"
```

**Timing**:
- 60s video: ~90-120 seconds total
- Progress updates every 3 seconds
- ~30-40 status checks

### Step 7: Video Completion
After ~90-120 seconds:

**Expected Result**:
- ✅ Progress card disappears
- ✅ Success card appears:
  - Green checkmark icon
  - "Video Ready! 🎉" title
  - "Your video has been generated successfully"
  - "Download Video" button
- ✅ Snackbar notification: "Video generated successfully! 🎉"
- ✅ Button text changes to "Generate Another Video"

### Step 8: Download Video
1. Click **"Download Video"** button

**Expected Behavior**:
- ✅ Snackbar shows video URL
- Video URL format: `https://storage.googleapis.com/.../*.mp4`

**Note**: Actual download implementation is pending. For now, the URL is displayed in a snackbar.

---

## What to Check

### ✅ UI States
- [ ] Initial state: "Generate Video 🎬" button visible
- [ ] Loading state: Progress card with spinner and bar
- [ ] Progress updates: Bar moves from 0% to 100%
- [ ] Completed state: Success card with download button
- [ ] Button text changes after completion

### ✅ Progress Tracking
- [ ] Progress starts at 0%
- [ ] Progress updates every 3 seconds
- [ ] Progress reaches 100%
- [ ] Status messages update
- [ ] Linear progress bar animates smoothly

### ✅ Notifications
- [ ] Success notification appears on completion
- [ ] Error notification appears on failure
- [ ] Snackbar auto-dismisses after 4 seconds

### ✅ Error Handling
- [ ] Network errors show error message
- [ ] Authentication errors show "Please login again"
- [ ] Backend errors show meaningful messages

### ✅ Responsiveness
- [ ] Works on mobile layout
- [ ] Works on desktop layout
- [ ] Button sizes appropriate
- [ ] Progress card fits screen

---

## Testing Error Scenarios

### Test 1: Generate Without Script
1. Don't generate script first
2. Try to click "Generate Video"

**Expected**: Should not be possible (button only appears after script generation)

### Test 2: Network Failure
1. Stop backend server
2. Generate script (will fail)
3. Check error handling

**Expected**: Error snackbar with network error message

### Test 3: Invalid Generation ID
1. Manually modify `generationId` in controller
2. Try to generate video

**Expected**: Backend error or 404 response

### Test 4: Authentication Expired
1. Wait for JWT token to expire
2. Try to generate video

**Expected**: "Unauthorized" error, redirect to login

---

## Debug Checklist

### If Video Generation Doesn't Start
1. ✅ Check backend logs for API request
2. ✅ Verify JWT token is valid
3. ✅ Check generation ID is present
4. ✅ Verify Replicate API key is configured
5. ✅ Check network connectivity

### If Progress Doesn't Update
1. ✅ Check backend logs for status requests
2. ✅ Verify polling is happening (every 3 seconds)
3. ✅ Check backend video service logs
4. ✅ Verify Replicate API is responding

### If Video Never Completes
1. ✅ Check backend timeout (5 minutes)
2. ✅ Check Replicate API status
3. ✅ Check backend video service logs
4. ✅ Verify Firebase Storage upload

### If Video URL Doesn't Work
1. ✅ Check Firebase Storage permissions
2. ✅ Verify video was uploaded
3. ✅ Check video file exists
4. ✅ Verify URL is public

---

## Expected Console Output

### Frontend (Flutter)
```
[LOG] Generating video from script: gen_1234567890
[LOG] Video job created: video_job_abc123
[LOG] Polling video status...
[LOG] Video progress: 10%
[LOG] Video progress: 25%
[LOG] Video progress: 50%
[LOG] Video progress: 75%
[LOG] Video progress: 100%
[LOG] Video ready: https://storage.googleapis.com/.../video.mp4
```

### Backend (Python)
```
INFO: POST /api/v1/generate/video-from-script
INFO: Creating video job for generation: gen_1234567890
INFO: Submitting to Replicate API...
INFO: Replicate job started: abc123def456
INFO: GET /api/v1/generate/video-status/video_job_abc123
INFO: Video progress: 25%
INFO: GET /api/v1/generate/video-status/video_job_abc123
INFO: Video progress: 50%
INFO: Video completed successfully
INFO: Uploaded to Firebase Storage: gs://bucket/videos/video_job_abc123.mp4
```

---

## Performance Benchmarks

### Target Metrics
- **Script Generation**: ≤ 15 seconds
- **Video Generation**: 60-180 seconds
  - 30s video: 60-90 seconds
  - 60s video: 90-120 seconds
  - 3min video: 150-180 seconds
- **Status Poll Interval**: 3 seconds
- **Total Polls**: 20-40 requests

### Cost Metrics
- **Script**: ~$0.05
- **Video (60s)**: ~$0.25
- **Total**: ~$0.30 per complete flow

---

## Quick Commands

### Start Backend
```bash
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload
```

### Run Flutter
```bash
flutter run
```

### Check Backend Health
```bash
curl http://127.0.0.1:8000/health
```

### Test Video Endpoint (Manual)
```bash
# 1. Login and get token
TOKEN="your_jwt_token_here"

# 2. Generate script
curl -X POST http://127.0.0.1:8000/api/v1/generate/video-script \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Test video",
    "platform": "youtube",
    "duration": 60,
    "tone": "professional"
  }'

# 3. Generate video (use generation_id from step 2)
curl -X POST http://127.0.0.1:8000/api/v1/generate/video-from-script \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "generation_id": "gen_1234567890",
    "include_subtitles": true,
    "include_captions": true
  }'

# 4. Check status (use video_job_id from step 3)
curl -X GET http://127.0.0.1:8000/api/v1/generate/video-status/video_job_abc123 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Success Criteria

### ✅ Must Have
- [ ] Script generates successfully
- [ ] "Generate Video" button appears
- [ ] Video generation starts on click
- [ ] Progress updates every 3 seconds
- [ ] Video completes successfully
- [ ] Video URL is accessible
- [ ] No errors in console

### ✅ Should Have
- [ ] Progress bar animates smoothly
- [ ] Notifications are user-friendly
- [ ] Error messages are clear
- [ ] UI is responsive
- [ ] Button states are clear

### ✅ Nice to Have
- [ ] Download video works
- [ ] Video preview plays
- [ ] Share functionality works
- [ ] Video history visible

---

## Troubleshooting Guide

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Button doesn't appear | Script not generated | Generate script first |
| Progress stuck at 0% | Backend not processing | Check backend logs |
| Video never completes | Timeout or API error | Check Replicate API status |
| Video URL 404 | Storage upload failed | Check Firebase Storage |
| Authentication error | Token expired | Re-login to app |
| Network error | Backend not running | Start backend server |

---

## Next Steps After Testing

1. ✅ Verify all success criteria met
2. ✅ Document any issues found
3. ✅ Fix critical bugs
4. ✅ Add video preview player
5. ✅ Implement actual download
6. ✅ Deploy to production

---

**Testing Status**: ⏳ READY TO TEST  
**Expected Duration**: 10-15 minutes  
**Success Rate**: Should be 90%+ with backend running

---

*Guide created: November 28, 2025*
