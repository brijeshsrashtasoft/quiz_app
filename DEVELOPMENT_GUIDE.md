# 🚀 Complete Development Guide

This guide provides everything you need to develop the Kahoot-style quiz app efficiently using Claude Code.

## 📋 **Quick Start Checklist**

- [ ] Flutter SDK installed and configured
- [ ] Firebase CLI installed and authenticated
- [ ] GitHub CLI configured
- [ ] Claude Code with MCP servers
- [ ] Development branch checked out

## 🎯 **When to Use Which Command**

### **🧠 Feature Planning & Design**
```bash
# When you have a new feature idea or change request
# Implementation: .claude/commands/brainstorm-feature.md
/project:brainstorm-feature "Add multiplayer team mode for quizzes"

# When creating a completely new feature from scratch  
/project:create-feature authentication

# When you need to understand existing codebase
# Use Read, Glob, Grep tools to explore code
# Reference architecture in CLAUDE.md for context
```

### **🔧 Development & Implementation**
```bash
# When implementing a specific GitHub issue
# Implementation: .claude/commands/implement-issue.md
# Follows agent assignment logic from CLAUDE.md
/project:implement-issue 11

# When you need to run tests for a specific feature
/project:run-tests authentication

# When generating code structure
/project:generate-code
```

### **🧪 Testing & Quality**
```bash
# Run comprehensive test suite
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code quality
flutter analyze

# Format all code
dart format .

# Build and verify
flutter build web
```

### **🔥 Firebase Operations**
```bash
# Deploy Firestore rules
/project:firestore-rules

# Start Firebase emulators
firebase emulators:start

# Deploy to Firebase
firebase deploy
```

## 🗂️ **Complete Development Task Sequence**

### **Phase 1: Project Foundation** ⏱️ *1-2 weeks*

#### **1.1 Setup Infrastructure** 
```bash
# Check current high-priority setup issues
gh issue list --label "type:setup,priority:high"

# Start with Firebase setup (usually issue #11)
/project:implement-issue 11

# Verify Firebase connection
firebase projects:list
flutter run
```

#### **1.2 UI Constants Implementation**
```bash
# Implement centralized UI constants from docs/ui_guideline.md
# This is a prerequisite for all UI development
# See ticket: docs/tickets/ui-constants-implementation.md
# Creates color system, typography, spacing, and animations
flutter create lib/shared/constants/
# Implement app_colors.dart, app_text_styles.dart, app_spacing.dart
```

#### **1.3 Core Architecture**
```bash
# Implement clean architecture foundation (usually issue #18)
/project:implement-issue 18

# Verify architecture
flutter analyze
dart run build_runner build
```

#### **1.4 Essential Services**
```bash
# Set up navigation (issue #19)
/project:implement-issue 19

# Set up error handling (issue #20)  
/project:implement-issue 20
```

### **Phase 2: Authentication System** ⏱️ *1-2 weeks*

#### **2.1 Domain Layer First**
```bash
# Start with authentication domain (issue #6)
/project:implement-issue 6
flutter test test/features/authentication/domain/
```

#### **2.2 Data Layer Integration**
```bash
# Implement Firebase auth data layer (issue #7)
/project:implement-issue 7
flutter test test/features/authentication/data/
```

#### **2.3 UI Implementation**
```bash
# Create authentication UI (issue #8)
/project:implement-issue 8
flutter test test/features/authentication/presentation/
```

#### **2.4 Complete Auth Flow**
```bash
# Implement full authentication system (issue #12)
/project:implement-issue 12

# Test complete flow
flutter test
flutter analyze
```

### **Phase 3: Quiz Management** ⏱️ *2-3 weeks*

#### **3.1 Quiz Creation**
```bash
# Implement quiz creation interface (issue #13)
/project:implement-issue 13

# Test quiz CRUD operations
flutter test test/features/quiz_creation/
```

#### **3.2 Quiz Storage & Retrieval**
```bash
# Test Firestore integration
firebase emulators:start
flutter test integration_test/quiz_management_test.dart
```

### **Phase 4: Real-time Game Sessions** ⏱️ *2-3 weeks*

#### **4.1 Game Session Backend**
```bash
# Implement real-time multiplayer (issue #14)
/project:implement-issue 14

# Test real-time synchronization
flutter test integration_test/game_session_test.dart
```

