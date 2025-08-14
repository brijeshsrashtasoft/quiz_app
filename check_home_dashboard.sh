#!/bin/bash
# Check home dashboard implementation

echo "🔍 Checking Home Dashboard Implementation..."

# 1. Format and analyze
echo "📝 Formatting code..."
dart format lib/features/home/presentation/pages/home_page.dart

echo "🔬 Analyzing code..."
flutter analyze lib/features/home/presentation/pages/home_page.dart

echo "✅ Home dashboard implementation check complete!"