import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'synth.dart';

/// In-memory state for the soundboard: synthesizes the WAV files on startup,
/// tracks the currently playing tile, and exposes the category filter.
class SoundboardController extends ChangeNotifier {
  SoundboardController({SoundSynthesizer? synthesizer})
    : _synth = synthesizer ?? SoundSynthesizer();

  final SoundSynthesizer _synth;
  final Map<String, String> _files = {};
  AudioPlayer? _player;

  bool ready = false;
  String? error;
  String? playingId;
  SoundCategory? filter;

  List<Sound> get sounds =>
      catalog.where((s) => filter == null || s.category == filter).toList();

  /// Renders every sound to a temporary WAV file, then marks the board ready.
  Future<void> init() async {
    try {
      final dir = await getTemporaryDirectory();
      for (final sound in catalog) {
        final file = File(
          '${dir.path}${Platform.pathSeparator}acoustic_${sound.id}.wav',
        );
        if (!await file.exists()) {
          await file.writeAsBytes(_synth.renderWav(sound.id), flush: true);
        }
        _files[sound.id] = file.path;
      }
      ready = true;
    } catch (e) {
      error = 'Could not prepare sounds: $e';
    }
    notifyListeners();
  }

  Future<void> play(Sound sound) async {
    final path = _files[sound.id];
    if (path == null) return;
    final player = _player ??= AudioPlayer()
      ..onPlayerComplete.listen((_) {
        if (playingId != null) {
          playingId = null;
          notifyListeners();
        }
      });
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(DeviceFileSource(path));
      playingId = sound.id;
    } catch (e) {
      playingId = null;
      error = 'Playback failed: $e';
    }
    notifyListeners();
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } finally {
      playingId = null;
      notifyListeners();
    }
  }

  void setFilter(SoundCategory? category) {
    filter = category;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