#### **4.2 Live Leaderboard**
```bash
# Build leaderboard system (issue #15)
/project:implement-issue 15

# Performance testing
flutter run --profile
# Monitor real-time performance in Firebase Console
```

### **Phase 5: UI/UX Polish** ⏱️ *1-2 weeks*

#### **5.1 Design System Implementation**
```bash
# Create engaging UI components (issue #16)
/project:implement-issue 16

# Test responsive design
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

#### **5.2 Animations & Interactions**
```bash
# Verify smooth animations
flutter run --profile
# Check 60fps performance in DevTools
```

### **Phase 6: Testing & Quality Assurance** ⏱️ *1 week*

#### **6.1 Comprehensive Testing**
```bash
# Set up testing infrastructure (issue #17)
/project:implement-issue 17

# Achieve >80% coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### **6.2 End-to-End Testing**
```bash
# Run integration tests
flutter test integration_test/
flutter drive --target=test_driver/app.dart
```

### **Phase 7: Deployment & Production** ⏱️ *1 week*

#### **7.1 Production Build**
```bash
# Build for all platforms
/project:build-all

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy to app stores (issue #21)
/project:implement-issue 21
```

## 🛠️ **Runnable Development Scripts**

### **Daily Development Workflow**
```bash
#!/bin/bash
# daily-dev.sh - Run this every day you start development

echo "🚀 Starting daily development workflow..."

# 1. Sync with latest development
git checkout development
git pull origin development

# 2. Check current issues
echo "📋 Current high-priority issues:"
gh issue list --label "priority:high" --limit 5

# 3. Verify environment
echo "🔧 Checking environment..."
flutter doctor
firebase --version

# 4. Run tests
echo "🧪 Running tests..."
flutter test

# 5. Check code quality  
echo "🔍 Checking code quality..."
flutter analyze

echo "✅ Daily setup complete! Ready for development."
```

### **Feature Development Script**
```bash
#!/bin/bash
# develop-feature.sh - Use when starting a new feature

if [ $# -eq 0 ]; then
    echo "Usage: ./develop-feature.sh <issue-number>"
    exit 1
fi

ISSUE_NUMBER=$1

echo "🚀 Starting feature development for issue #$ISSUE_NUMBER"

# 1. Get issue details
gh issue view $ISSUE_NUMBER

# 2. Create feature branch
git checkout development
git pull origin development
git checkout -b feature/issue-$ISSUE_NUMBER-$(gh issue view $ISSUE_NUMBER --json title -q .title | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | cut -c1-20)

# 3. Start implementation
echo "🤖 Use this command to implement:"
echo "/project:implement-issue $ISSUE_NUMBER"
```

### **Quality Check Script**
```bash
#!/bin/bash
# quality-check.sh - Run before creating PR

echo "🔍 Running comprehensive quality checks..."

# 1. Format code
echo "📝 Formatting code..."
dart format .

# 2. Analyze code
echo "🔬 Analyzing code..."
flutter analyze

# 3. Run tests
echo "🧪 Running tests..."
flutter test --coverage

# 4. Check coverage
echo "📊 Checking test coverage..."
genhtml coverage/lcov.info -o coverage/html
echo "Coverage report generated at coverage/html/index.html"

# 5. Build verification
echo "🏗️ Verifying builds..."
flutter build web --release
flutter build apk --debug

echo "✅ Quality checks complete!"
```

### **Firebase Operations Script**
```bash
#!/bin/bash
# firebase-ops.sh - Firebase operations helper

case $1 in
  "start")
    echo "🔥 Starting Firebase emulators..."
    firebase emulators:start
    ;;
  "deploy")
    echo "🚀 Deploying to Firebase..."
    firebase deploy
    ;;
  "rules")
    echo "🛡️ Deploying Firestore rules..."
    firebase deploy --only firestore:rules
    ;;
  "functions")
    echo "⚡ Deploying Cloud Functions..."
    firebase deploy --only functions
    ;;
  *)
    echo "Usage: ./firebase-ops.sh [start|deploy|rules|functions]"
    ;;
esac
```

## 🎯 **Development Milestones & Success Metrics**

### **Week 1-2: Foundation**
- [ ] Firebase connected and configured
- [ ] Clean architecture structure implemented
- [ ] Navigation and error handling working
- [ ] First PR merged to development

### **Week 3-4: Authentication**
- [ ] User registration and login working
- [ ] Google Sign-In integrated
- [ ] User session management implemented
- [ ] Authentication tests >80% coverage

