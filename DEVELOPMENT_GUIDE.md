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
# Automatically creates PR and comments on issue when complete
# Follows agent assignment logic from CLAUDE.md
/project:implement-issue 11

# When you need to run tests for a specific feature
/project:run-tests authentication

# When generating code structure
/project:generate-code
```

**Important**: Every `/project:implement-issue` command now **automatically**:
- ✅ Launches multiple specialized sub-agents in parallel for maximum speed
- ✅ Mandates platform verification by ALL agents (Web, Android, iOS builds)
- ✅ Creates proper commit with closing reference  
- ✅ Creates pull request targeting `development` branch
- ✅ Comments on GitHub issue with implementation summary
- ✅ Includes quality metrics and next steps

**Parallel Execution**: All tasks are now split across specialized sub-agents working simultaneously:
- **Setup Issues**: flutter-architect + firebase-specialist + testing-specialist (ALL PARALLEL)
- **Authentication**: firebase-specialist + flutter-architect + ui-designer + testing-specialist (ALL PARALLEL)
- **UI Components**: ui-designer + flutter-architect + testing-specialist (ALL PARALLEL)
- **Real-time Features**: firebase-specialist + performance-optimizer + flutter-architect + testing-specialist (ALL PARALLEL)

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

### **📊 Current Project Status** *(Updated: 2025-01-30)*

**✅ COMPLETED INFRASTRUCTURE**:
- Issue #1: Firebase Integration ✅ COMPLETED
- Issue #2: Core Architecture Foundation ✅ COMPLETED  
- Issue #3: Development Tools and CI/CD ✅ COMPLETED
- Issue #4: Firestore Database Schema ✅ COMPLETED
- Issue #11: Firebase Configuration ✅ COMPLETED
- Issue #12: Authentication System ✅ COMPLETED
- Issue #17: Testing Framework ✅ COMPLETED
- Issue #18: Clean Architecture Foundation ✅ COMPLETED
- Issue #19: Navigation System ✅ COMPLETED
- Issue #20: Error Handling ✅ COMPLETED

**🔥 ACTIVE DEVELOPMENT OPPORTUNITIES**:
- Issue #6: Authentication Domain Layer ⚠️ **READY TO START**
- Issue #7: Firebase Authentication Data Layer ⚠️ **READY TO START**
- Issue #8: Authentication UI and State Management ⚠️ **READY TO START**
- Issue #9: User Profile Management ⚠️ **READY TO START**
- Issue #10: Authentication Security ⚠️ **READY TO START**
- Issue #13: Quiz Creation Interface ⚠️ **READY TO START**
- Issue #16: UI Components ⚠️ **READY TO START**

**⏭️ NEXT PHASE OPPORTUNITIES**:
- Issue #14: Game Session (Requires #13)
- Issue #15: Leaderboard System (Requires #14)
- Issue #5: Multi-Platform Build (Can start anytime)
- Issue #21: Production Deployment (Requires #5)

### **Phase 1: Foundation Setup** ⏱️ *2-3 weeks* ✅ **COMPLETED**

#### **1.1 Critical Infrastructure ✅ COMPLETED**
```bash
# ✅ ALL FOUNDATION INFRASTRUCTURE COMPLETED
# Issue #1: Firebase Integration ✅ COMPLETED
# Issue #2: Core Architecture Foundation ✅ COMPLETED
# Issue #3: Development Tools and CI/CD ✅ COMPLETED
# Issue #4: Firestore Database Schema ✅ COMPLETED
# Issue #11: Firebase Configuration ✅ COMPLETED
# Issue #17: Testing Framework ✅ COMPLETED
# Issue #18: Clean Architecture Foundation ✅ COMPLETED
# Issue #19: Navigation System ✅ COMPLETED  
# Issue #20: Error Handling ✅ COMPLETED

