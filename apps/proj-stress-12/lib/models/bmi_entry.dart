/// Core domain model for the BMI Coach app.
///
/// Contains the [BmiEntry] value type plus WHO-style BMI classification and
/// healthy-range helpers. Pure Dart logic; no Flutter state lives here.
library;

import 'package:flutter/material.dart' show Color, Colors;

/// A single BMI measurement taken at [timestamp].
class BmiEntry {
  BmiEntry({
    required this.timestamp,
    required this.heightCm,
    required this.weightKg,
  });

  /// When the measurement was taken.
  final DateTime timestamp;

  /// Height in centimeters (50-250).
  final double heightCm;

  /// Weight in kilograms (10-400).
  final double weightKg;

  double get _squareMeters {
    final double meters = heightCm / 100;
    return meters * meters;
  }

  /// Classic BMI = kg / m^2.
  double get bmi => weightKg / _squareMeters;

  /// Lower bound of the healthy weight span for this entry's height (18.5 BMI).
  double get healthyMinWeightKg => 18.5 * _squareMeters;

  /// Upper bound of the healthy weight span for this entry's height (24.9 BMI).
  double get healthyMaxWeightKg => 24.9 * _squareMeters;

  /// Where this BMI falls on the standard scale.
  BmiCategory get category => BmiCategory.fromBmi(bmi);
}

/// WHO-style BMI buckets with a label, color and coaching advice each.
enum BmiCategory {
  underweight,
  healthy,
  overweight,
  obese;

  static BmiCategory fromBmi(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25) return BmiCategory.healthy;
    if (bmi < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  String get label => switch (this) {
        BmiCategory.underweight => 'Underweight',
        BmiCategory.healthy => 'Healthy',
        BmiCategory.overweight => 'Overweight',
        BmiCategory.obese => 'Obese',
      };

  Color get color => switch (this) {
        BmiCategory.underweight => Colors.lightBlue,
        BmiCategory.healthy => Colors.green,
        BmiCategory.overweight => Colors.orange,
        BmiCategory.obese => Colors.red,
      };

  String get advice => switch (this) {
        BmiCategory.underweight =>
          'You are below the healthy range. Add nutrient-dense meals and strength training to gain weight gradually.',
        BmiCategory.healthy =>
          'You are in the healthy range. Keep up regular activity and balanced meals to stay here.',
        BmiCategory.overweight =>
          'You are a little above the healthy range. A modest calorie deficit and daily walks make a big difference.',
        BmiCategory.obese =>
          'You are well above the healthy range. Small, sustainable habits add up — consider talking to a clinician.',
      };
}
