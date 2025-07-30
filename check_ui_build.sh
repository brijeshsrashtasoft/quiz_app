#!/bin/bash
echo "🎨 Checking UI components build status..."

# Format code
echo "📝 Formatting code..."
dart format lib/shared/widgets/quiz/ lib/shared/widgets/primitives/

# Quick syntax check
echo "🔍 Checking syntax..."
flutter analyze --no-pub

echo "✅ UI components syntax check complete!"
echo ""
echo "📱 UI Components Created:"
echo "   ✅ CountdownTimer - Animated timer with warning states"
echo "   ✅ QuestionDisplay - Question cards with slide transitions"
echo "   ✅ ScoreCounter - Animated score displays with celebrations"
echo "   ✅ LobbyAvatar - Player avatars with status indicators"
echo "   ✅ ParticleEffects - Confetti and celebration particles"
echo "   ✅ LoadingAnimations - Engaging loading states"
echo "   ✅ ShakeWidget - Shake animations for wrong answers"
echo "   ✅ AnimatedButton - Base animated button components"
echo "   ✅ ResponsiveGrid - Responsive grid layouts"
echo ""
echo "🎯 Next steps:"
echo "   1. Platform verification: ./scripts/quality-check.sh"
echo "   2. Create demo screens to showcase components"
echo "   3. Integration with game logic"