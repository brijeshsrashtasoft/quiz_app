#!/bin/bash

# Auto Test Executor Script
# Executes Flutter integration tests with intelligent failure analysis

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
TEST_FILE="integration_test/simple_visual_test.dart"
TEST_RESULTS_FILE="test_results.txt"
FAILURE_ANALYSIS_FILE="failure_analysis.json"
AGENT_ASSIGNMENTS_FILE="agent_assignments.json"
MAX_RETRIES=10
CURRENT_RETRY=0

echo -e "${BLUE}🚀 Auto Test Executor Starting...${NC}"

# Function to check emulator status
check_emulator() {
    echo -e "${YELLOW}📱 Checking emulator status...${NC}"
    
    # Check if any Android device is connected
    DEVICES=$(flutter devices | grep "android-arm64" | head -1)
    
    if [[ -n "$DEVICES" ]]; then
        EMULATOR_ID=$(echo "$DEVICES" | awk '{print $4}')
        echo -e "${GREEN}✅ Android emulator found: $EMULATOR_ID${NC}"
        return 0
    else
        echo -e "${RED}❌ No Android emulator detected${NC}"
        return 1
    fi
}

# Function to start emulator if needed
start_emulator() {
    echo -e "${YELLOW}🔄 Starting Android emulator...${NC}"
    
    # Get available emulators
    AVAILABLE_EMULATORS=$(flutter emulators | grep "android" | head -1 | awk '{print $1}')
    
    if [[ -n "$AVAILABLE_EMULATORS" ]]; then
        echo -e "${BLUE}Starting emulator: $AVAILABLE_EMULATORS${NC}"
        flutter emulators --launch "$AVAILABLE_EMULATORS" &
        
        # Wait for emulator to boot
        echo -e "${YELLOW}⏳ Waiting for emulator to boot (30 seconds)...${NC}"
        sleep 30
        
        # Verify emulator is running
        if check_emulator; then
            echo -e "${GREEN}✅ Emulator started successfully${NC}"
            return 0
        else
            echo -e "${RED}❌ Failed to start emulator${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ No Android emulators available${NC}"
        return 1
    fi
}

# Function to execute tests
execute_tests() {
    echo -e "${BLUE}🧪 Executing integration tests...${NC}"
    
    # Clear previous results
    rm -f "$TEST_RESULTS_FILE"
    
    # Run tests with verbose output
    if flutter test "$TEST_FILE" --verbose > "$TEST_RESULTS_FILE" 2>&1; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Tests failed - analyzing failures...${NC}"
        return 1
    fi
}

# Function to analyze test failures
analyze_failures() {
    echo -e "${PURPLE}🔍 Analyzing test failures...${NC}"
    
    if [[ ! -f "$TEST_RESULTS_FILE" ]]; then
        echo -e "${RED}❌ Test results file not found${NC}"
        return 1
    fi
    
    # Initialize failure analysis
    cat > "$FAILURE_ANALYSIS_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "retry_count": $CURRENT_RETRY,
  "failure_categories": {
    "ui_issues": [],
    "navigation_issues": [],
    "firebase_issues": [],
    "performance_issues": [],
    "test_framework_issues": [],
    "build_issues": []
  },
  "total_failures": 0,
  "recommended_agents": []
}
EOF
    
    # Analyze different failure types
    local ui_failures=0
    local nav_failures=0
    local firebase_failures=0
    local perf_failures=0
    local test_failures=0
    local build_failures=0
    
    # UI/Layout issues
    if grep -i "renderflex overflow\|widget constraints\|layout\|overflow" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}🎨 UI/Layout issues detected${NC}"
        ui_failures=$((ui_failures + 1))
        jq '.failure_categories.ui_issues += ["RenderFlex overflow", "Widget constraints", "Layout issues"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Navigation issues
    if grep -i "route not found\|navigator\|navigation\|context" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}🧭 Navigation issues detected${NC}"
        nav_failures=$((nav_failures + 1))
        jq '.failure_categories.navigation_issues += ["Route not found", "Navigator errors", "Context issues"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Firebase issues
    if grep -i "firebase\|authentication\|firestore\|permission denied" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}🔥 Firebase issues detected${NC}"
        firebase_failures=$((firebase_failures + 1))
        jq '.failure_categories.firebase_issues += ["Firebase connection", "Authentication errors", "Firestore issues"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Performance issues
    if grep -i "timeout\|memory\|performance\|slow" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}⚡ Performance issues detected${NC}"
        perf_failures=$((perf_failures + 1))
        jq '.failure_categories.performance_issues += ["Test timeouts", "Memory issues", "Performance problems"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Test framework issues
    if grep -i "test\|mock\|provider\|widget test" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}🧪 Test framework issues detected${NC}"
        test_failures=$((test_failures + 1))
        jq '.failure_categories.test_framework_issues += ["Test setup issues", "Mock failures", "Provider issues"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Build issues
    if grep -i "build\|compile\|dependency\|import" "$TEST_RESULTS_FILE" > /dev/null; then
        echo -e "${YELLOW}🔨 Build issues detected${NC}"
        build_failures=$((build_failures + 1))
        jq '.failure_categories.build_issues += ["Build failures", "Dependency issues", "Import errors"]' "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    fi
    
    # Calculate total failures
    local total_failures=$((ui_failures + nav_failures + firebase_failures + perf_failures + test_failures + build_failures))
    jq ".total_failures = $total_failures" "$FAILURE_ANALYSIS_FILE" > tmp.json && mv tmp.json "$FAILURE_ANALYSIS_FILE"
    
    echo -e "${BLUE}📊 Failure Analysis Summary:${NC}"
    echo -e "  UI Issues: $ui_failures"
    echo -e "  Navigation Issues: $nav_failures"
    echo -e "  Firebase Issues: $firebase_failures"
    echo -e "  Performance Issues: $perf_failures"
    echo -e "  Test Framework Issues: $test_failures"
    echo -e "  Build Issues: $build_failures"
    echo -e "  Total Failures: $total_failures"
    
    return $total_failures
}

