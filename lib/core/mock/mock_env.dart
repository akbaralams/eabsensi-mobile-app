import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clock/clock.dart';
import '../../features/auth/data/token_store.dart';

enum LocationScenario { inside, outside, denied, searching }

/// Skenario uji untuk data dummy (panel di `/debug/skenario`).
@immutable
class MockScenario {
  const MockScenario({
    this.offline = false,
    this.tokenRevoked = false,
    this.location = LocationScenario.inside,
    this.requiresPhoto = true,
    this.requiresApproval = true,
  });

  final bool offline;
  final bool tokenRevoked;
  final LocationScenario location;
  final bool requiresPhoto;
  final bool requiresApproval;

  MockScenario copyWith({
    bool? offline,
    bool? tokenRevoked,
    LocationScenario? location,
    bool? requiresPhoto,
    bool? requiresApproval,
  }) => MockScenario(
    offline: offline ?? this.offline,
    tokenRevoked: tokenRevoked ?? this.tokenRevoked,
    location: location ?? this.location,
    requiresPhoto: requiresPhoto ?? this.requiresPhoto,
    requiresApproval: requiresApproval ?? this.requiresApproval,
  );
}

class MockScenarioController extends Notifier<MockScenario> {
  @override
  MockScenario build() => const MockScenario();

  void update(MockScenario Function(MockScenario s) change) =>
      state = change(state);
}

final mockScenarioProvider =
    NotifierProvider<MockScenarioController, MockScenario>(
      MockScenarioController.new,
    );

/// Lingkungan bersama repository mock: penyimpanan token, skenario, jam, latensi.
class MockEnv {
  MockEnv({
    required this.tokens,
    required this.scenario,
    required this.now,
    this.latency = const Duration(milliseconds: 450),
  });

  final TokenStore tokens;
  final MockScenario Function() scenario;
  final DateTime Function() now;
  final Duration latency;

  Future<void> network() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }
}

final mockEnvProvider = Provider<MockEnv>((ref) {
  return MockEnv(
    tokens: ref.watch(tokenStoreProvider),
    scenario: () => ref.read(mockScenarioProvider),
    now: ref.watch(clockProvider),
  );
});
