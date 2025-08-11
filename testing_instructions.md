# Manual Testing Instructions for Phase 2C

## Overview
The Flutter app is running at **Chrome browser** (launched via `flutter run -d chrome`)

## Test Execution Plan

### Step 1: Initial Setup
1. Open 3 separate Chrome browser windows/tabs
2. Navigate each to the running app URL
3. Prepare to test with 3 different users concurrently

### Step 2: Host User Testing (brijesh@yopmail.com)
**Tab 1 - Host Account**

1. **Sign In**
   - Email: `brijesh@yopmail.com`
   - Password: `Brijesh@123`
   - ✅ Verify: Successful authentication
   - ✅ Verify: Navigate to home dashboard

2. **Create Quiz** (if none exists)
   - Click "Create Quiz" button
   - Fill in quiz details:
     - Title: "Integration Test Quiz"
     - Description: "Test quiz for Phase 2C validation"
     - Add 3-5 questions with multiple choice answers
     - Mark correct answers for each question
   - Save and publish quiz
   - ✅ Verify: Quiz saves to Firestore
   - ✅ Verify: Quiz appears in user's quiz list

3. **Host Game Session**
   - Select the created quiz to host
   - Click "Host Game" button
   - ✅ Verify: 6-digit PIN generates and displays
   - ✅ Verify: Lobby screen shows "Waiting for players"
   - ✅ Verify: Player count shows "0 players joined"
   - Keep this window open and note the PIN

### Step 3: Player 1 Testing (ayushi@yopmail.com)
**Tab 2 - Player 1 Account**

1. **Sign In**
   - Email: `ayushi@yopmail.com`
   - Password: `Ayushi@123`
   - ✅ Verify: Successful authentication

2. **Join Game**
   - Click "Join Game" button
   - Enter the PIN from Host's screen
   - Enter nickname: "Ayushi"
   - ✅ Verify: Successfully joins game session
   - ✅ Verify: Player lobby shows "Waiting for host to start"
   - ✅ Verify: Host's screen updates to show "1 player joined"

### Step 4: Player 2 Testing (pankaj@yopmail.com)
**Tab 3 - Player 2 Account**

1. **Sign In**
   - Email: `pankaj@yopmail.com`
   - Password: `Pankaj!@#123`
   - ✅ Verify: Successful authentication

2. **Join Game**
   - Click "Join Game" button
   - Enter the same PIN
   - Enter nickname: "Pankaj"
   - ✅ Verify: Successfully joins game session
   - ✅ Verify: Player lobby shows "Waiting for host to start"
   - ✅ Verify: Host's screen updates to show "2 players joined"
   - ✅ Verify: Both players see each other in lobby

### Step 5: Game Play Testing
**Multi-tab Coordination Required**

1. **Host Starts Game** (Tab 1)
   - Click "Start Game" button
   - ✅ Verify: Game begins for all players simultaneously

2. **Question Synchronization Test**
   - ✅ Verify: All 3 tabs show same question at same time
   - ✅ Verify: Question timer synchronizes across all tabs
   - ✅ Verify: Question counter shows same progress (e.g., "Question 1 of 5")

3. **Answer Submission Test**
   - **Player 1** (Tab 2): Select answer A, submit quickly
   - **Player 2** (Tab 3): Select answer B, submit after delay
   - **Host** (Tab 1): Monitor answer collection
   - ✅ Verify: Host sees both players' answers in real-time
   - ✅ Verify: Answer submission timestamps recorded

4. **Scoring Verification**
   - ✅ Verify: Points calculated based on correctness and speed
   - ✅ Verify: Live leaderboard updates after each question
   - ✅ Verify: Score calculations are accurate

5. **Question Progression**
   - ✅ Verify: All players advance to next question simultaneously
   - ✅ Verify: Previous answers cannot be changed
   - ✅ Verify: Timer resets for each new question

6. **Game Completion**
   - Complete all questions in the quiz
   - ✅ Verify: Final results screen appears for all players
   - ✅ Verify: Final leaderboard shows correct rankings
   - ✅ Verify: Individual scores match expected calculations

### Step 6: Data Persistence Verification
1. **Firestore Validation**
   - Check that game session data is saved
   - Verify player answers are recorded
   - Confirm final scores are persisted
   - Validate session cleanup after completion

### Step 7: Edge Case Testing
1. **Connection Issues**
   - Test player disconnection/reconnection
   - Verify graceful handling of network interruptions
   - Test host disconnection scenarios

2. **Input Validation**
   - Test invalid PIN entry
   - Test duplicate nicknames
   - Test empty form submissions

## Success Criteria
- ✅ All 3 users complete full game session without errors
- ✅ Real-time synchronization works perfectly
- ✅ Scoring calculations are accurate
- ✅ Final leaderboard shows correct rankings
- ✅ All data saves to Firestore properly
- ✅ Performance meets requirements (operations < 30s)
- ✅ No crashes or critical errors during gameplay

## Documentation Requirements
Update the following after testing:
- `test_results.md` - Mark all test scenarios as completed
- `IMPLEMENTATION_ROADMAP.md` - Update Phase 2C testing status to ✅ Complete
- Record any issues found and their resolutions
- Note performance metrics observed during testing

## Expected Timeline
- Setup: 5 minutes
- Host flow testing: 10 minutes  
- Player join testing: 10 minutes
- Complete gameplay: 15 minutes
- Validation and documentation: 10 minutes
- **Total: ~50 minutes comprehensive testing**