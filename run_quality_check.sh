#!/bin/bash

cd /Users/brijeshsakariya/AndroidStudioProjects/quiz_app_1

echo "🔍 Running Flutter analysis..."
flutter analyze

echo ""
echo "🏗️ Building web platform..."
flutter build web --release

echo ""
echo "🤖 Building Android platform..."
flutter build apk --debug

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "🍎 Building iOS platform..."
    flutter build ios --debug --no-codesign
fi

echo ""
echo "✅ Platform verification complete!"