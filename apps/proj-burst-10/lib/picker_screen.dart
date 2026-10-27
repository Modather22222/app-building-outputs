import 'package:flutter/material.dart';

import 'palette_controller.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final PaletteController _controller = PaletteController();
  final TextEditingController _hexField = TextEditingController();
  final FocusNode _hexFocus = FocusNode();
  bool _hexError = false;

  @override
  void initState() {
    super.initState();
    _hexField.text = _controller.currentHex;
    _controller.addListener(_syncFieldFromController);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFieldFromController);
    _controller.dispose();
    _hexField.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  /// Keeps the hex field in sync when the color changes from the sliders
  /// or a favorite tap, without fighting the user while they type.
  void _syncFieldFromController() {
    if (_hexFocus.hasFocus) return;
    final String hex = _controller.currentHex;
    if (_hexField.text.toUpperCase() != hex) {
      _hexField.text = hex;
      if (_hexError) setState(() => _hexError = false);
    }
  }

  void _onHexChanged(String value) {
    final Color? parsed = PaletteController.colorFromHex(value);
    setState(() => _hexError = parsed == null);
    if (parsed != null) _controller.setCurrentColor(parsed);
  }

  void _setChannel(int index, double value) {
    final int argb = _controller.currentColor.toARGB32();
    final List<int> rgb = <int>[(argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF];
    rgb[index] = value.round().clamp(0, 255);
    _controller.setCurrentColor(
      Color(0xFF000000 | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2]),
    );
  }

  void _selectColor(Color color) {
    _hexFocus.unfocus();
    _controller.setCurrentColor(color);
  }

  void _saveToFavorites() {
    final bool added = _controller.addCurrentToFavorites();
    final String message = added
        ? 'Saved #${_controller.currentHex} to your palette'
        : '#${_controller.currentHex} is already in your palette';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final Color color = _controller.currentColor;
        final List<Color> favorites = _controller.favorites;
        final Color onPreview =
            color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Color Match'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Save current color',
                icon: const Icon(Icons.favorite_border),
                onPressed: _saveToFavorites,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Preview(color: color, onColor: onPreview),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hexField,
                    focusNode: _hexFocus,
                    onChanged: _onHexChanged,
                    decoration: InputDecoration(
                      prefixText: '#',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                      labelText: 'Hex color',
                      hintText: 'RRGGBB or AARRGGBB',
                      border: const OutlineInputBorder(),
                      errorText: _hexError ? 'Not a valid hex color' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ChannelSlider(
                    label: 'R',
                    color: const Color(0xFFE53935),
                    value: (color.toARGB32() >> 16) & 0xFF,
                    onChanged: (double v) => _setChannel(0, v),
                  ),
                  _ChannelSlider(
                    label: 'G',
                    color: const Color(0xFF43A047),
                    value: (color.toARGB32() >> 8) & 0xFF,
                    onChanged: (double v) => _setChannel(1, v),
                  ),
                  _ChannelSlider(
                    label: 'B',
                    color: const Color(0xFF1E88E5),
                    value: color.toARGB32() & 0xFF,
                    onChanged: (double v) => _setChannel(2, v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _saveToFavorites,
                    icon: const Icon(Icons.favorite),
                    label: const Text('Save to palette'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Favorites (${favorites.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (favorites.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No favorites yet — pick a color and tap the heart.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 96,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _Swatch(
                        color: favorites[index],
                        selected: favorites[index] == color,
                        onTap: () => _selectColor(favorites[index]),
                        onRemove: () => _controller.removeFavorite(favorites[index]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.color, required this.onColor});

  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '#${PaletteController.hexFromColor(color)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const Text('Current color'),
        ],
      ),
    );
  }
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 24,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            max: 255,
            divisions: 255,
            label: '$value',
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70;
    return Tooltip(
      message: '#${PaletteController.hexFromColor(color)}',
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          if (selected)
            Positioned(
              left: 4,
              bottom: 4,
              child: Icon(Icons.check_circle, size: 20, color: iconColor),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Icon(Icons.cancel, size: 20, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
