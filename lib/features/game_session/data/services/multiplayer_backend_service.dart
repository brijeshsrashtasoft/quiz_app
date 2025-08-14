import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';
import '../datasources/game_session_firestore_datasource.dart';
import '../../domain/entities/game_session_entity.dart';
import 'game_state_sync_service.dart';
import 'player_management_service.dart' as player_mgmt;
import 'host_control_service.dart';
import 'answer_collection_service.dart';
import 'pin_lookup_service.dart';

/// Unified multiplayer backend service that coordinates all game session services
/// Provides a single entry point for real-time multiplayer functionality
class MultiplayerBackendService {
  late final GameSessionFirestoreDataSource _dataSource;
  late final GameStateSyncService _syncService;
  late final player_mgmt.PlayerManagementService _playerService;
  late final HostControlService _hostService;
  late final AnswerCollectionService _answerService;
  late final PinLookupService _pinService;

  MultiplayerBackendService() {
    _initializeServices();
  }

  /// Initialize all backend services
  void _initializeServices() {
    _dataSource = GameSessionFirestoreDataSource();
    _syncService = GameStateSyncService(dataSource: _dataSource);
    _playerService = player_mgmt.PlayerManagementService(
      dataSource: _dataSource,
    );
    _answerService = AnswerCollectionService(dataSource: _dataSource);
    _hostService = HostControlService(
      dataSource: _dataSource,
      syncService: _syncService,
    );
    _pinService = PinLookupService();

    AppLogger.firebase('MultiplayerBackendService', 'Initialized all services');
  }

  // =========================================
  // UNIFIED API METHODS
  // =========================================

  /// Create and host a new game session
  Future<Result<GameSessionEntity>> createGameSession({
    required String quizId,
    required String hostId,
    GameSessionSettings? settings,
  }) async {
    return await _hostService.createGameSession(
      quizId: quizId,
      hostId: hostId,
      settings: settings,
    );
  }

  /// Join game session using PIN
  Future<Result<GameSessionEntity>> joinGameByPin({
    required String pin,
    required String playerId,
    required String playerName,
  }) async {
    return await _playerService.joinSessionWithPin(
      pin: pin,
      playerId: playerId,
      playerName: playerName,
    );
  }

  /// Start game session
  Future<Result<GameSessionEntity>> startGame({
    required String sessionId,
    required String hostId,
    int minPlayers = 1,
  }) async {
    return await _hostService.startGameSession(
      sessionId: sessionId,
      hostId: hostId,
      minPlayers: minPlayers,
    );
  }

  /// Submit player answer
  Future<Result<AnswerSubmissionResult>> submitAnswer({
    required String sessionId,
    required String playerId,
    required String playerName,
    required int questionIndex,
    required int selectedOption,
    required bool isCorrect,
    required int responseTimeMs,
    int? pointsEarned,
  }) async {
    return await _answerService.submitAnswer(
      sessionId: sessionId,
      playerId: playerId,
      playerName: playerName,
      questionIndex: questionIndex,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      pointsEarned: pointsEarned,
    );
  }

  /// Validate PIN in real-time
  Future<Result<PinValidationResult>> validatePin(String pin) async {
    return await _pinService.validatePinRealtime(pin);
  }

  // =========================================
  // REAL-TIME STREAMS
  // =========================================

  /// Watch game session for real-time updates
  Stream<Result<GameSessionEntity>> watchGameSession(String sessionId) {
    return _syncService.startSessionSync(sessionId);
  }

  /// Watch player list changes
  Stream<Result<List<player_mgmt.PlayerInfo>>> watchPlayerList(
    String sessionId,
  ) {
    return _playerService.watchPlayerList(sessionId);
  }

  /// Watch game phase updates
  Stream<Result<GamePhaseUpdate>> watchGamePhase(String sessionId) {
    return _syncService.watchGamePhase(sessionId);
  }

  /// Watch live answer statistics
  Stream<Result<LiveAnswerStats>> watchLiveAnswerStats({
    required String sessionId,
    required int questionIndex,
  }) {
    return _answerService.watchLiveAnswerStats(
      sessionId: sessionId,
      questionIndex: questionIndex,
    );
  }

  /// Watch PIN status
  Future<Result<PinValidationResult>> validatePinRealtime(String pin) {
    return _pinService.validatePinRealtime(pin);
  }

  // =========================================
  // SERVICE ACCESS (for advanced usage)
  // =========================================

  GameStateSyncService get syncService => _syncService;
  player_mgmt.PlayerManagementService get playerService => _playerService;
  HostControlService get hostService => _hostService;
  AnswerCollectionService get answerService => _answerService;
  PinLookupService get pinService => _pinService;

  /// Dispose all services and cleanup resources
  void dispose() {
    _syncService.dispose();
    _playerService.dispose();
    _hostService.dispose();
    _answerService.dispose();
    _pinService.dispose();

    AppLogger.firebase('MultiplayerBackendService', 'Disposed all services');
  }
}
