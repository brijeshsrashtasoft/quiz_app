#!/bin/bash

# Auto-Fix Runtime Script
# Monitors app runtime, detects issues, and coordinates automatic fixes

set -e

# Default values
DEVICE_ID=""
MAX_ATTEMPTS=5
LOG_LEVEL="error"
SESSION_ID=$(date +%Y%m%d_%H%M%S)
ISSUES_DIR="docs/runtime-issues"
MONITORING_ACTIVE=true
ISSUE_COUNT=0
FIXED_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --device=*)
            DEVICE_ID="${1#*=}"
            shift
            ;;
        --max-attempts=*)
            MAX_ATTEMPTS="${1#*=}"
            shift
            ;;
        --log-level=*)
            LOG_LEVEL="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to create issue documentation
create_issue_doc() {
    local issue_type=$1
    local description=$2
    local details=$3
    local issue_id="${issue_type}_${SESSION_ID}_$(printf "%03d" $ISSUE_COUNT)"
    local doc_path="${ISSUES_DIR}/${issue_id}.md"
    
    mkdir -p "$ISSUES_DIR"
    
    cat > "$doc_path" << EOF
# Runtime Issue: ${description}

## Issue Details
- **Type**: ${issue_type}
- **Detection Time**: $(date)
- **Device**: ${DEVICE_NAME}
- **Session ID**: ${SESSION_ID}

## Description
${description}

## Stack Trace / Logs
\`\`\`
${details}
\`\`\`

## Resolution Attempts

### Attempt 1
- **Agent**: TBD
- **Changes Made**: TBD
- **Result**: Pending
- **User Feedback**: TBD

## Final Status
- **Resolved**: Pending
- **Total Attempts**: 0
- **Time to Resolution**: TBD

## Lessons Learned
TBD
EOF
    
    echo "$doc_path"
}

# Function to detect device
detect_device() {
    print_color "$BLUE" "\n🔍 Detecting available devices..."
    
    if [ -z "$DEVICE_ID" ]; then
        # Auto-detect first available device
        DEVICE_ID=$(flutter devices --machine | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi
    
    if [ -z "$DEVICE_ID" ]; then
        print_color "$RED" "❌ No devices found! Please connect a device or start an emulator."
        exit 1
    fi
    
    # Get device name
    DEVICE_NAME=$(flutter devices --machine | grep -A2 "\"id\":\"$DEVICE_ID\"" | grep '"name"' | cut -d'"' -f4)
    
    print_color "$GREEN" "✅ Using device: $DEVICE_NAME ($DEVICE_ID)"
}

# Function to launch app with monitoring
launch_app() {
    print_color "$BLUE" "\n🚀 Launching app with runtime monitoring..."
    
    # Create log file for this session
    LOG_FILE="logs/runtime_monitor_${SESSION_ID}.log"
    mkdir -p logs
    
    # Launch Flutter app in background with logging
    flutter run -d "$DEVICE_ID" --verbose 2>&1 | tee "$LOG_FILE" &
    FLUTTER_PID=$!
    
    # Wait for app to start
    sleep 10
    
    print_color "$GREEN" "✅ App launched successfully!"
}

# Function to show monitoring interface
show_interface() {
    clear
    print_color "$PURPLE" "
🚀 APP RUNTIME MONITOR ACTIVE
============================
📱 Device: $DEVICE_NAME
🔍 Monitoring: ${LOG_LEVEL} and above
📊 Session: $SESSION_ID
⌨️  Commands:
   - Type issue description and press Enter to report
   - Type 'status' to see current issues  
   - Type 'quit' to end session

👀 Watching for runtime issues...
"
}

# Function to monitor logs for issues
monitor_logs() {
    local log_file=$1
    local last_line=0
    
    while $MONITORING_ACTIVE; do
        # Check for new log entries
        local current_lines=$(wc -l < "$log_file" 2>/dev/null || echo 0)
        
        if [ $current_lines -gt $last_line ]; then
            # Process new lines
            tail -n +$((last_line + 1)) "$log_file" 2>/dev/null | while IFS= read -r line; do
                # Check for exceptions and errors
                if [[ "$line" =~ (Exception|Error|EXCEPTION|ERROR) ]]; then
                    handle_detected_issue "exception" "Automatic detection: Exception in logs" "$line"
                elif [[ "$line" =~ (RenderFlex.*overflow|OVERFLOW) ]]; then
                    handle_detected_issue "ui_overflow" "RenderFlex overflow detected" "$line"
                elif [[ "$line" =~ (Failed.*assertion|Assertion.*failed) ]]; then
                    handle_detected_issue "assertion" "Assertion failure detected" "$line"
                elif [[ "$LOG_LEVEL" == "warning" ]] && [[ "$line" =~ (Warning|WARNING) ]]; then
                    handle_detected_issue "warning" "Warning detected" "$line"
                fi
            done
            last_line=$current_lines
        fi
        
        sleep 2
    done
}

# Function to handle detected issues
handle_detected_issue() {
    local issue_type=$1
    local description=$2
    local details=$3
    
    ((ISSUE_COUNT++))
    
    print_color "$RED" "\n❌ ISSUE DETECTED:"
    print_color "$YELLOW" "Type: $issue_type"
    print_color "$YELLOW" "Description: $description"
    
    # Create issue documentation
    local doc_path=$(create_issue_doc "$issue_type" "$description" "$details")
    
    print_color "$BLUE" "📝 Created issue report: $doc_path"
    
    # Determine appropriate agent
    local agent=""
    case $issue_type in
        "ui_overflow")
            agent="ui-designer"
            ;;
        "exception"|"assertion")
            agent="test-failure-analyzer"
            ;;
        *)
            agent="flutter-architect"
            ;;
    esac
    
    print_color "$BLUE" "🤖 Assigning to $agent agent..."
    
    # Attempt to fix
    fix_issue "$doc_path" "$agent" "$description"
}

# Function to fix issue with agent
fix_issue() {
    local doc_path=$1
    local agent=$2
    local description=$3
    local attempt=1
    
    while [ $attempt -le $MAX_ATTEMPTS ]; do
        print_color "$YELLOW" "\n🔧 Fix Attempt $attempt/$MAX_ATTEMPTS: Implementing solution..."
        
        # Here we would invoke the actual agent
        # For now, we'll simulate the agent call
        echo "Task(
    description=\"Fix runtime issue\",
    prompt=\"Fix the runtime issue documented in $doc_path
    
    Issue: $description
    Attempt: $attempt of $MAX_ATTEMPTS
    
    Implement the fix and update the documentation.\",
    subagent_type=\"$agent\"
)"
        
        # Simulate fix being applied
        sleep 3
        
        print_color "$GREEN" "♻️  Hot reloading changes..."
        
        # Trigger hot reload
        echo "r" > /proc/$FLUTTER_PID/fd/0 2>/dev/null || true
        
        sleep 2
        
        # Ask user for verification
        print_color "$PURPLE" "\n❓ USER VERIFICATION REQUIRED:"
        print_color "$YELLOW" "Has the issue been resolved? (yes/no/describe): "
        
        read -r user_response
        
        if [[ "$user_response" == "yes" ]]; then
            print_color "$GREEN" "✅ Issue resolved!"
            ((FIXED_COUNT++))
            
            # Update documentation
            echo -e "\n### Resolution\nIssue resolved in attempt $attempt" >> "$doc_path"
            break
        elif [[ "$user_response" == "no" ]]; then
            print_color "$YELLOW" "Issue persists, trying again..."
        else
            print_color "$YELLOW" "Additional feedback: $user_response"
            echo -e "\n### Attempt $attempt Feedback\n$user_response" >> "$doc_path"
        fi
        
        ((attempt++))
    done
    
    if [ $attempt -gt $MAX_ATTEMPTS ]; then
        print_color "$RED" "❌ Unable to resolve after $MAX_ATTEMPTS attempts"
        echo -e "\n### Final Status\nUnresolved after $MAX_ATTEMPTS attempts" >> "$doc_path"
    fi
    
    # Return to monitoring
    show_interface
}

# Function to handle user input
handle_user_input() {
    while $MONITORING_ACTIVE; do
        read -r user_input
        
        case "$user_input" in
            "quit")
                MONITORING_ACTIVE=false
                ;;
            "status")
                print_color "$BLUE" "\n📊 Current Session Status:"
                print_color "$YELLOW" "Issues Detected: $ISSUE_COUNT"
                print_color "$GREEN" "Issues Fixed: $FIXED_COUNT"
                print_color "$RED" "Issues Pending: $((ISSUE_COUNT - FIXED_COUNT))"
                ;;
            "")
                # Empty input, ignore
                ;;
            *)
                # User reporting an issue
                ((ISSUE_COUNT++))
                print_color "$BLUE" "\n📝 Issue reported: $user_input"
                
                # Create issue documentation
                local doc_path=$(create_issue_doc "user_report" "$user_input" "User-reported issue")
                
                # Determine agent based on keywords
                local agent="flutter-architect"
                if [[ "$user_input" =~ (button|tap|click|UI|ui|screen|display) ]]; then
                    agent="ui-designer"
                elif [[ "$user_input" =~ (slow|lag|freeze|performance|memory) ]]; then
                    agent="performance-optimizer"
                elif [[ "$user_input" =~ (firebase|firestore|auth|login|data) ]]; then
                    agent="firebase-specialist"
                fi
                
                print_color "$BLUE" "🤖 Assigning to $agent agent..."
                fix_issue "$doc_path" "$agent" "$user_input"
                ;;
        esac
    done
}

# Function to show final summary
show_summary() {
    local duration=$(($(date +%s) - $(date -d "${SESSION_ID:0:8} ${SESSION_ID:9:2}:${SESSION_ID:11:2}:${SESSION_ID:13:2}" +%s)))
    local minutes=$((duration / 60))
    
    print_color "$PURPLE" "
📊 RUNTIME MONITORING SESSION SUMMARY
====================================

⏱️  Session Duration: $minutes minutes
📱 Device: $DEVICE_NAME
🆔 Session ID: $SESSION_ID

🔍 Issues Detected: $ISSUE_COUNT
✅ Issues Fixed: $FIXED_COUNT
❌ Issues Unresolved: $((ISSUE_COUNT - FIXED_COUNT))

📁 Documentation Created:
"
    
    if [ -d "$ISSUES_DIR" ]; then
        ls -1 "$ISSUES_DIR"/*_${SESSION_ID}_*.md 2>/dev/null || echo "  No issues documented"
    fi
    
    local success_rate=0
    if [ $ISSUE_COUNT -gt 0 ]; then
        success_rate=$((FIXED_COUNT * 100 / ISSUE_COUNT))
    fi
    
    print_color "$GREEN" "\n🎯 Success Rate: ${success_rate}%"
}

# Main execution
main() {
    print_color "$PURPLE" "🚀 Starting Auto-Fix Runtime Monitor..."
    
    # Setup
    detect_device
    launch_app
    show_interface
    
    # Start log monitoring in background
    monitor_logs "$LOG_FILE" &
    MONITOR_PID=$!
    
    # Handle user input in foreground
    handle_user_input
    
    # Cleanup
    kill $MONITOR_PID 2>/dev/null || true
    kill $FLUTTER_PID 2>/dev/null || true
    
    # Show summary
    show_summary
    
    print_color "$GREEN" "\n✅ Runtime monitoring session completed!"
}

# Run main function
main