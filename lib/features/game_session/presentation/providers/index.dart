// Core session providers
export 'session_providers.dart';
export 'game_play_providers.dart';
export 'optimized_session_providers.dart';
export 'game_host_setup_providers.dart';

// Provider groups for specific use cases:
//
// 1. BASIC SESSION MANAGEMENT:
//    - session_providers.dart: Core session CRUD operations
//    - game_host_setup_providers.dart: Host setup and configuration
//
// 2. GAME PLAY MANAGEMENT:
//    - game_play_providers.dart: Game flow and answer submission
//    - Real-time game state with StreamProviders
//
// 3. PERFORMANCE OPTIMIZATION:
//    - optimized_session_providers.dart: Performance-focused providers
