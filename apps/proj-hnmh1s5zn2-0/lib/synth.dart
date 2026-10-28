import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Categories shown as filter chips in the UI.
enum SoundCategory { funny, lofi, rain }

/// A single tile on the soundboard.
class Sound {
  const Sound(this.id, this.name, this.category, this.icon);

  final String id;
  final String name;
  final SoundCategory category;
  final IconData icon;
}

const List<Sound> catalog = [
  Sound('boing', 'Boing', SoundCategory.funny, Icons.toys),
  Sound('laser', 'Laser Zap', SoundCategory.funny, Icons.bolt),
  Sound('beep_boop', 'Beep Boop', SoundCategory.funny, Icons.smart_toy),
  Sound('pop', 'Pop', SoundCategory.funny, Icons.bubble_chart),
  Sound('beat_a', 'Lo-Fi Drive', SoundCategory.lofi, Icons.music_note),
  Sound('beat_b', 'Lo-Fi Waltz', SoundCategory.lofi, Icons.piano),
  Sound('chill_chord', 'Chill Chord', SoundCategory.lofi, Icons.graphic_eq),
  Sound('rain', 'Rainfall', SoundCategory.rain, Icons.water_drop),
  Sound('thunder', 'Thunder Roll', SoundCategory.rain, Icons.thunderstorm),
  Sound('brook', 'Forest Brook', SoundCategory.rain, Icons.forest),
];

/// Synthesizes every sound in [catalog] as 16-bit PCM WAV data, entirely in
/// Dart, so the app needs no bundled audio assets and works fully offline.
class SoundSynthesizer {
  SoundSynthesizer({this.sampleRate = 44100});

  final int sampleRate;

  List<int> renderWav(String id) => _encodeWav(render(id));

  Float64List render(String id) {
    final rng = math.Random(11);
    switch (id) {
      case 'boing':
        return _boing();
      case 'laser':
        return _laser();
      case 'beep_boop':
        return _beepBoop();
      case 'pop':
        return _pop();
      case 'beat_a':
        return _beatA(rng);
      case 'beat_b':
        return _beatB(rng);
      case 'chill_chord':
        return _chillChord(rng);
      case 'rain':
        return _rain(rng);
      case 'thunder':
        return _thunder(rng);
      case 'brook':
        return _brook(rng);
      default:
        throw ArgumentError.value(id, 'id', 'Unknown sound');
    }
  }

  // ---------------------------------------------------------------- helpers

  int _samples(double seconds) => (seconds * sampleRate).round();

  double _whitenoise(math.Random rng) => rng.nextDouble() * 2 - 1;

  /// Adds [piece] on top of [buffer] starting at sample index [at].
  void _add(Float64List buffer, Float64List piece, int at, double gain) {
    for (int i = 0; i < piece.length; i++) {
      final j = at + i;
      if (j < 0 || j >= buffer.length) continue;
      buffer[j] += piece[i] * gain;
    }
  }

  /// Adds a tone whose instantaneous frequency [freq] (Hz) and amplitude [amp]
  /// are arbitrary functions of local time in seconds.
  void _tone(
    Float64List buf,
    int start,
    int len,
    double Function(double t) freq,
    double Function(double t) amp,
  ) {
    if (start >= buf.length) return;
    final end = math.min(start + len, buf.length);
    var phase = 0.0;
    for (int i = start; i < end; i++) {
      final t = (i - start) / sampleRate;
      phase += 2 * math.pi * freq(t) / sampleRate;
      buf[i] += amp(t) * math.sin(phase);
    }
  }

  /// One-pole low-pass applied in place; [alpha] in (0,1), smaller = darker.
  void _lowPass(Float64List buffer, double alpha) {
    var y = 0.0;
    for (int i = 0; i < buffer.length; i++) {
      y += alpha * (buffer[i] - y);
      buffer[i] = y;
    }
  }

  /// Bright, band-limited noise (white minus its low-passed copy).
  Float64List _hiss(int n, math.Random rng, {double alpha = 0.25}) {
    final white = Float64List(n);
    for (int i = 0; i < n; i++) {
      white[i] = _whitenoise(rng);
    }
    final low = Float64List.fromList(white);
    _lowPass(low, alpha);
    for (int i = 0; i < n; i++) {
      white[i] -= low[i];
    }
    return white;
  }

  void _crackle(Float64List buf, math.Random rng, {int count = 40}) {
    final len = _samples(0.004);
    for (int k = 0; k < count; k++) {
      final at = rng.nextInt(buf.length);
      for (int i = 0; i < len && at + i < buf.length; i++) {
        buf[at + i] += _whitenoise(rng) * 0.05 * math.exp(-i / sampleRate * 900);
      }
    }
  }

  void _normalize(Float64List buffer, {double peak = 0.9}) {
    var max = 0.0;
    for (final v in buffer) {
      final a = v.abs();
      if (a > max) max = a;
    }
    if (max > 0) {
      final g = peak / max;
      for (int i = 0; i < buffer.length; i++) {
        buffer[i] *= g;
      }
    }
  }

