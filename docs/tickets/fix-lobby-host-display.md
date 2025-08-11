# Issue: Fix Lobby Host Display and Player Status

## Progress Tracking
- [x] Analyze current implementation issues 
- [x] Fix LobbyPlayerList host identification
- [x] Add player readiness update mechanism  
- [x] Update lobby screen to show host properly
- [x] Test host identification and player status
- [x] Platform verification

## Issues Identified
1. Host badge shows for index 0, not actual hostId
2. Player status always "Joining..." - no readiness update 
3. Host name display issues in lobby

## Solution Approach
- Update LobbyPlayerList to use GameSessionEntity.hostId
- Add setPlayerReady method to update isReady status
- Automatically mark players as ready after joining
- Proper host identification in player list