### **Week 5-7: Quiz Management**
- [ ] Quiz creation interface functional
- [ ] Questions can be added/edited/deleted
- [ ] Quiz sharing and privacy settings
- [ ] Quiz management tests comprehensive

### **Week 8-10: Real-time Features**
- [ ] Game sessions with PIN generation
- [ ] Real-time player joining and answers
- [ ] Live leaderboard updates
- [ ] <200ms real-time latency achieved

### **Week 11-12: UI/UX Polish**
- [ ] Kahoot-style colorful interface
- [ ] Smooth animations and transitions
- [ ] Responsive design across platforms
- [ ] Accessibility features implemented

### **Week 13: Testing & Launch**
- [ ] >80% test coverage achieved
- [ ] Performance benchmarks met
- [ ] Production deployment successful
- [ ] User acceptance testing complete

## 🚨 **Troubleshooting Common Issues**

### **Branch Issues**
```bash
# If you're on wrong branch
git checkout development
git pull origin development

# If merge conflicts
git status
git merge --abort  # if needed
git pull origin development
```

### **Firebase Issues**
```bash
# If Firebase connection fails
firebase login
firebase use --add
firebase projects:list

# If emulators won't start
firebase emulators:start --only firestore,auth
```

### **Testing Issues**
```bash
# If tests fail
flutter clean
flutter pub get
flutter test --verbose

# If coverage issues
flutter test --coverage
lcov --remove coverage/lcov.info 'lib/*/**.g.dart' -o coverage/lcov.info
```

### **Build Issues**
```bash
# If build fails
flutter clean
flutter pub get
flutter pub deps
flutter doctor

# If platform-specific issues
cd android && ./gradlew clean
cd ios && rm -rf Pods/ && pod install
```

## 📞 **Getting Help**

### **Issue Templates**
```bash
# Create bug report
gh issue create --template bug_report.md

# Create feature request  
gh issue create --template feature_request.md

# Get help with existing issue
gh issue comment <number> --body "Need help with..."
```

### **Development Support**
- **Architecture Questions**: Use flutter-architect subagent
- **Firebase Issues**: Use firebase-specialist subagent  
- **UI/UX Problems**: Use ui-designer subagent (see `.claude/agents/ui-designer.md`)
- **Testing Help**: Use testing-specialist subagent (see `.claude/agents/testing-specialist.md`)
- **Performance Issues**: Use performance-optimizer subagent (see `.claude/agents/performance-optimizer.md`)
- **Code Quality**: Use code-reviewer subagent (see `.claude/agents/code-reviewer.md`)

---

## 🎉 **Quick Command Reference**

```bash
# Daily workflow (scripts/daily-dev.sh)
./scripts/daily-dev.sh

# Feature development (scripts/develop-feature.sh)
./scripts/develop-feature.sh <issue-number>

# Quality checks (scripts/quality-check.sh)
./scripts/quality-check.sh

# Firebase operations (scripts/firebase-ops.sh)
./scripts/firebase-ops.sh [start|deploy|rules|functions]

# Custom commands (see .claude/commands/ for implementations)
/project:brainstorm-feature "feature description"
/project:implement-issue <number>
/project:create-feature <name>
/project:run-tests <feature>
```

## 📖 **Documentation Hierarchy**

```
CLAUDE.md (Master)
├── Architecture & Design Principles
├── UI/UX Guidelines Reference (→ docs/ui_guideline.md)
├── Sub-Agent Coordination
└── Technology Stack

DEVELOPMENT_GUIDE.md (This File)
├── Command Usage & Workflow
├── 13-Week Development Timeline
├── Troubleshooting & Scripts
└── Quality Gates

docs/ui_guideline.md
├── Complete Color Palette
├── Typography System
├── Component Specifications
├── Animation Standards
└── Platform Adaptations

docs/github_instruction.md
├── GitHub Workflow Standards
├── Commit Message Formats
├── PR Templates & Guidelines
└── Communication Standards

.claude/agents/
├── flutter-architect.md
├── firebase-specialist.md
├── ui-designer.md (references ui_guideline.md)
├── testing-specialist.md
├── code-reviewer.md
└── performance-optimizer.md

.claude/commands/
├── implement-issue.md
└── brainstorm-feature.md
```

**Happy coding! 🚀**