  // ---------------------------------------------------------- funny effects

  Float64List _boing() {
    final n = _samples(1.4);
    final buf = Float64List(n);
    _tone(
      buf,
      0,
      n,
      (t) => (560 * math.exp(-t * 1.6) + 85) * (1 + 0.12 * math.sin(2 * math.pi * 9 * t)),
      (t) => math.exp(-t * 2.4),
    );
    _tone(buf, 0, _samples(0.08), (t) => 70, (t) => 0.5 * math.exp(-t * 30));
    _normalize(buf);
    return buf;
  }

  Float64List _laser() {
    final n = _samples(0.55);
    final buf = Float64List(n);
    _tone(buf, 0, n, (t) => 1900 * math.exp(-t * 7) + 70, (t) => math.exp(-t * 3.5));
    _tone(
      buf,
      _samples(0.25),
      _samples(0.3),
      (t) => 1600 * math.exp(-t * 7) + 70,
      (t) => 0.7 * math.exp(-t * 3.5),
    );
    _normalize(buf);
    return buf;
  }

  Float64List _beepBoop() {
    final n = _samples(0.5);
    final buf = Float64List(n);
    _tone(buf, 0, _samples(0.14), (t) => 960, (t) => math.exp(-math.max(0.0, t - 0.12) * 60));
    _tone(
      buf,
      _samples(0.22),
      _samples(0.14),
      (t) => 720,
      (t) => math.exp(-math.max(0.0, t - 0.12) * 60),
    );
    _tone(buf, _samples(0.44), _samples(0.06), (t) => 1200, (t) => 0.8 * math.exp(-t * 20));
    _normalize(buf);
    return buf;
  }

  Float64List _pop() {
    final n = _samples(0.2);
    final buf = Float64List(n);
    _tone(buf, 0, n, (t) => 850 * math.exp(-t * 22) + 110, (t) => math.exp(-t * 18));
    _normalize(buf);
    return buf;
  }

  // -------------------------------------------------------------- lo-fi kit

  Float64List _kick() {
    final n = _samples(0.38);
    final buf = Float64List(n);
    _tone(buf, 0, n, (t) => 42 + 125 * math.exp(-t * 22), (t) => math.exp(-t * 9));
    return buf;
  }

  Float64List _snare(math.Random rng) {
    final n = _samples(0.28);
    final buf = Float64List(n);
    final hiss = _hiss(n, rng, alpha: 0.35);
    _tone(buf, 0, n, (t) => 195, (t) => 0.5 * math.exp(-t * 28));
    for (int i = 0; i < n; i++) {
      buf[i] += hiss[i] * 0.9 * math.exp(-i / sampleRate * 15);
    }
    return buf;
  }

  Float64List _hat(math.Random rng, {double decay = 40}) {
    final n = _samples(0.12);
    final buf = _hiss(n, rng, alpha: 0.18);
    for (int i = 0; i < n; i++) {
      buf[i] *= math.exp(-i / sampleRate * decay);
    }
    return buf;
  }

  Float64List _bass(double freq) {
    final n = _samples(0.75);
    final buf = Float64List(n);
    _tone(buf, 0, n, (t) => freq, (t) {
      final attack = t < 0.02 ? t / 0.02 : 1.0;
      return attack * math.exp(-math.max(0.0, t - 0.4) * 4) * 0.9;
    });
    for (int i = 0; i < n; i++) {
      buf[i] = math.sin(buf[i] * 1.4);
    }
    return buf;
  }

  Float64List _beatA(math.Random rng) {
    final buf = Float64List(_samples(3.0));
    void hit(double at, Float64List piece, double gain) =>
        _add(buf, piece, _samples(at), gain);
    final kick = _kick();
    final snare = _snare(rng);
    hit(0.0, kick, 1.0);
    hit(1.5, kick, 1.0);
    hit(2.625, kick, 0.8);
    hit(0.75, snare, 0.9);
    hit(2.25, snare, 0.9);
    for (int i = 0; i < 8; i++) {
      hit(0.375 * i, _hat(rng), i.isEven ? 0.35 : 0.2);
    }
    hit(0.0, _bass(98.0), 1.0);
    hit(1.5, _bass(116.54), 0.9);
    hit(2.25, _bass(87.31), 0.9);
    _crackle(buf, rng, count: 30);
    _normalize(buf);
    return buf;
  }

  Float64List _beatB(math.Random rng) {
    final buf = Float64List(_samples(3.2));
    void hit(double at, Float64List piece, double gain) =>
        _add(buf, piece, _samples(at), gain);
    final kick = _kick();
    final snare = _snare(rng);
    hit(0.0, kick, 1.0);
    hit(1.6, kick, 0.9);
    hit(2.4, kick, 0.95);
    hit(0.8, snare, 0.85);
    hit(2.4, snare, 0.85);
    for (int i = 0; i < 8; i++) {
      hit(0.4 * i + (i.isOdd ? 0.06 : 0), _hat(rng), i.isEven ? 0.4 : 0.22);
    }
    hit(0.0, _bass(73.42), 1.0);
    hit(1.6, _bass(87.31), 0.9);
    hit(2.4, _bass(65.41), 0.9);
    _crackle(buf, rng, count: 30);
    _normalize(buf);
    return buf;
  }

