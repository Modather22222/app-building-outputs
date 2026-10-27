import 'package:flutter/material.dart';

/// In-memory state for the picker: the color being edited plus the
/// saved favorites palette.
class PaletteController extends ChangeNotifier {
  static const int maxFavorites = 24;

  Color _currentColor = const Color(0xFF4C6FE7);
  final List<Color> _favorites = <Color>[
    const Color(0xFFE63946),
    const Color(0xFFF4A261),
    const Color(0xFF2A9D8F),
    const Color(0xFF264653),
    const Color(0xFF9B5DE5),
  ];

  Color get currentColor => _currentColor;
  List<Color> get favorites => List<Color>.unmodifiable(_favorites);
  String get currentHex => hexFromColor(_currentColor);

  void setCurrentColor(Color color) {
    if (_currentColor == color) return;
    _currentColor = color;
    notifyListeners();
  }

  /// Adds the current color to the palette. Returns false if it was
  /// already saved. Evicts the oldest entry when the palette is full.
  bool addCurrentToFavorites() {
    if (_favorites.contains(_currentColor)) return false;
    if (_favorites.length >= maxFavorites) _favorites.removeAt(0);
    _favorites.add(_currentColor);
    notifyListeners();
    return true;
  }

  void removeFavorite(Color color) {
    if (_favorites.remove(color)) notifyListeners();
  }

  static String hexFromColor(Color color) {
    final int argb = color.toARGB32();
    return (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  /// Accepts `RRGGBB`, `#RRGGBB`, `0xRRGGBB`, or the same with an alpha
  /// channel (`AARRGGBB`). Returns null for anything else.
  static Color? colorFromHex(String input) {
    String hex = input.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.toLowerCase().startsWith('0x')) hex = hex.substring(2);
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }
}
