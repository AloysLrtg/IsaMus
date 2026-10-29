import 'package:isamus/core/audio/audio_haptic_service.dart';

class FakeSoundOutput implements SoundOutput {
  final played = <String>[];
  int stops = 0;
  bool disposed = false;
  @override
  Future<void> play(String assetPath) async => played.add(assetPath);
  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakeAudioHapticService extends AudioHapticService {
  factory FakeAudioHapticService({bool enabled = true}) =>
      FakeAudioHapticService._(FakeSoundOutput(), [], enabled);
  FakeAudioHapticService._(this.output, this.impacts, bool enabled)
    : super(output, (impact) async {
        impacts.add(impact);
      }) {
    setSoundEnabled(enabled);
  }
  final FakeSoundOutput output;
  final List<HapticImpact> impacts;
}
