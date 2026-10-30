import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isamus/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isamus/core/audio/audio_haptic_service.dart';
import 'package:isamus/core/network/player_repository.dart';
import 'package:isamus/features/settings/settings_screen.dart';

import 'helpers/audio_haptic_fakes.dart';

class PendingSoundOutput extends FakeSoundOutput {
  final gate = Completer<void>();
  @override
  Future<void> play(String path) async {
    await super.play(path);
    await gate.future;
  }
}

class PendingSoundProfile extends PlayerRepository {
  final save = Completer<void>();
  bool enabled = true;
  @override
  Future<Map<String, dynamic>> profile() async => {'sound_enabled': enabled};
  @override
  Future<void> sound(bool value) async {
    await save.future;
    enabled = value;
  }
}

void main() {
  test(
    'silencieux par défaut ; mute coupe audio, haptiques et effets futurs',
    () async {
      final service = FakeAudioHapticService(enabled: false);
      await service.feedback(GameSounds.deal, impact: HapticImpact.heavy);
      expect(service.output.played, isEmpty);
      expect(service.impacts, isEmpty);
      service.setSoundEnabled(true);
      await service.feedback(GameSounds.cardSlide, impact: HapticImpact.light);
      expect(service.output.played, [GameSounds.cardSlide]);
      expect(service.impacts, [HapticImpact.light]);
      service.setSoundEnabled(false);
      expect(service.output.stops, 1);
      await service.feedback(GameSounds.victory, impact: HapticImpact.heavy);
      expect(service.output.played, [GameSounds.cardSlide]);
      expect(service.impacts, [HapticImpact.light]);
      service.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(service.output.disposed, isTrue);
    },
  );

  test('mute pendant initialisation annule les anciens effets même après réactivation', () async {
    final output = PendingSoundOutput();
    final service = AudioHapticService(output, (_) async {});
    service.setSoundEnabled(true);
    final first = service.playSound('first');
    final queued = service.playSound('stale');
    await Future<void>.delayed(Duration.zero);
    expect(output.played, ['first']);
    service.setSoundEnabled(false);
    expect(output.stops, 1);
    service.setSoundEnabled(true);
    final fresh = service.playSound('fresh');
    output.gate.complete();
    await Future.wait([first, queued, fresh]);
    expect(output.played, ['first', 'fresh']);
    expect(output.stops, 2);
    service.dispose();
  });

  test(
    'dispose annule une lecture encore en file et interdit toute reprise',
    () async {
      final service = FakeAudioHapticService();
      final pending = service.playSound(GameSounds.deal);
      service.dispose();
      service.setSoundEnabled(true);
      await pending;
      await service.impact(HapticImpact.heavy);
      expect(service.output.played, isEmpty);
      expect(service.impacts, isEmpty);
    },
  );

  testWidgets(
    'préférence non chargée, erreur ou valeur absente : aucun effet',
    (tester) async {
      for (final result in [
        <String, dynamic>{},
        {'sound_enabled': false},
        {'sound_enabled': true},
        null,
      ]) {
        final load = Completer<Map<String, dynamic>>();
        final output = FakeSoundOutput();
        final impacts = <HapticImpact>[];
        final container = ProviderContainer(
          overrides: [
            playerProfileProvider.overrideWith((ref) => load.future),
            soundOutputFactoryProvider.overrideWithValue(() => output),
            hapticOutputProvider.overrideWithValue((impact) async {
              impacts.add(impact);
            }),
          ],
        );
        final service = container.read(audioHapticServiceProvider);
        await service.feedback(GameSounds.deal, impact: HapticImpact.heavy);
        expect(output.played, isEmpty);
        expect(impacts, isEmpty);
        if (result == null) {
          load.completeError(StateError('offline'));
        } else {
          load.complete(result);
        }
        await tester.pump();
        await service.feedback(GameSounds.deal, impact: HapticImpact.heavy);
        expect(output.played.length, result?['sound_enabled'] == true ? 1 : 0);
        expect(impacts.length, result?['sound_enabled'] == true ? 1 : 0);
        container.dispose();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'le provider réagit au changement de préférence sans recréer le service',
    (tester) async {
      var enabled = true;
      final output = FakeSoundOutput();
      final container = ProviderContainer(
        overrides: [
          playerProfileProvider.overrideWith(
            (ref) async => {'sound_enabled': enabled},
          ),
          soundOutputFactoryProvider.overrideWithValue(() => output),
          hapticOutputProvider.overrideWithValue((_) async {}),
        ],
      );
      final service = container.read(audioHapticServiceProvider);
      await tester.pump();
      await service.playSound(GameSounds.deal);
      enabled = false;
      container.invalidate(playerProfileProvider);
      await tester.pump();
      expect(
        identical(service, container.read(audioHapticServiceProvider)),
        isTrue,
      );
      expect(service.isSoundEnabled, isFalse);
      await service.playSound(GameSounds.hordago);
      expect(output.played, [GameSounds.deal]);
      expect(output.stops, greaterThanOrEqualTo(1));
      container.dispose();
      await tester.pump();
    },
  );

  testWidgets(
    'les impacts natifs utilisent lightImpact et heavyImpact, jamais en mute',
    (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          soundOutputFactoryProvider.overrideWithValue(FakeSoundOutput.new),
          playerProfileProvider.overrideWith(
            (ref) async => {'sound_enabled': true},
          ),
        ],
      );
      final service = container.read(audioHapticServiceProvider);
      await tester.pump();
      await service.impact(HapticImpact.light);
      await service.impact(HapticImpact.heavy);
      service.setSoundEnabled(false);
      await service.impact(HapticImpact.light);
      expect(calls, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
      container.dispose();
      await tester.pump();
    },
  );

  for (final fail in [false, true]) {
    testWidgets('Réglages : arrêt immédiat pendant sauvegarde, échec=$fail', (
      tester,
    ) async {
      final profile = PendingSoundProfile();
      final output = FakeSoundOutput();
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWithValue(profile),
          soundOutputFactoryProvider.overrideWithValue(() => output),
          hapticOutputProvider.overrideWithValue((_) async {}),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MyApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final service = container.read(audioHapticServiceProvider);
      await service.playSound(GameSounds.deal);
      await tester.tap(find.byKey(const ValueKey('settings-sound-toggle')));
      await tester.pump();
      expect(service.isSoundEnabled, isFalse);
      expect(output.stops, 1);
      await service.playSound(GameSounds.hordago);
      expect(output.played, [GameSounds.deal]);
      if (fail) {
        profile.save.completeError(StateError('offline'));
      } else {
        profile.save.complete();
      }
      await tester.pumpAndSettle();
      expect(service.isSoundEnabled, fail);
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('settings-sound-toggle')),
            )
            .value,
        fail,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump();
    });
  }
}
