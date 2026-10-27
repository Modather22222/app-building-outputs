import 'package:flutter/material.dart';

import 'quiz.dart';

void main() {
  runApp(const UnitQuizApp());
}

class UnitQuizApp extends StatelessWidget {
  const UnitQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuizController();
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
        title: const Text('Unit Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.isFinished) {
              return _ScoreView(controller: _controller);
            }
            return _QuestionView(controller: _controller);
          },
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;
    final answered = controller.isAnswered;
    final isLast = controller.currentIndex == controller.questions.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                'Question ${controller.currentIndex + 1} of ${controller.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                'Score: ${controller.score}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LinearProgressIndicator(
            value: controller.currentIndex / controller.questions.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        question.emoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.prompt,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final option in question.options)
                _OptionTile(
                  option: option,
                  controller: controller,
                  onTap: () => controller.selectAnswer(option),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: answered ? controller.nextQuestion : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(answered && isLast ? 'See score' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.controller,
    required this.onTap,
  });

  final String option;
  final QuizController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCorrectAnswer = option == controller.currentQuestion.correctAnswer;
    final isSelected = option == controller.selectedAnswer;
    final locked = controller.isAnswered;

    var borderColor = scheme.outline;
    var fillColor = Colors.transparent;
    var textColor = scheme.onSurface;
    IconData? trailing;
    Color? trailingColor;

    if (locked) {
      if (isCorrectAnswer) {
        borderColor = Colors.green;
        fillColor = Colors.green.withValues(alpha: 0.12);
        textColor = Colors.green;
        trailing = Icons.check_circle;
        trailingColor = Colors.green;
      } else if (isSelected) {
        borderColor = scheme.error;
        fillColor = scheme.error.withValues(alpha: 0.12);
        textColor = scheme.error;
        trailing = Icons.cancel;
        trailingColor = scheme.error;
      } else {
        textColor = scheme.outline;
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: fillColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        enabled: !locked,
        onTap: locked ? null : onTap,
        title: Text(
          option,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        trailing: trailing == null
            ? const Icon(Icons.chevron_right)
            : Icon(trailing, color: trailingColor),
      ),
    );
  }
}

class _ScoreView extends StatelessWidget {
  const _ScoreView({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.questions.length;
    final score = controller.score;
    final pct = score / total;

    var emoji = '💪';
    var message = 'Keep practicing — you\'ll nail it next round!';
    if (pct >= 0.9) {
      emoji = '🏆';
      message = 'Conversion master! Flawless knowledge of units.';
    } else if (pct >= 0.7) {
      emoji = '🎉';
      message = 'Great job — your conversions are sharp.';
    } else if (pct >= 0.5) {
      emoji = '👍';
      message = 'Solid effort — keep it up!';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'Score: $score / $total',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.restart,
              icon: const Icon(Icons.replay),
              label: const Text('Play again'),
            ),
          ],
        ),
      ),
    );
  }
}
