#!/bin/bash

echo "🎬 Running Simple Visual E2E Test"
echo "=================================="
echo ""
echo "📱 Make sure your Android emulator is running and visible!"
echo "   You should see the Quiz App launch and navigate on screen."
echo ""
echo "🎯 Starting test in 3 seconds..."
sleep 1
echo "   3..."
sleep 1
echo "   2..."
sleep 1
echo "   1..."
echo ""
echo "🚀 Launching visual test..."

flutter test integration_test/simple_visual_test.dart -d emulator-5554