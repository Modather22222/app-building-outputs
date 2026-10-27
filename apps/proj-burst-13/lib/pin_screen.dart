import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;
  static const String _demoPin = '1234';

  final FocusNode _focusNode = FocusNode();

  String _entry = '';
  bool _dismissed = false;
  bool _error = false;
  bool _submitting = false;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _shake.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_dismissed || _submitting || _entry.length >= _pinLength) return;
    setState(() {
      _entry += digit;
      _error = false;
    });
    if (_entry.length == _pinLength) {
      _submitting = true;
      Future.delayed(const Duration(milliseconds: 250), _checkPin);
    }
  }

  void _checkPin() {
    if (!mounted) return;
    if (_entry == _demoPin) {
      setState(() {
        _dismissed = true;
        _submitting = false;
      });
    } else {
      setState(() => _error = true);
      _shake.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _entry = '';
          _error = false;
          _submitting = false;
        });
      });
    }
  }

  void _onDelete() {
    if (_dismissed || _submitting || _entry.isEmpty) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = false;
    });
  }

  void _clearAll() {
    if (_dismissed || _submitting || _entry.isEmpty) return;
    setState(() {
      _entry = '';
      _error = false;
    });
  }

  void _reset() {
    setState(() {
      _entry = '';
      _dismissed = false;
      _error = false;
      _submitting = false;
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final character = event.character;
    if (character != null && RegExp(r'^\d$').hasMatch(character)) {
      _onDigit(character);
    } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
        event.logicalKey == LogicalKeyboardKey.delete) {
      _onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Icon(
                    _dismissed ? Icons.alarm_off : Icons.alarm,
                    size: 44,
                    color: _dismissed ? Colors.green : scheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _dismissed ? 'Alarm dismissed' : 'Alarm ringing',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _error ? scheme.error : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dismissed
                        ? 'Nothing left to do here.'
                        : 'Enter the demo PIN ($_demoPin) to dismiss',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        _error ? math.sin(_shake.value * 3 * math.pi) * 10 : 0,
                        0,
                      ),
                      child: child,
                    ),
                    child: PinDots(
                      key: const ValueKey('pin_dots'),
                      length: _pinLength,
                      filled: _entry.length,
                      error: _error,
                    ),
                  ),
                  const Spacer(flex: 3),
                  if (_dismissed)
                    FilledButton.icon(
                      key: const ValueKey('ring_again'),
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Ring again'),
                    )
                  else
                    PinPad(
                      onDigit: _onDigit,
                      onDelete: _onDelete,
                      onClearAll: _clearAll,
                      enabled: !_submitting,
                    ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
  });

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = error ? scheme.error : scheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        final color = isFilled ? activeColor : scheme.outlineVariant;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: isFilled ? 20 : 14,
          height: isFilled ? 20 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? activeColor : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        );
      }),
    );
  }
}

class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onClearAll,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClearAll;
  final bool enabled;

  Widget _digit(String digit) {
    return KeyButton(
      key: ValueKey('digit_$digit'),
      label: digit,
      onTap: enabled ? () => onDigit(digit) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> keys) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: keys,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([_digit('1'), _digit('2'), _digit('3')]),
        const SizedBox(height: 14),
        row([_digit('4'), _digit('5'), _digit('6')]),
        const SizedBox(height: 14),
        row([_digit('7'), _digit('8'), _digit('9')]),
        const SizedBox(height: 14),
        row([
          KeyButton(
            key: const ValueKey('biometric'),
            icon: Icons.fingerprint,
            tooltip: 'Biometric unlock is not available in this demo',
          ),
          _digit('0'),
          KeyButton(
            key: const ValueKey('delete'),
            icon: Icons.backspace_outlined,
            tooltip: 'Delete (long-press to clear)',
            onTap: enabled ? onDelete : null,
            onLongPress: enabled ? onClearAll : null,
          ),
        ]),
      ],
    );
  }
}

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    this.label,
    this.icon,
    this.tooltip,
    this.onTap,
    this.onLongPress,
  })  : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Widget button = SizedBox(
      width: 76,
      height: 60,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 26,
                    color: onTap == null ? scheme.outline : scheme.onSurface,
                  )
                : Text(label!, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
