import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/game_session_entity.dart';

part 'game_session_model.freezed.dart';
part 'game_session_model.g.dart';

/// Game session model for data layer
/// Following CLAUDE.md patterns and Firestore integration
@freezed
class GameSessionModel with _$GameSessionModel {
  const factory GameSessionModel({
    required String id,
    required String quizId,
    required String hostId,
    required String pin,
    required GameSessionStatus status,
    required Map<String, PlayerModel> players,
    required int currentQuestionIndex,
    required DateTime createdAt,
    GameSessionSettingsModel? settings,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _GameSessionModel;

  /// Create from Firestore document data
  factory GameSessionModel.fromFirestore(Map<String, dynamic> data) {
    return GameSessionModel(
      id: data['id'] as String,
      quizId: data['quizId'] as String,
      hostId: data['hostId'] as String,
      pin: data['pin'] as String,
      status: GameSessionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GameSessionStatus.waiting,
      ),
      players:
          (data['players'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              PlayerModel.fromMap(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      currentQuestionIndex: data['currentQuestionIndex'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      settings: data['settings'] != null
          ? GameSessionSettingsModel.fromMap(
              data['settings'] as Map<String, dynamic>,
            )
          : null,
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create from JSON
  factory GameSessionModel.fromJson(Map<String, dynamic> json) =>
      _$GameSessionModelFromJson(json);
}

/// Player model for data layer
@freezed
class PlayerModel with _$PlayerModel {
  const factory PlayerModel({
    required String name,
    required DateTime joinedAt,
    @Default(0) int score,
    @Default([]) List<int> answers,
    @Default(false) bool isReady,
  }) = _PlayerModel;

  /// Create from Firestore map
  factory PlayerModel.fromMap(Map<String, dynamic> data) {
    return PlayerModel(
      name: data['name'] as String,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      score: data['score'] as int? ?? 0,
      answers: List<int>.from(data['answers'] as List<dynamic>? ?? []),
      isReady: data['isReady'] as bool? ?? false,
    );
  }

  /// Create from JSON
  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}

/// Game session settings model
@freezed
class GameSessionSettingsModel with _$GameSessionSettingsModel {
  const factory GameSessionSettingsModel({
    @Default(50) int maxPlayers,
    @Default(true) bool showCorrectAnswers,
    @Default(false) bool shuffleQuestions,
    @Default(true) bool allowReplay,
  }) = _GameSessionSettingsModel;

  /// Create from Firestore map
  factory GameSessionSettingsModel.fromMap(Map<String, dynamic> data) {
    return GameSessionSettingsModel(
      maxPlayers: data['maxPlayers'] as int? ?? 50,
      showCorrectAnswers: data['showCorrectAnswers'] as bool? ?? true,
      shuffleQuestions: data['shuffleQuestions'] as bool? ?? false,
      allowReplay: data['allowReplay'] as bool? ?? true,
    );
  }

  /// Create from JSON
  factory GameSessionSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$GameSessionSettingsModelFromJson(json);
}

/// Extensions for model conversions
extension GameSessionModelX on GameSessionModel {
  /// Convert to domain entity
  GameSessionEntity toEntity() {
    return GameSessionEntity(
      id: id,
      quizId: quizId,
      hostId: hostId,
      pin: pin,
      status: status,
      players: players.map((key, value) => MapEntry(key, value.toEntity())),
      currentQuestionIndex: currentQuestionIndex,
      createdAt: createdAt,
      settings: settings?.toEntity(),
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'id': id,
      'quizId': quizId,
      'hostId': hostId,
      'pin': pin,
      'status': status.name,
      'players': players.map(
        (key, value) => MapEntry(key, value.toFirestore()),
      ),
      'currentQuestionIndex': currentQuestionIndex,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (settings != null) {
      data['settings'] = settings!.toFirestore();
    }

    if (startedAt != null) {
      data['startedAt'] = Timestamp.fromDate(startedAt!);
    }

    if (completedAt != null) {
      data['completedAt'] = Timestamp.fromDate(completedAt!);
    }

    return data;
  }

  /// Check if session is valid (delegates to entity logic)
  bool get isValid {
    return toEntity().isValid;
  }

  /// Check if session has expired (delegates to entity logic)
  bool get hasExpired {
    return toEntity().hasExpired;
  }

  /// Check if user is host (delegates to entity logic)
  bool isHost(String userId) {
    return toEntity().isHost(userId);
  }

  /// Check if user is player (delegates to entity logic)
  bool isPlayer(String userId) {
    return toEntity().isPlayer(userId);
  }

  /// Check if user can join (delegates to entity logic)
  bool canUserJoin(String userId) {
    return toEntity().canUserJoin(userId);
  }

  /// Get current player count (delegates to entity logic)
  int get playerCount => toEntity().playerCount;

  /// Check if session is full (delegates to entity logic)
  bool get isFull => toEntity().isFull;
}

extension PlayerModelX on PlayerModel {
  /// Convert to domain entity
  PlayerEntity toEntity() {
    return PlayerEntity(
      name: name,
      joinedAt: joinedAt,
      score: score,
      answers: answers,
      isReady: isReady,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'score': score,
      'answers': answers,
      'isReady': isReady,
    };
  }
}

extension GameSessionSettingsModelX on GameSessionSettingsModel {
  /// Convert to domain entity
  GameSessionSettings toEntity() {
    return GameSessionSettings(
      maxPlayers: maxPlayers,
      showCorrectAnswers: showCorrectAnswers,
      shuffleQuestions: shuffleQuestions,
      allowReplay: allowReplay,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'maxPlayers': maxPlayers,
      'showCorrectAnswers': showCorrectAnswers,
      'shuffleQuestions': shuffleQuestions,
      'allowReplay': allowReplay,
    };
  }
}

/// Factory extensions for entity to model conversion
extension GameSessionEntityX on GameSessionEntity {
  /// Convert to data model
  GameSessionModel toModel() {
    return GameSessionModel(
      id: id,
      quizId: quizId,
      hostId: hostId,
      pin: pin,
      status: status,
      players: players.map((key, value) => MapEntry(key, value.toModel())),
      currentQuestionIndex: currentQuestionIndex,
      createdAt: createdAt,
      settings: settings?.toModel(),
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}

extension PlayerEntityX on PlayerEntity {
  /// Convert to data model
  PlayerModel toModel() {
    return PlayerModel(
      name: name,
      joinedAt: joinedAt,
      score: score,
      answers: answers,
      isReady: isReady,
    );
  }
}

extension GameSessionSettingsX on GameSessionSettings {
  /// Convert to data model
  GameSessionSettingsModel toModel() {
    return GameSessionSettingsModel(
      maxPlayers: maxPlayers,
      showCorrectAnswers: showCorrectAnswers,
      shuffleQuestions: shuffleQuestions,
      allowReplay: allowReplay,
    );
  }
}
