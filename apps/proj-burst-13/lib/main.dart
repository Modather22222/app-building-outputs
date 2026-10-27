import 'package:flutter/material.dart';

import 'package:alarm_pad/pin_screen.dart';

void main() {
  runApp(const AlarmPadApp());
}

class AlarmPadApp extends StatelessWidget {
  const AlarmPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Pad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const PinScreen(),
    );
  }
}