  Float64List _chillChord(math.Random rng) {
    final n = _samples(3.2);
    final buf = Float64List(n);
    const freqs = [174.61, 220.0, 261.63, 329.63]; // Fmaj7
    for (final f in freqs) {
      for (final (detune, gain) in [(1.0015, 0.22), (1.0, 0.14)]) {
        _tone(buf, 0, n, (t) => f * detune, (t) {
          final attack = math.min(1.0, t / 0.5);
          return attack * gain * (t < 2.2 ? 1 : math.exp(-(t - 2.2) * 3));
        });
      }
    }
    _crackle(buf, rng, count: 45);
    _normalize(buf, peak: 0.8);
    return buf;
  }

  // ----------------------------------------------------------- ambient rain

  Float64List _rain(math.Random rng) {
    final n = _samples(6.0);
    final buf = Float64List(n);
    for (int i = 0; i < n; i++) {
      buf[i] = _whitenoise(rng) * 0.16;
    }
    _lowPass(buf, 0.35);
    for (int k = 0; k < 110; k++) {
      final at = rng.nextInt(n);
      final len = _samples(0.02 + rng.nextDouble() * 0.03);
      final f = 900 + rng.nextDouble() * 1800;
      final gain = 0.04 + rng.nextDouble() * 0.09;
      _tone(buf, at, len, (t) => f, (t) => gain * math.exp(-t / 0.008));
    }
    _normalize(buf, peak: 0.75);
    return buf;
  }

  Float64List _thunder(math.Random rng) {
    final n = _samples(4.0);
    final buf = Float64List(n);
    var b = 0.0;
    for (int i = 0; i < n; i++) {
      final t = i / sampleRate;
      b = (b + _whitenoise(rng) * 0.02) * 0.995;
      final env = math.min(1.0, t / 0.15) * math.exp(-math.max(0.0, t - 0.5) * 1.1);
      buf[i] = b * 3 * env;
    }
    for (int i = 0; i < _samples(0.15); i++) {
      final t = i / sampleRate;
      buf[i] += _whitenoise(rng) * 0.5 * math.exp(-t * 28);
    }
    _tone(buf, 0, n, (t) => 46 + 8 * math.sin(2 * math.pi * 0.35 * t), (t) {
      final env = math.min(1.0, t / 0.3) * math.exp(-math.max(0.0, t - 0.6) * 1.3);
      return 0.35 * env;
    });
    _normalize(buf, peak: 0.85);
    return buf;
  }

  Float64List _brook(math.Random rng) {
    final n = _samples(5.0);
    final buf = Float64List(n);
    for (int i = 0; i < n; i++) {
      buf[i] = _whitenoise(rng) * 0.3;
    }
    _lowPass(buf, 0.45);
    final drift = Float64List.fromList(buf);
    _lowPass(drift, 0.005);
    for (int i = 0; i < n; i++) {
      buf[i] -= drift[i] * 0.9;
      buf[i] *= 0.75 + 0.25 * math.sin(2 * math.pi * 0.5 * i / sampleRate + 1.0);
    }
    for (int k = 0; k < 26; k++) {
      final at = rng.nextInt(n);
      final len = _samples(0.06 + rng.nextDouble() * 0.08);
      final dur = len / sampleRate;
      final f0 = 260 + rng.nextDouble() * 220;
      final gain = 0.05 + rng.nextDouble() * 0.07;
      _tone(buf, at, len, (t) => f0 + 240 * (t / dur), (t) => gain * math.sin(math.pi * t / dur));
    }
    _normalize(buf, peak: 0.7);
    return buf;
  }

  // ------------------------------------------------------------- wav encoder

  List<int> _encodeWav(Float64List samples) {
    final pcm = Int16List(samples.length);
    for (int i = 0; i < samples.length; i++) {
      final v = samples[i].clamp(-1.0, 1.0).toDouble();
      pcm[i] = (v * 32767).round();
    }
    final data = pcm.buffer.asUint8List();
    final out = BytesBuilder();
    void ascii(String s) => out.add(s.codeUnits);
    void u32(int v) {
      final b = ByteData(4)..setUint32(0, v, Endian.little);
      out.add(b.buffer.asUint8List());
    }

    void u16(int v) {
      final b = ByteData(2)..setUint16(0, v, Endian.little);
      out.add(b.buffer.asUint8List());
    }

    ascii('RIFF');
    u32(36 + data.length);
    ascii('WAVE');
    ascii('fmt ');
    u32(16);
    u16(1); // PCM
    u16(1); // mono
    u32(sampleRate);
    u32(sampleRate * 2);
    u16(2); // block align
    u16(16); // bits per sample
    ascii('data');
    u32(data.length);
    out.add(data);
    return out.toBytes();
  }
}
