#!/bin/bash
# daily-dev.sh - Run this every day you start development

echo "🚀 Starting daily development workflow..."

# 1. Sync with latest development
echo "📦 Syncing with development branch..."
git checkout development
git pull origin development

# 2. Check current issues
echo "📋 Current high-priority issues:"
gh issue list --label "priority:high" --limit 5

# 3. Verify environment
echo "🔧 Checking environment..."
flutter doctor
firebase --version

# 4. Get dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# 5. Generate code if needed
echo "⚙️ Running code generation..."
dart run build_runner build --delete-conflicting-outputs

# 6. Run tests  
echo "🧪 Running tests..."
flutter test

# 7. Check code quality
echo "🔍 Checking code quality..."
flutter analyze

echo "✅ Daily setup complete! Ready for development."
echo ""
echo "💡 Next steps:"
echo "   - Choose an issue: gh issue list --label 'priority:high'"
echo "   - Brainstorm feature: /project:brainstorm-feature 'your idea'"
echo "   - Implement issue: /project:implement-issue <number>"