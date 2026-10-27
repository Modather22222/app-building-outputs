import 'package:flutter/material.dart';

/// A unit that can convert to and from its category's base unit.
class Unit {
  const Unit(this.name, {required this.toBase, required this.fromBase});

  final String name;
  final double Function(double value) toBase;
  final double Function(double base) fromBase;

  double convertTo(Unit target, double value) =>
      target.fromBase(toBase(value));
}

/// A conversion category shown as one tab.
class Category {
  const Category(this.label, this.icon, this.units);

  final String label;
  final IconData icon;
  final List<Unit> units;
}

double _identity(double v) => v;

// Length base: meter
double _mmToM(double v) => v / 1000;
double _mToMm(double v) => v * 1000;

final List<Unit> lengthUnits = [
  Unit('Millimeter', toBase: _mmToM, fromBase: _mToMm),
  Unit('Centimeter', toBase: (v) => v / 100, fromBase: (v) => v * 100),
  Unit('Meter', toBase: _identity, fromBase: _identity),
  Unit('Kilometer', toBase: (v) => v * 1000, fromBase: (v) => v / 1000),
  Unit('Inch', toBase: (v) => v * 0.0254, fromBase: (v) => v / 0.0254),
  Unit('Foot', toBase: (v) => v * 0.3048, fromBase: (v) => v / 0.3048),
  Unit('Yard', toBase: (v) => v * 0.9144, fromBase: (v) => v / 0.9144),
  Unit('Mile', toBase: (v) => v * 1609.344, fromBase: (v) => v / 1609.344),
];

// Weight base: kilogram
final List<Unit> weightUnits = [
  Unit('Gram', toBase: (v) => v / 1000, fromBase: (v) => v * 1000),
  Unit('Kilogram', toBase: _identity, fromBase: _identity),
  Unit('Ounce', toBase: (v) => v * 0.028349523125, fromBase: (v) => v / 0.028349523125),
  Unit('Pound', toBase: (v) => v * 0.45359237, fromBase: (v) => v / 0.45359237),
  Unit('Stone', toBase: (v) => v * 6.35029318, fromBase: (v) => v / 6.35029318),
  Unit('Metric ton', toBase: (v) => v * 1000, fromBase: (v) => v / 1000),
];

// Temperature base: Celsius
final List<Unit> temperatureUnits = [
  Unit('Celsius', toBase: _identity, fromBase: _identity),
  Unit('Fahrenheit', toBase: (v) => (v - 32) / 1.8, fromBase: (v) => v * 1.8 + 32),
  Unit('Kelvin', toBase: (v) => v - 273.15, fromBase: (v) => v + 273.15),
];

final List<Category> categories = [
  Category('Length', Icons.straighten, lengthUnits),
  Category('Weight', Icons.scale, weightUnits),
  Category('Temperature', Icons.thermostat, temperatureUnits),
];

/// Formats a conversion result without trailing zeros or noise.
String formatResult(double value) {
  if (value.isNaN || value.isInfinite) return '—';
  if (value != 0 && (value.abs() >= 1e12 || value.abs() < 1e-9)) {
    return value.toStringAsExponential(4);
  }
  var s = value.toStringAsFixed(6);
  s = s.replaceAll(RegExp(r'0+$'), '');
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}
