import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_calculation.freezed.dart';

/// Score calculation entity with multipliers and bonuses
/// Following Clean Architecture principles from CLAUDE.md
@freezed
class ScoreCalculation with _$ScoreCalculation {
  const factory ScoreCalculation({
    required String playerId,
    required int baseScore,
    required double speedMultiplier,
    required double streakMultiplier,
    required double accuracyMultiplier,
    required int speedBonus,
    required int streakBonus,
    required int accuracyBonus,
    required int totalScore,
    required int answerTimeMs,
    required int currentStreak,
    required double accuracy,
  }) = _ScoreCalculation;

  /// Create empty calculation
  factory ScoreCalculation.empty(String playerId) {
    return ScoreCalculation(
      playerId: playerId,
      baseScore: 0,
      speedMultiplier: 1.0,
      streakMultiplier: 1.0,
      accuracyMultiplier: 1.0,
      speedBonus: 0,
      streakBonus: 0,
      accuracyBonus: 0,
      totalScore: 0,
      answerTimeMs: 0,
      currentStreak: 0,
      accuracy: 0.0,
    );
  }

  /// Create from map
  factory ScoreCalculation.fromMap(Map<String, dynamic> map) {
    return ScoreCalculation(
      playerId: map['playerId'] ?? '',
      baseScore: map['baseScore'] ?? 0,
      speedMultiplier: (map['speedMultiplier'] ?? 1.0).toDouble(),
      streakMultiplier: (map['streakMultiplier'] ?? 1.0).toDouble(),
      accuracyMultiplier: (map['accuracyMultiplier'] ?? 1.0).toDouble(),
      speedBonus: map['speedBonus'] ?? 0,
      streakBonus: map['streakBonus'] ?? 0,
      accuracyBonus: map['accuracyBonus'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      answerTimeMs: map['answerTimeMs'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
    );
  }
}

/// Score calculation configuration
@freezed
class ScoreConfig with _$ScoreConfig {
  const factory ScoreConfig({
    /// Base score for correct answer
    @Default(1000) int baseScoreCorrect,
    
    /// Speed bonus thresholds (in milliseconds)
    @Default(3000) int speedBonusThreshold1,  // < 3 seconds
    @Default(5000) int speedBonusThreshold2,  // < 5 seconds
    @Default(10000) int speedBonusThreshold3, // < 10 seconds
    
    /// Speed multipliers
    @Default(2.0) double speedMultiplier1,     // < 3 seconds
    @Default(1.5) double speedMultiplier2,     // < 5 seconds
    @Default(1.2) double speedMultiplier3,     // < 10 seconds
    
    /// Streak multipliers
    @Default(1.1) double streakMultiplier3,    // 3+ correct
    @Default(1.25) double streakMultiplier5,   // 5+ correct
    @Default(1.5) double streakMultiplier10,   // 10+ correct
    @Default(2.0) double streakMultiplier20,   // 20+ correct
    
    /// Accuracy multipliers
    @Default(1.1) double accuracyMultiplier80, // 80%+ accuracy
    @Default(1.25) double accuracyMultiplier90, // 90%+ accuracy
    @Default(1.5) double accuracyMultiplier100, // 100% accuracy
    
    /// Bonus points
    @Default(100) int speedBonus1,
    @Default(50) int speedBonus2,
    @Default(25) int speedBonus3,
    @Default(50) int streakBonus3,
    @Default(100) int streakBonus5,
    @Default(200) int streakBonus10,
    @Default(500) int streakBonus20,
    @Default(100) int accuracyBonus80,
    @Default(200) int accuracyBonus90,
    @Default(500) int accuracyBonus100,
  }) = _ScoreConfig;

  /// Default configuration
  factory ScoreConfig.defaultConfig() => const ScoreConfig();

  /// Competitive configuration (higher multipliers)
  factory ScoreConfig.competitive() {
    return const ScoreConfig(
      baseScoreCorrect: 1000,
      speedMultiplier1: 3.0,
      speedMultiplier2: 2.0,
      speedMultiplier3: 1.5,
      streakMultiplier3: 1.2,
      streakMultiplier5: 1.5,
      streakMultiplier10: 2.0,
      streakMultiplier20: 3.0,
    );
  }

  /// Casual configuration (lower multipliers)
  factory ScoreConfig.casual() {
    return const ScoreConfig(
      baseScoreCorrect: 1000,
      speedMultiplier1: 1.5,
      speedMultiplier2: 1.2,
      speedMultiplier3: 1.1,
      streakMultiplier3: 1.05,
      streakMultiplier5: 1.1,
      streakMultiplier10: 1.2,
      streakMultiplier20: 1.5,
    );
  }
}

/// Score calculation extensions
extension ScoreCalculationX on ScoreCalculation {
  /// Check if calculation is valid
  bool get isValid {
    return playerId.isNotEmpty &&
        baseScore >= 0 &&
        totalScore >= 0 &&
        speedMultiplier >= 1.0 &&
        streakMultiplier >= 1.0 &&
        accuracyMultiplier >= 1.0 &&
        accuracy >= 0 && accuracy <= 100;
  }

  /// Get total multiplier
  double get totalMultiplier => 
      speedMultiplier * streakMultiplier * accuracyMultiplier;

  /// Get total bonus
  int get totalBonus => speedBonus + streakBonus + accuracyBonus;

  /// Check if perfect speed (answered in < 3 seconds)
  bool get isPerfectSpeed => answerTimeMs < 3000;

  /// Check if has streak
  bool get hasStreak => currentStreak >= 3;

  /// Check if high accuracy
  bool get hasHighAccuracy => accuracy >= 80;

  /// Get performance rating
  PerformanceRating get performanceRating {
    if (totalMultiplier >= 3.0) return PerformanceRating.legendary;
    if (totalMultiplier >= 2.0) return PerformanceRating.excellent;
    if (totalMultiplier >= 1.5) return PerformanceRating.good;
    if (totalMultiplier >= 1.2) return PerformanceRating.fair;
    return PerformanceRating.normal;
  }
}

/// Performance rating based on multipliers
enum PerformanceRating {
  normal,
  fair,
  good,
  excellent,
  legendary;

  String get displayName {
    switch (this) {
      case PerformanceRating.normal:
        return 'Normal';
      case PerformanceRating.fair:
        return 'Fair';
      case PerformanceRating.good:
        return 'Good';
      case PerformanceRating.excellent:
        return 'Excellent';
      case PerformanceRating.legendary:
        return 'Legendary';
    }
  }

  String get emoji {
    switch (this) {
      case PerformanceRating.normal:
        return '👍';
      case PerformanceRating.fair:
        return '⭐';
      case PerformanceRating.good:
        return '🌟';
      case PerformanceRating.excellent:
        return '🏆';
      case PerformanceRating.legendary:
        return '🔥';
    }
  }
}