import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/features/game_session/domain/entities/game_session_entity.dart';
import 'package:quiz_app/features/game_session/presentation/widgets/lobby_player_list.dart';

void main() {
  group('Lobby Host Display Tests', () {
    late Map<String, PlayerEntity> testPlayers;
    const String hostPlayerId = 'host_123';
    const String playerPlayerId = 'player_456';

    setUp(() {
      final now = DateTime.now();
      testPlayers = {
        hostPlayerId: PlayerEntity(
          name: 'Host Player',
          joinedAt: now,
          isReady: true,
        ),
        playerPlayerId: PlayerEntity(
          name: 'Regular Player',
          joinedAt: now,
          isReady: true,
        ),
      };
    });

    testWidgets('should show HOST badge for correct player', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LobbyPlayerList(
              players: testPlayers,
              hostId: hostPlayerId,
              isCurrentUserHost: false,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for HOST text - should appear exactly once
      expect(find.text('HOST'), findsOneWidget);

      // Verify both player names appear (may be multiple instances due to UI layout)
      expect(find.textContaining('Host Player'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Regular Player'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show Ready status for ready players', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LobbyPlayerList(
              players: testPlayers,
              hostId: hostPlayerId,
              isCurrentUserHost: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show Ready status for both players (at least 2)
      expect(find.text('Ready'), findsAtLeastNWidgets(2));

      // Should not show Joining... status
      expect(find.text('Joining...'), findsNothing);
    });

    testWidgets('should not show HOST badge when hostId is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LobbyPlayerList(
              players: testPlayers,
              hostId: null, // No host specified
              isCurrentUserHost: false,
            ),
          ),
        ),
      );

      // Wait longer for animations and dispose any timers
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should not find HOST badge
      expect(find.text('HOST'), findsNothing);

      // Dispose any remaining timers
      await tester.binding.delayed(const Duration(milliseconds: 100));
    });
  });
}
