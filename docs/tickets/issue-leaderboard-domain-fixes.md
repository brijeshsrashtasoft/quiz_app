# Issue: Leaderboard Domain & Use Cases (40 critical errors)

## Progress Tracking
- [x] Fix repository interface Result pattern - completed
- [x] Fix GetLeaderboard use case - completed  
- [x] Fix GetHistoricalLeaderboard use case - completed
- [x] Fix UpdateRank use case - completed
- [x] Fix WatchLeaderboard use case - completed
- [x] Fix CalculateScore constructor - completed
- [x] Verify domain layer builds - completed

## Results
- Issues reduced from 319 → 203 (116 issues fixed)
- All leaderboard domain layer errors resolved
- Repository interface now uses Result<T> pattern
- Use cases properly implement BaseUseCase pattern
- Stream use case correctly returns Stream<Result<T>>

## Errors Fixed
- Repository uses Either<Failure, T> instead of Result<T> ✅
- Use cases return Either but expect Result ✅
- WatchLeaderboard returns wrong Stream type ✅
- Constructor issues with const in use cases ✅

## Agent: flutter-architect-A3