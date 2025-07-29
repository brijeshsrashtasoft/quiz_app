#!/bin/bash
# develop-feature.sh - Use when starting a new feature

if [ $# -eq 0 ]; then
    echo "Usage: ./develop-feature.sh <issue-number>"
    echo "Example: ./develop-feature.sh 11"
    exit 1
fi

ISSUE_NUMBER=$1

echo "🚀 Starting feature development for issue #$ISSUE_NUMBER"

# 1. Get issue details
echo "📋 Issue details:"
gh issue view $ISSUE_NUMBER

# 2. Create feature branch
echo "🌿 Creating feature branch..."
git checkout development
git pull origin development

# Get issue title for branch name
ISSUE_TITLE=$(gh issue view $ISSUE_NUMBER --json title -q .title | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | cut -c1-20)
BRANCH_NAME="feature/issue-$ISSUE_NUMBER-$ISSUE_TITLE"

git checkout -b $BRANCH_NAME

echo "✅ Created branch: $BRANCH_NAME"
echo ""
echo "🤖 Ready for implementation!"
echo "   Use this command: /project:implement-issue $ISSUE_NUMBER"
echo ""
echo "📚 Or brainstorm first: /project:brainstorm-feature 'issue requirements'"