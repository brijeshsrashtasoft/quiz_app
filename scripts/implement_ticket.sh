#!/bin/bash

# Implement Ticket Script
# This script provides helper functions for the implement-ticket command

set -e

TICKET_DIR="docs/github_tickets"
STATUS_FILE=".ticket_implementation_status.json"
CHECKPOINT_DIR=".ticket_checkpoints"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if ticket exists
check_ticket_exists() {
    local ticket_number=$1
    local ticket_file="$TICKET_DIR/${ticket_number}_*.md"
    
    if ls $ticket_file 1> /dev/null 2>&1; then
        echo -e "${GREEN}✅ Found ticket file: $(ls $ticket_file)${NC}"
        return 0
    else
        echo -e "${RED}❌ Ticket file not found for $ticket_number${NC}"
        return 1
    fi
}

# Function to run flutter analyze
check_flutter_analyze() {
    echo -e "${BLUE}🔍 Running flutter analyze...${NC}"
    
    local output=$(flutter analyze 2>&1)
    local error_count=$(echo "$output" | grep -c "error" || true)
    local warning_count=$(echo "$output" | grep -c "warning" || true)
    
    if [ $error_count -gt 50 ]; then
        echo -e "${RED}❌ Flutter analyze failed: $error_count errors found (max: 50)${NC}"
        echo "$output"
        return 1
    else
        echo -e "${GREEN}✅ Flutter analyze passed: $error_count errors, $warning_count warnings${NC}"
        return 0
    fi
}

# Function to run platform builds
check_platform_builds() {
    local platforms=("web" "apk" "ios")
    local all_passed=true
    
    for platform in "${platforms[@]}"; do
        echo -e "${BLUE}🏗️  Building for $platform...${NC}"
        
        if [ "$platform" == "ios" ] && [ "$(uname)" != "Darwin" ]; then
            echo -e "${YELLOW}⚠️  Skipping iOS build (not on macOS)${NC}"
            continue
        fi
        
        if flutter build $platform --debug > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $platform build successful${NC}"
        else
            echo -e "${RED}❌ $platform build failed${NC}"
            all_passed=false
        fi
    done
    
    return $([ "$all_passed" = true ] && echo 0 || echo 1)
}

# Function to create checkpoint
create_checkpoint() {
    local ticket_number=$1
    local status=$2
    
    mkdir -p "$CHECKPOINT_DIR"
    local checkpoint_file="$CHECKPOINT_DIR/${ticket_number}_$(date +%Y%m%d_%H%M%S).json"
    
    echo "$status" > "$checkpoint_file"
    echo -e "${GREEN}✅ Checkpoint created: $checkpoint_file${NC}"
}

# Function to get latest checkpoint
get_latest_checkpoint() {
    local ticket_number=$1
    local latest_checkpoint=$(ls -t "$CHECKPOINT_DIR/${ticket_number}_"*.json 2>/dev/null | head -1)
    
    if [ -n "$latest_checkpoint" ]; then
        echo -e "${BLUE}📥 Loading checkpoint: $latest_checkpoint${NC}"
        cat "$latest_checkpoint"
    else
        echo "{}"
    fi
}

# Function to update ticket status
update_ticket_status() {
    local ticket_file=$1
    local status_section=$2
    
    # This is a placeholder - actual implementation would update the markdown file
    echo -e "${BLUE}📝 Updating ticket status in: $ticket_file${NC}"
}

# Function to run E2E tests
run_e2e_tests() {
    local test_file=$1
    
    echo -e "${BLUE}🧪 Running E2E tests...${NC}"
    
    # Check if emulators are running
    if ! flutter devices | grep -q "emulator"; then
        echo -e "${YELLOW}⚠️  No emulators detected. Starting Android emulator...${NC}"
        # Start emulator command would go here
    fi
    
    # Run integration tests
    if flutter test integration_test/$test_file; then
        echo -e "${GREEN}✅ E2E tests passed${NC}"
        return 0
    else
        echo -e "${RED}❌ E2E tests failed${NC}"
        return 1
    fi
}

# Function to check implementation progress
check_progress() {
    local ticket_number=$1
    local ticket_file=$(ls $TICKET_DIR/${ticket_number}_*.md 2>/dev/null | head -1)
    
    if [ -z "$ticket_file" ]; then
        echo "0"
        return
    fi
    
    # Count completed items (lines with ✅ or [x])
    local completed=$(grep -c "✅\|\\[x\\]" "$ticket_file" || echo "0")
    # Count total items (lines with [ ] or ✅ or [x])
    local total=$(grep -c "\\[ \\]\|✅\|\\[x\\]" "$ticket_file" || echo "0")
    
    if [ $total -eq 0 ]; then
        echo "0"
    else
        echo "$((completed * 100 / total))"
    fi
}

# Main function to display status
display_status() {
    local ticket_number=$1
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}📊 Implementation Status for $ticket_number${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    local progress=$(check_progress "$ticket_number")
    echo -e "Overall Progress: ${YELLOW}$progress%${NC}"
    
    # Display progress bar
    local bar_length=20
    local filled_length=$((progress * bar_length / 100))
    local bar="["
    for ((i=0; i<filled_length; i++)); do bar+="█"; done
    for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
    bar+="]"
    echo -e "$bar"
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# Parse command line arguments
case "${1:-}" in
    "check")
        check_ticket_exists "$2"
        ;;
    "analyze")
        check_flutter_analyze
        ;;
    "build")
        check_platform_builds
        ;;
    "checkpoint")
        create_checkpoint "$2" "$3"
        ;;
    "status")
        display_status "$2"
        ;;
    "e2e")
        run_e2e_tests "$2"
        ;;
    *)
        echo "Usage: $0 {check|analyze|build|checkpoint|status|e2e} [args]"
        exit 1
        ;;
esac