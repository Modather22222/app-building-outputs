import 'dart:async';

import 'package:flutter/material.dart';

import '../format.dart';

class WorldZone {
  const WorldZone({required this.city, required this.offset});

  final String city;
  final Duration offset;
}

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  static const List<WorldZone> _catalog = [
    WorldZone(city: 'New York', offset: Duration(hours: -5)),
    WorldZone(city: 'São Paulo', offset: Duration(hours: -3)),
    WorldZone(city: 'London', offset: Duration.zero),
    WorldZone(city: 'Paris', offset: Duration(hours: 1)),
    WorldZone(city: 'Dubai', offset: Duration(hours: 4)),
    WorldZone(city: 'Mumbai', offset: Duration(hours: 5, minutes: 30)),
    WorldZone(city: 'Singapore', offset: Duration(hours: 8)),
    WorldZone(city: 'Tokyo', offset: Duration(hours: 9)),
    WorldZone(city: 'Sydney', offset: Duration(hours: 10)),
    WorldZone(city: 'Auckland', offset: Duration(hours: 12)),
  ];

  final List<WorldZone> _zones = [
    _catalog[0],
    _catalog[2],
    _catalog[7],
  ];

  late DateTime _nowUtc = DateTime.now().toUtc();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _nowUtc = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _deviceDate => _dateKey(_nowUtc);

  static String _dateKey(DateTime t) =>
      '${t.year}-${t.month}-${t.day}';

  String _dayBadge(DateTime zoneNow) {
    final diff = DateTime.utc(zoneNow.year, zoneNow.month, zoneNow.day)
        .difference(DateTime.utc(
            _nowUtc.year, _nowUtc.month, _nowUtc.day))
        .inDays;
    return switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => diff > 0 ? '+$diff days' : '$diff days',
    };
  }

  void _addZone() {
    final available = _catalog
        .where((z) => !_zones.any((x) => x.city == z.city))
        .toList();
    if (available.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final z in available)
                ListTile(
                  title: Text(z.city),
                  subtitle: Text(offsetLabel(z.offset)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _zones.add(z));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _zones.isEmpty
            ? Center(
                child: Text(
                  'No cities yet. Tap + to add one.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 88),
                itemCount: _zones.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final zone = _zones[i];
                  final zoneNow = _nowUtc.add(zone.offset);
                  final sameDay =
                      _dateKey(zoneNow) == _deviceDate;
                  return Dismissible(
                    key: ValueKey(zone.city),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: scheme.errorContainer,
                      child: Icon(Icons.delete_outline,
                          color: scheme.onErrorContainer),
                    ),
                    onDismissed: (_) {
                      setState(() => _zones.removeAt(i));
                    },
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        zone.city,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(offsetLabel(zone.offset)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            clockText(zoneNow, use24h: false),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            '${meridiem(zoneNow)} · ${_dayBadge(zoneNow)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: sameDay
                                  ? scheme.onSurfaceVariant
                                  : scheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addZone,
        child: const Icon(Icons.add),
      ),
    );
  }
}