# Foundation verification commands
flutter analyze          # Should show minimal issues
flutter test            # Core tests should pass
firebase emulators:start # Should start successfully
flutter run -d chrome   # Should launch web app
```

### **Phase 2: Authentication System** ⏱️ *2-3 weeks* ⚠️ **READY TO START**

**Current Status**: Foundation infrastructure complete. Authentication system partially implemented but needs enhancement.

#### **2.1 Authentication Enhancement (Can be parallel) - CURRENT PRIORITY**
```bash
# 🔥 IMMEDIATE OPPORTUNITIES - All can be started in parallel by different agents
/project:implement-issue 6   # [AUTH] Implement User Authentication Domain Layer
/project:implement-issue 7   # [AUTH] Implement Firebase Authentication Data Layer  
/project:implement-issue 8   # [AUTH] Implement Authentication UI and State Management
/project:implement-issue 9   # [AUTH] Implement User Profile Management
/project:implement-issue 10  # [AUTH] Implement Authentication Security and Session Management

# ✅ ALREADY COMPLETED: Issue #12 (Basic authentication system)

# Verify enhanced authentication
flutter test test/features/authentication/
firebase emulators:start
flutter run
```

**⚡ PARALLEL DEVELOPMENT STRATEGY**:
- **Agent A (firebase-specialist)**: Issues #6, #7 (Domain & Data layers)
- **Agent B (ui-designer)**: Issue #8 (Authentication UI enhancement)
- **Agent C (firebase-specialist)**: Issues #9, #10 (Profile management & Security)
- **Agent D (testing-specialist)**: Comprehensive authentication testing

### **Phase 3: Core Quiz Features** ⏱️ *2-3 weeks* ⚠️ **READY TO START**

**Current Status**: Can be started immediately in parallel with authentication enhancements.

#### **3.1 Quiz Creation System & UI Components (Can be parallel) - CURRENT OPPORTUNITY**
```bash
# 🔥 IMMEDIATE OPPORTUNITIES - Can start now
/project:implement-issue 13  # Add quiz creation: Build question management interface
/project:implement-issue 16  # Design UI components: Create engaging quiz interface

# These can be developed in parallel by different agents
# Agent A (flutter-architect): Quiz creation business logic and architecture  
# Agent B (ui-designer): Kahoot-style UI components and quiz interface
# Agent C (firebase-specialist): Quiz data storage and real-time features
# Agent D (testing-specialist): Quiz creation and UI component testing

# Test quiz features
flutter test test/features/quiz_creation/
flutter test test/shared/widgets/
firebase emulators:start
flutter run
```

### **Phase 4: Real-time Multiplayer** ⏱️ *2-3 weeks*

#### **4.1 Game Session Backend (Sequential) - Week 6-7**
```bash
# Implement real-time multiplayer - REQUIRES QUIZ CREATION
/project:implement-issue 14  # Implement game session: Enable real-time multiplayer gameplay

# Test real-time synchronization
flutter test integration_test/game_session_test.dart
firebase emulators:start
```

#### **4.2 Live Leaderboard System (Can be parallel) - Week 7**
```bash
# Build leaderboard system - CAN START AFTER GAME SESSIONS BEGIN
/project:implement-issue 15  # Build leaderboard: Display live ranking system

# Performance testing
flutter run --profile
# Monitor real-time performance (<200ms latency requirement)
```

### **Phase 5: UI/UX Enhancement** ⏱️ *2-3 weeks*

#### **5.1 Engaging UI Components (Can be parallel with Phase 4) - Week 6-8**
```bash
# Create Kahoot-style interface - CAN START DURING GAME SESSION DEVELOPMENT
/project:implement-issue 16  # Design UI components: Create engaging quiz interface

# Test responsive design across platforms
flutter run -d chrome
flutter run -d android  
flutter run -d ios
```

### **Phase 6: Production Preparation** ⏱️ *2-3 weeks*

#### **6.1 Multi-Platform Build Setup (Can be parallel) - Week 9**
```bash
# Configure platform-specific builds - CAN START EARLY
/project:implement-issue 5   # [SETUP] Configure Multi-Platform Build and Deployment