# Function to generate agent assignments
generate_agent_assignments() {
    echo -e "${PURPLE}🤖 Generating agent assignments...${NC}"
    
    # Initialize agent assignments
    cat > "$AGENT_ASSIGNMENTS_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "retry_count": $CURRENT_RETRY,
  "parallel_agents": [],
  "priority": "high",
  "execution_strategy": "parallel"
}
EOF
    
    # Add agents based on failure analysis
    if jq -e '.failure_categories.ui_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "ui-designer", "task": "Fix UI/layout issues in integration tests", "priority": "high"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ ui-designer agent assigned${NC}"
    fi
    
    if jq -e '.failure_categories.navigation_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "flutter-architect", "task": "Resolve navigation and architecture issues", "priority": "high"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ flutter-architect agent assigned${NC}"
    fi
    
    if jq -e '.failure_categories.firebase_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "firebase-specialist", "task": "Fix Firebase/backend connectivity issues", "priority": "high"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ firebase-specialist agent assigned${NC}"
    fi
    
    if jq -e '.failure_categories.performance_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "performance-optimizer", "task": "Optimize performance bottlenecks", "priority": "medium"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ performance-optimizer agent assigned${NC}"
    fi
    
    if jq -e '.failure_categories.test_framework_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "test-failure-analyzer", "task": "Resolve test framework and execution issues", "priority": "high"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ test-failure-analyzer agent assigned${NC}"
    fi
    
    if jq -e '.failure_categories.build_issues | length > 0' "$FAILURE_ANALYSIS_FILE" > /dev/null 2>&1; then
        jq '.parallel_agents += [{"agent": "flutter-architect", "task": "Fix build and dependency issues", "priority": "high"}]' "$AGENT_ASSIGNMENTS_FILE" > tmp.json && mv tmp.json "$AGENT_ASSIGNMENTS_FILE"
        echo -e "${GREEN}  ✅ flutter-architect agent assigned for build issues${NC}"
    fi
    
    # Show recommended agents
    local agent_count=$(jq '.parallel_agents | length' "$AGENT_ASSIGNMENTS_FILE")
    echo -e "${BLUE}🎯 Recommended $agent_count agents for parallel deployment${NC}"
}

# Function to display test results summary
display_summary() {
    echo -e "\n${BLUE}📋 Test Execution Summary${NC}"
    echo -e "========================="
    echo -e "Retry Count: $CURRENT_RETRY/$MAX_RETRIES"
    
    if [[ -f "$FAILURE_ANALYSIS_FILE" ]]; then
        local total_failures=$(jq '.total_failures' "$FAILURE_ANALYSIS_FILE")
        echo -e "Total Failures: $total_failures"
    fi
    
    if [[ -f "$AGENT_ASSIGNMENTS_FILE" ]]; then
        local agent_count=$(jq '.parallel_agents | length' "$AGENT_ASSIGNMENTS_FILE")
        echo -e "Agents to Deploy: $agent_count"
        
        if [[ $agent_count -gt 0 ]]; then
            echo -e "\n${PURPLE}🤖 Agent Deployment Plan:${NC}"
            jq -r '.parallel_agents[] | "  - \(.agent): \(.task)"' "$AGENT_ASSIGNMENTS_FILE"
        fi
    fi
    
    echo -e "\n${YELLOW}📁 Generated Files:${NC}"
    echo -e "  - Test Results: $TEST_RESULTS_FILE"
    echo -e "  - Failure Analysis: $FAILURE_ANALYSIS_FILE"
    echo -e "  - Agent Assignments: $AGENT_ASSIGNMENTS_FILE"
}

# Main execution loop
main() {
    echo -e "${BLUE}🎯 Starting Auto Test Execution Pipeline${NC}"
    
    # Check/Start emulator
    if ! check_emulator; then
        if ! start_emulator; then
            echo -e "${RED}💥 Failed to start emulator - aborting${NC}"
            exit 1
        fi
    fi
    
    # Main testing loop
    while [[ $CURRENT_RETRY -lt $MAX_RETRIES ]]; do
        echo -e "\n${BLUE}🔄 Test Iteration: $((CURRENT_RETRY + 1))/$MAX_RETRIES${NC}"
        
        # Execute tests
        if execute_tests; then
            echo -e "${GREEN}🎉 ALL TESTS PASSED! Success achieved!${NC}"
            display_summary
            exit 0
        fi
        
        # Analyze failures
        if analyze_failures; then
            echo -e "${RED}💥 No failures detected but tests failed - investigation needed${NC}"
        fi
        
        # Generate agent assignments
        generate_agent_assignments
        
        # Display summary
        display_summary
        
        # Increment retry counter
        CURRENT_RETRY=$((CURRENT_RETRY + 1))
        
        echo -e "\n${YELLOW}⏳ Waiting for agent resolution before next iteration...${NC}"
        echo -e "${PURPLE}🚨 AGENTS SHOULD BE DEPLOYED NOW to resolve detected issues${NC}"
        
        # In automated mode, this would trigger agent deployment
        # For now, we break to allow manual agent deployment
        echo -e "${RED}🛑 Breaking execution loop - Deploy agents and re-run script${NC}"
        break
    done
    
    if [[ $CURRENT_RETRY -ge $MAX_RETRIES ]]; then
        echo -e "${RED}💥 Maximum retries reached ($MAX_RETRIES) - Test resolution failed${NC}"
        exit 1
    fi
}

# Execute main function
main "$@"