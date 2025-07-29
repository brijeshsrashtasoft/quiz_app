#!/bin/bash
# quality-check.sh - Run before creating PR

echo "🔍 Running comprehensive quality checks..."

# 1. Format code
echo "📝 Formatting code..."
dart format .

# 2. Analyze code
echo "🔬 Analyzing code..."
if ! flutter analyze; then
    echo "❌ Code analysis failed! Please fix issues before proceeding."
    exit 1
fi

# 3. Run tests
echo "🧪 Running tests..."
if ! flutter test --coverage; then
    echo "❌ Tests failed! Please fix failing tests before proceeding."
    exit 1
fi

# 4. Check coverage
echo "📊 Checking test coverage..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html 2>/dev/null
    echo "📈 Coverage report generated at coverage/html/index.html"
else
    echo "⚠️ genhtml not found. Install lcov for coverage reports: brew install lcov"
fi

# 5. Build verification
echo "🏗️ Verifying builds..."
if ! flutter build web --release; then
    echo "❌ Web build failed!"
    exit 1
fi

if ! flutter build apk --debug; then
    echo "❌ Android build failed!"
    exit 1
fi

echo "✅ Quality checks complete!"
echo ""
echo "🚀 Ready to create PR:"
echo "   git push -u origin \$(git branch --show-current)"
echo "   gh pr create --base development --title 'type(scope): description'"