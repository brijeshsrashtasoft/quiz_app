import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/leaderboard_model.dart';
import '../models/score_model.dart';

class LeaderboardOptimizationService {
  final _scoreUpdateSubject = PublishSubject<ScoreModel>();
  final _leaderboardCache = <String, LeaderboardModel>{};
  final _updateDebouncer = <String, Timer>{};
  
  static const _debounceDuration = Duration(milliseconds: 300);
  static const _batchSize = 10;
  
  Stream<List<ScoreModel>> get batchedScoreUpdates => 
      _scoreUpdateSubject.bufferTime(_debounceDuration);

  void addScoreUpdate(ScoreModel score) {
    _scoreUpdateSubject.add(score);
  }

  LeaderboardModel? getCachedLeaderboard(String sessionId) {
    return _leaderboardCache[sessionId];
  }

  void updateCache(String sessionId, LeaderboardModel leaderboard) {
    _leaderboardCache[sessionId] = leaderboard;
  }

  void debounceLeaderboardUpdate(
    String sessionId,
    VoidCallback updateCallback,
  ) {
    _updateDebouncer[sessionId]?.cancel();
    _updateDebouncer[sessionId] = Timer(_debounceDuration, () {
      updateCallback();
      _updateDebouncer.remove(sessionId);
    });
  }

  List<T> optimizeRankCalculation<T>(
    List<T> entries,
    int Function(T) getScore,
  ) {
    final sorted = List<T>.from(entries)
      ..sort((a, b) => getScore(b).compareTo(getScore(a)));
    
    return sorted;
  }

  bool shouldUpdateUI(
    LeaderboardModel oldLeaderboard,
    LeaderboardModel newLeaderboard,
  ) {
    if (oldLeaderboard.entries.length != newLeaderboard.entries.length) {
      return true;
    }

    for (var i = 0; i < oldLeaderboard.entries.length; i++) {
      final oldEntry = oldLeaderboard.entries[i];
      final newEntry = newLeaderboard.entries.firstWhere(
        (e) => e.playerId == oldEntry.playerId,
        orElse: () => oldEntry,
      );

      if (oldEntry.rank != newEntry.rank ||
          oldEntry.totalScore != newEntry.totalScore) {
        return true;
      }
    }

    return false;
  }

  void clearCache(String sessionId) {
    _leaderboardCache.remove(sessionId);
    _updateDebouncer[sessionId]?.cancel();
    _updateDebouncer.remove(sessionId);
  }

  void dispose() {
    _scoreUpdateSubject.close();
    for (final timer in _updateDebouncer.values) {
      timer.cancel();
    }
    _updateDebouncer.clear();
    _leaderboardCache.clear();
  }
}