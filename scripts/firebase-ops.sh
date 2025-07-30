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
    echo "💡 Implement all business logic in Flutter app instead"
    echo "📚 See CLAUDE.md for free tier implementation guidelines"
    ;;
  "hosting")
    echo "🌐 Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    ;;
  "init")
    echo "🔧 Initializing Firebase project..."
    firebase init
    ;;
  "login")
    echo "🔑 Logging into Firebase..."
    firebase login
    ;;
  "projects")
    echo "📋 Listing Firebase projects..."
    firebase projects:list
    ;;
  "use")
    if [ $# -eq 1 ]; then
      echo "Usage: ./firebase-ops.sh use <project-id>"
      exit 1
    fi
    echo "🎯 Switching to Firebase project: $2"
    firebase use $2
    ;;
  *)
    echo "🔥 Firebase Operations Helper"
    echo ""
    echo "Usage: ./firebase-ops.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Start Firebase emulators"
    echo "  deploy    - Deploy everything to Firebase"
    echo "  rules     - Deploy Firestore security rules only"
    echo "  functions - NOT SUPPORTED (Free tier only - use Flutter app logic)"
    echo "  hosting   - Deploy to Firebase Hosting only"
    echo "  init      - Initialize Firebase project"
    echo "  login     - Login to Firebase"
    echo "  projects  - List available Firebase projects"
    echo "  use       - Switch to specific Firebase project"
    echo ""
    echo "Examples:"
    echo "  ./firebase-ops.sh start"
    echo "  ./firebase-ops.sh deploy"
    echo "  ./firebase-ops.sh use quiz-app-dev"
    ;;
esac