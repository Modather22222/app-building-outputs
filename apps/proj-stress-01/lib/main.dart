import 'package:flutter/material.dart';

import 'converter_page.dart';
import 'units.dart';

void main() => runApp(const UnitConverterApp());

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ConverterHome(),
    );
  }
}

class ConverterHome extends StatelessWidget {
  const ConverterHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Converter'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              for (final category in categories)
                Tab(text: category.label, icon: Icon(category.icon)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final category in categories) ConverterPage(category: category),
          ],
        ),
      ),
    );
  }
}
