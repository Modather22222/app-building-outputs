import 'package:flutter/material.dart';

import 'soundboard_controller.dart';
import 'synth.dart';

void main() => runApp(const AcousticSoundboardApp());

class AcousticSoundboardApp extends StatelessWidget {
  const AcousticSoundboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C4DFF);
    return MaterialApp(
      title: 'Acoustic Soundboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: const SoundboardPage(),
    );
  }
}

class SoundboardPage extends StatefulWidget {
  const SoundboardPage({super.key});

  @override
  State<SoundboardPage> createState() => _SoundboardPageState();
}

class _SoundboardPageState extends State<SoundboardPage> {
  late final SoundboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SoundboardController()..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acoustic Soundboard'),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => IconButton(
              tooltip: 'Stop',
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: _controller.playingId == null ? null : _controller.stop,
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              if (_controller.error != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    title: Text(
                      _controller.error!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )
              else if (!_controller.ready)
                const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip(context, 'All', null),
                      _chip(context, 'Funny', SoundCategory.funny),
                      _chip(context, 'Lo-Fi', SoundCategory.lofi),
                      _chip(context, 'Rain', SoundCategory.rain),
                    ],
                  ),
                ),
              ),
              Expanded(child: _grid()),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(BuildContext context, String label, SoundCategory? category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _controller.filter == category,
        onSelected: (_) => _controller.setFilter(category),
      ),
    );
  }

  Widget _grid() {
    final sounds = _controller.sounds;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 860 ? 4 : (constraints.maxWidth >= 520 ? 3 : 2);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: sounds.length,
          itemBuilder: (context, index) => _SoundCard(
            sound: sounds[index],
            playing: _controller.playingId == sounds[index].id,
            ready: _controller.ready,
            onTap: () => _controller.play(sounds[index]),
          ),
        );
      },
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.playing,
    required this.ready,
    required this.onTap,
  });

  final Sound sound;
  final bool playing;
  final bool ready;
  final VoidCallback onTap;

  static const _palette = {
    SoundCategory.funny: Color(0xFFFF9800),
    SoundCategory.lofi: Color(0xFF9C27B0),
    SoundCategory.rain: Color(0xFF26A69A),
  };

  static const _labels = {
    SoundCategory.funny: 'Funny effect',
    SoundCategory.lofi: 'Lo-Fi beat',
    SoundCategory.rain: 'Ambient',
  };

  @override
  Widget build(BuildContext context) {
    final color = _palette[sound.category]!;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: playing ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: playing ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withValues(alpha: 0.16),
                child: ready
                    ? Icon(playing ? Icons.volume_up : sound.icon, color: color)
                    : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                sound.name,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                playing ? 'Playing…' : _labels[sound.category]!,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: playing ? color : theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