# Verify builds on all platforms
flutter build web --release
flutter build apk --release
flutter build ios --release
```

#### **6.2 Production Deployment (Sequential) - Week 10**
```bash
# Deploy to production environment - REQUIRES BUILD SETUP
/project:implement-issue 21  # Deploy production: Configure Firebase hosting and distribution

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Verify production deployment
curl https://your-app-domain.web.app
```

## 🔄 **Current Parallel Development Opportunities**

### **🚀 IMMEDIATE HIGH-IMPACT PARALLEL TASKS** *(Ready to start NOW)*

#### **CURRENT PHASE: Maximum Parallel Development** 
- **Agent A (firebase-specialist)**: Issues #6, #7 (Authentication Domain & Data layers)  
- **Agent B (ui-designer)**: Issues #8, #16 (Authentication UI + Quiz interface components)
- **Agent C (flutter-architect)**: Issues #9, #13 (User Profile + Quiz creation architecture)
- **Agent D (firebase-specialist)**: Issue #10 (Authentication security)
- **Agent E (testing-specialist)**: Comprehensive testing for all above features
- **Agent F (flutter-architect)**: Issue #5 (Multi-platform build setup - can start anytime)

#### **NEXT PHASE: Feature Expansion**
- **Agent A (firebase-specialist)**: Issue #14 (Game sessions) - after #13 complete
- **Agent B (firebase-specialist)**: Issue #15 (Leaderboard) - after #14 starts  
- **Agent C (flutter-architect)**: Issue #21 (Production deployment) - after #5 complete

#### **✅ COMPLETED FOUNDATIONS** *(No longer needed)*
- ~~Issues #1, #2, #3, #4, #11, #12, #17, #18, #19, #20~~ ✅ ALL COMPLETED

### **⚠️ Current Dependencies** *(Updated based on completed work)*

#### **✅ Foundation Dependencies - ALL RESOLVED**
- ~~All foundation issues completed~~ ✅ NO BLOCKING DEPENDENCIES

#### **🔥 Current Active Dependencies**
1. **Issue #13** (Quiz creation) → **Issue #14** (Game sessions) → **Issue #15** (Leaderboard)
2. **Issue #5** (Multi-platform build) → **Issue #21** (Production deployment)
3. **Authentication enhancements** (#6-#10) can all be developed in parallel

#### **🚀 NO BLOCKERS FOR IMMEDIATE START**
- Issues #5, #6, #7, #8, #9, #10, #13, #16 can ALL start immediately
- Multiple agents can work in parallel without dependencies
- Foundation work eliminates previous sequential requirements

### **🎯 Optimal Development Strategy**

#### **Week-by-Week Agent Assignment**

**Week 1: Foundation Setup**
- **flutter-architect**: #2 (Core Architecture) 
- **firebase-specialist**: #4 (Database Schema) - depends on #11 ✅
- **testing-specialist**: #17 (Testing Framework)

**Week 2: Infrastructure Completion**
- **flutter-architect**: #18 (Code Structure) - depends on #2
- **firebase-specialist**: #1 (Firebase Integration) - depends on #4
- **general-purpose**: #19, #20 (Navigation & Error Handling) - can be parallel

**Week 3: Authentication Foundation**
- **firebase-specialist**: #6 (Auth Domain)
- **flutter-architect**: #3 (CI/CD Pipeline) - parallel work
- **ui-designer**: Start #16 planning (UI research)

**Week 4: Authentication Implementation**
- **firebase-specialist**: #7 (Auth Data) - depends on #6
- **ui-designer**: #8 (Auth UI) - can start after #6
- **firebase-specialist**: #9, #10 (Profile & Security) - parallel with #8

**Week 5: Authentication Integration + Quiz Start**
- **firebase-specialist**: #12 (Auth Integration) - depends on #7,8,9,10
- **ui-designer**: #13 (Quiz Creation) - can start after auth domain (#6)
- **flutter-architect**: #5 (Build Setup) - parallel work

**Weeks 6-8: Core Features (High Parallelization)**
- **firebase-specialist**: #14 (Game Sessions) - depends on #13
- **ui-designer**: #16 (UI Components) - can work parallel
- **firebase-specialist**: #15 (Leaderboard) - starts after #14 begins
- **flutter-architect**: Complete #5 (Build Setup)

**Weeks 9-10: Production & Polish**
- **general-purpose**: #21 (Production Deployment) - depends on #5
- **code-reviewer**: Final review of all implementations
- **performance-optimizer**: Performance tuning across all features

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
    echo "❌ Cloud Functions are NOT supported - Using FREE tier only"
    echo "💡 Implement business logic in Flutter app instead"
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