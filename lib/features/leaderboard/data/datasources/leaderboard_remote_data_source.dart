import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/score_model.dart';

abstract class LeaderboardRemoteDataSource {
  Stream<LeaderboardModel> watchLeaderboard(String sessionId);
  Future<void> updateScore(String sessionId, ScoreModel score);
  Future<LeaderboardModel> getLeaderboard(String sessionId);
  Future<List<LeaderboardEntryModel>> getHistoricalLeaderboard({
    required String quizId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<LeaderboardEntryModel> getPlayerStats({
    required String playerId,
    required String sessionId,
  });
  Future<void> recordFinalLeaderboard(LeaderboardModel leaderboard);
  Future<List<LeaderboardModel>> getPlayerHistory(String playerId);
  Future<void> clearLeaderboard(String sessionId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore firestore;

  static const String leaderboardsCollection = 'leaderboards';
  static const String scoresCollection = 'scores';
  static const String historicalLeaderboardsCollection =
      'historical_leaderboards';

  const LeaderboardRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<LeaderboardModel> watchLeaderboard(String sessionId) {
    return firestore
        .collection(leaderboardsCollection)
        .doc(sessionId)
        .collection(scoresCollection)
        .orderBy('totalScore', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final entries = <LeaderboardEntryModel>[];
          int rank = 1;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            entries.add(
              LeaderboardEntryModel.fromJson({
                ...data,
                'rank': rank++,
                'playerId': doc.id,
              }),
            );
          }

          final sessionDoc = await firestore
              .collection('game_sessions')
              .doc(sessionId)
              .get();

          final quizId = sessionDoc.data()?['quizId'] ?? '';

          return LeaderboardModel(
            sessionId: sessionId,
            quizId: quizId,
            entries: entries,
            lastUpdated: DateTime.now(),
            type: 'live',
            totalPlayers: entries.length,
          );
        });
  }

  @override
  Future<void> updateScore(String sessionId, ScoreModel score) async {
    final docRef = firestore
        .collection(leaderboardsCollection)
        .doc(sessionId)
        .collection(scoresCollection)
        .doc(score.playerId);

    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (doc.exists) {
        final currentData = doc.data()!;
        final currentScore = currentData['totalScore'] as int;
        final correctAnswers = currentData['correctAnswers'] as int;
        final totalQuestions = currentData['totalQuestions'] as int;
        final currentStreak = currentData['currentStreak'] as int;
        final maxStreak = currentData['maxStreak'] as int;
        final responseTimes = List<int>.from(
          currentData['responseTimes'] ?? [],
        );

        responseTimes.add(score.responseTimeMs);
        final avgResponseTime =
            responseTimes.reduce((a, b) => a + b) / responseTimes.length;

        final newStreak = score.isCorrect ? currentStreak + 1 : 0;

        transaction.update(docRef, {
          'totalScore': currentScore + score.totalScore,
          'correctAnswers': correctAnswers + (score.isCorrect ? 1 : 0),
          'totalQuestions': totalQuestions + 1,
          'currentStreak': newStreak,
          'maxStreak': newStreak > maxStreak ? newStreak : maxStreak,
          'averageResponseTime': avgResponseTime,
          'responseTimes': responseTimes,
          'lastUpdated': FieldValue.serverTimestamp(),
          'previousRank': currentData['rank'] ?? 0,
        });
      } else {
        transaction.set(docRef, {
          'playerName': score.playerName,
          'totalScore': score.totalScore,
          'correctAnswers': score.isCorrect ? 1 : 0,
          'totalQuestions': 1,
          'currentStreak': score.isCorrect ? 1 : 0,
          'maxStreak': score.isCorrect ? 1 : 0,
          'averageResponseTime': score.responseTimeMs.toDouble(),
          'responseTimes': [score.responseTimeMs],
          'lastUpdated': FieldValue.serverTimestamp(),
          'previousRank': 0,
          'rank': 0,
        });
      }
    });
  }

  @override
  Future<LeaderboardModel> getLeaderboard(String sessionId) async {
    final snapshot = await firestore
        .collection(leaderboardsCollection)
        .doc(sessionId)
        .collection(scoresCollection)
        .orderBy('totalScore', descending: true)
        .get();

    final entries = <LeaderboardEntryModel>[];
    int rank = 1;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      entries.add(
        LeaderboardEntryModel.fromJson({
          ...data,
          'rank': rank++,
          'playerId': doc.id,
        }),
      );
    }

    final sessionDoc = await firestore
        .collection('game_sessions')
        .doc(sessionId)
        .get();

    final quizId = sessionDoc.data()?['quizId'] ?? '';

    return LeaderboardModel(
      sessionId: sessionId,
      quizId: quizId,
      entries: entries,
      lastUpdated: DateTime.now(),
      type: 'live',
      totalPlayers: entries.length,
    );
  }

  @override
  Future<List<LeaderboardEntryModel>> getHistoricalLeaderboard({
    required String quizId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = firestore
        .collection(historicalLeaderboardsCollection)
        .where('quizId', isEqualTo: quizId)
        .orderBy('totalScore', descending: true);

    if (startDate != null) {
      query = query.where('lastUpdated', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('lastUpdated', isLessThanOrEqualTo: endDate);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return LeaderboardEntryModel.fromJson({...data, 'playerId': doc.id});
    }).toList();
  }

  @override
  Future<LeaderboardEntryModel> getPlayerStats({
    required String playerId,
    required String sessionId,
  }) async {
    final doc = await firestore
        .collection(leaderboardsCollection)
        .doc(sessionId)
        .collection(scoresCollection)
        .doc(playerId)
        .get();

    if (!doc.exists) {
      throw Exception('Player not found in leaderboard');
    }

    final data = doc.data()!;
    return LeaderboardEntryModel.fromJson({...data, 'playerId': playerId});
  }

  @override
  Future<void> recordFinalLeaderboard(LeaderboardModel leaderboard) async {
    final batch = firestore.batch();

    for (final entry in leaderboard.entries) {
      final docRef = firestore
          .collection(historicalLeaderboardsCollection)
          .doc('${leaderboard.sessionId}_${entry.playerId}');

      batch.set(docRef, {
        ...entry.toJson(),
        'sessionId': leaderboard.sessionId,
        'quizId': leaderboard.quizId,
        'finalizedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Future<List<LeaderboardModel>> getPlayerHistory(String playerId) async {
    final snapshot = await firestore
        .collection(historicalLeaderboardsCollection)
        .where('playerId', isEqualTo: playerId)
        .orderBy('finalizedAt', descending: true)
        .limit(20)
        .get();

    final groupedBySession = <String, List<LeaderboardEntryModel>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final sessionId = data['sessionId'] as String;

      if (!groupedBySession.containsKey(sessionId)) {
        groupedBySession[sessionId] = [];
      }

      groupedBySession[sessionId]!.add(LeaderboardEntryModel.fromJson(data));
    }

    return groupedBySession.entries.map((entry) {
      final firstEntry = entry.value.first;
      return LeaderboardModel(
        sessionId: entry.key,
        quizId: firstEntry.toJson()['quizId'] ?? '',
        entries: entry.value,
        lastUpdated: firstEntry.lastUpdated,
        type: 'historical',
        totalPlayers: entry.value.length,
      );
    }).toList();
  }

  @override
  Future<void> clearLeaderboard(String sessionId) async {
    final snapshot = await firestore
        .collection(leaderboardsCollection)
        .doc(sessionId)
        .collection(scoresCollection)
        .get();

    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
