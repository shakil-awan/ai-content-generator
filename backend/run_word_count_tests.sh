#!/bin/bash

# Automated Word Count Testing Script
# Tests all word counts and monitors backend logs for errors

set -e

BACKEND_DIR="/Users/muhammadshakil/Projects/ai_content_generator/backend"
LOG_FILE="${BACKEND_DIR}/test_logs_$(date +%Y%m%d_%H%M%S).log"

echo "=================================================="
echo "🧪 GEMINI TOKEN LIMIT TEST SUITE"
echo "=================================================="
echo "📅 $(date)"
echo "📁 Backend: $BACKEND_DIR"
echo "📄 Logs: $LOG_FILE"
echo "=================================================="
echo ""

# Navigate to backend
cd "$BACKEND_DIR"

# Check if backend is running
if ! pgrep -f "uvicorn app.main:app" > /dev/null; then
    echo "⚠️  Backend not running!"
    echo "Please start the backend first with:"
    echo "   cd backend"
    echo "   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
    echo ""
    exit 1
fi

echo "✅ Backend is running"
echo ""

# Activate virtual environment
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    echo "✅ Virtual environment activated"
else
    echo "⚠️  Virtual environment not found at .venv"
    echo "Using system Python"
fi

echo ""
echo "🚀 Starting word count tests..."
echo "=================================================="
echo ""

# Run the test script and capture output
python3 test_all_word_counts.py 2>&1 | tee "$LOG_FILE"

# Capture exit code
EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=================================================="
echo "📊 TEST COMPLETE"
echo "=================================================="
echo "📄 Full logs saved to: $LOG_FILE"
echo "🏁 Exit code: $EXIT_CODE"

# Show summary of errors from backend logs if any
echo ""
echo "🔍 Checking backend logs for errors..."

if grep -q "MAX_TOKENS" "$LOG_FILE"; then
    echo "⚠️  MAX_TOKENS errors found in logs!"
    echo "Occurrences:"
    grep -c "MAX_TOKENS" "$LOG_FILE" || true
fi

if grep -q "finish_reason=2" "$LOG_FILE"; then
    echo "⚠️  finish_reason=2 (MAX_TOKENS) detected!"
fi

if grep -q "429" "$LOG_FILE"; then
    echo "⚠️  Rate limit (429) errors detected!"
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All tests passed successfully!"
else
    echo ""
    echo "❌ Some tests failed. Check the log file for details."
fi

echo "=================================================="

exit $EXIT_CODE
