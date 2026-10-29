import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/player_repository.dart';

abstract final class GameSounds {
  static const deal = 'assets/audio/deal.wav';
  static const chips = 'assets/audio/chips.wav';
  static const hordago = 'assets/audio/hordago.wav';
  static const victory = 'assets/audio/victory.wav';
  static const cardSlide = 'assets/sounds/card_slide.wav';
  static const tap = 'assets/sounds/tap.wav';
  static const timeout = 'assets/sounds/timeout.wav';
}

enum HapticImpact { light, heavy }

/// Injectable output: tests never need an audio device or a platform plugin.
abstract interface class SoundOutput {
  Future<void> play(String assetPath);
  Future<void> stop();
  Future<void> dispose();
}

class AssetSoundOutput implements SoundOutput {
  AudioPlayer? _player;
  @override
  Future<void> play(String assetPath) async {
    final player = _player ??= AudioPlayer();
    await player.play(
      AssetSource(assetPath.replaceFirst(RegExp(r'^assets/'), '')),
      volume: .5,
    );
  }

  @override
  Future<void> stop() async => _player?.stop();
  @override
  Future<void> dispose() async => _player?.dispose();
}

final soundOutputFactoryProvider = Provider<SoundOutput Function()>(
  (ref) => AssetSoundOutput.new,
);
final hapticOutputProvider = Provider<Future<void> Function(HapticImpact)>(
  (ref) =>
      (impact) => impact == HapticImpact.heavy
      ? HapticFeedback.heavyImpact()
      : HapticFeedback.lightImpact(),
);

final audioHapticServiceProvider = Provider<AudioHapticService>((ref) {
  final service = AudioHapticService(
    ref.read(soundOutputFactoryProvider)(),
    ref.read(hapticOutputProvider),
    () => _enabledPreference(ref.read(playerProfileProvider)),
  );
  // Unknown, loading and failed preferences are silent. Never assume opt-in.
  ref.listen(playerProfileProvider, (_, next) {
    service.setSoundEnabled(_enabledPreference(next));
  }, fireImmediately: true);
  ref.onDispose(service.dispose);
  return service;
});

bool _enabledPreference(AsyncValue<Map<String, dynamic>> profile) =>
    profile is AsyncData<Map<String, dynamic>> &&
    !profile.isLoading &&
    !profile.hasError &&
    profile.value['sound_enabled'] == true;

/// One gate for ALL audio and haptics. No queued effect survives a mute.
class AudioHapticService {
  AudioHapticService(this._output, this._haptic, [this._preferenceEnabled]);
  final bool Function()? _preferenceEnabled;
  final SoundOutput _output;
  final Future<void> Function(HapticImpact) _haptic;
  bool _enabled = false;
  bool _disposed = false;
  int _generation = 0;
  Future<void> _pending = Future.value();
  bool get isSoundEnabled =>
      !_disposed && _enabled && (_preferenceEnabled?.call() ?? true);

  void setSoundEnabled(bool enabled) {
    if (_disposed || _enabled == enabled) return;
    _enabled = enabled;
    _generation++;
    if (!enabled) unawaited(_ignore(_output.stop));
  }

  Future<void> playSound(String assetPath) {
    if (!isSoundEnabled) return Future.value();
    final generation = _generation;
    // Serialize starts (not playback duration), so a late initialization cannot
    // restart an old cue after mute/unmute or race a newer sound's cleanup.
    _pending = _pending.then((_) async {
      if (!isSoundEnabled || generation != _generation) return;
      await _ignore(() => _output.play(assetPath));
      if (!isSoundEnabled || generation != _generation) {
        await _ignore(_output.stop);
      }
    });
    return _pending;
  }

  Future<void> impact(HapticImpact intensity) async {
    if (!isSoundEnabled) return;
    await _ignore(() => _haptic(intensity));
  }

  Future<void> feedback(String assetPath, {HapticImpact? impact}) async {
    await Future.wait([
      playSound(assetPath),
      if (impact != null) this.impact(impact),
    ]);
  }

  Future<void> _ignore(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      /* Feedback must never interrupt a turn. */
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _enabled = false;
    _generation++;
    unawaited(_ignore(_output.stop));
    unawaited(_pending.then((_) => _ignore(_output.dispose)));
  }
}
