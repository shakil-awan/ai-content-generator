# Video Generation API Testing Guide

## Quick Test with cURL

### 1. Get Authentication Token

First, log in to get your JWT token:

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "password": "your-password"
  }'
```

Copy the `access_token` from the response.

### 2. Generate Video Script

```bash
export TOKEN="your-jwt-token-here"

curl -X POST http://localhost:8000/api/v1/generate/video-script \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "5 Tips for Better Productivity",
    "platform": "youtube",
    "duration": 60,
    "tone": "professional",
    "include_hooks": true,
    "include_cta": true
  }' | jq '.'
```

Copy the `id` field from the response (this is your `generation_id`).

### 3. Generate Video from Script

```bash
export GENERATION_ID="gen_abc123"  # Replace with actual ID from step 2

curl -X POST http://localhost:8000/api/v1/generate/video-from-script \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"generation_id\": \"$GENERATION_ID\",
    \"voice_style\": \"natural\",
    \"music_mood\": \"upbeat\",
    \"video_style\": \"modern\",
    \"include_captions\": true
  }" | jq '.'
```

This will take 60-180 seconds depending on video duration. The response will include:
- `video_url`: Direct link to the generated video
- `processing_time`: How long it took to generate
- `cost`: Estimated cost in USD
- `id`: Video job ID for status checking

### 4. Check Video Status (Optional)

```bash
export VIDEO_JOB_ID="video_xyz789"  # Replace with actual ID from step 3

curl -X GET http://localhost:8000/api/v1/generate/video-status/$VIDEO_JOB_ID \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

## Automated Testing Script

Use the provided bash script for full end-to-end testing:

```bash
# Set your token
export AUTH_TOKEN="your-jwt-token-here"

# Run the test script
./backend/test_video_generation.sh
```

The script will:
1. Generate a video script
2. Generate video from the script
3. Check video status
4. Save results to JSON file

## Expected Response Format

### Video Generation Response
```json
{
  "id": "video_abc123",
  "generation_id": "gen_xyz789",
  "user_id": "user_123",
  "status": "completed",
  "progress": 100,
  "video_url": "https://replicate.delivery/pbxt/abc123.mp4",
  "duration": 60,
  "processing_time": 90.5,
  "cost": 0.25,
  "error_message": null,
  "metadata": {
    "platform": "youtube",
    "video_style": "modern",
    "model": "zeroscope-v2-xl",
    "prediction_id": "pred_abc123"
  },
  "created_at": "2025-11-28T10:00:00Z",
  "updated_at": "2025-11-28T10:01:30Z"
}
```

### Video Status Response
```json
{
  "id": "video_abc123",
  "status": "completed",
  "progress": 100,
  "video_url": "https://replicate.delivery/pbxt/abc123.mp4",
  "processing_time": 90.5,
  "error_message": null
}
```

## Error Handling

### 402 Payment Required
```json
{
  "error": "video_limit_reached",
  "message": "You've reached your monthly video limit of 0. Upgrade to Pro for 10/month or Enterprise for unlimited.",
  "used": 0,
  "limit": 0
}
```

**Solution:** Upgrade to Pro or Enterprise tier.

### 404 Not Found
```json
{
  "error": "generation_not_found",
  "message": "Script generation gen_xyz789 not found"
}
```

**Solution:** Verify the `generation_id` exists and belongs to your user.

### 500 Internal Server Error
```json
{
  "error": "video_generation_failed",
  "message": "Video generation failed: API timeout"
}
```

**Solution:** Check Replicate API status, verify API key is correct.

## Performance Benchmarks

| Video Duration | Processing Time | Cost  |
|----------------|-----------------|-------|
| 30 seconds     | 60-90 seconds   | $0.15 |
| 60 seconds     | 90-120 seconds  | $0.25 |
| 3 minutes      | 150-180 seconds | $0.45 |
| 5 minutes      | 240-300 seconds | $0.75 |

**Note:** Processing times may vary based on Replicate API load. Costs are estimates.

## Troubleshooting

### Video Generation Hangs
- Check Replicate API status at https://status.replicate.com
- Increase timeout in video_generation_service.py (default 300s)
- Try a shorter video duration

### "VIDEO_API_KEY not configured" Error
- Add `VIDEO_API_KEY` to `.env` file
- Or ensure `REPLICATE_API_KEY` is set (used as fallback)
- Restart the backend server after updating .env

### Video Quality Issues
- Try different `video_style` options (modern, cinematic, animated, minimal)
- Ensure script is clear and descriptive
- Consider using a different model in `VIDEO_MODEL` config

## Next Steps

After successful testing:
1. ✅ Verify video plays correctly
2. ✅ Check video quality and captions
3. ✅ Test with different platforms (YouTube, TikTok, Instagram)
4. ✅ Test with different durations (30s, 60s, 3min, 5min)
5. ✅ Integrate with Flutter frontend
6. ✅ Test end-to-end user workflow
