import 'dart:math';

/// A single note with a title, body, and last-updated timestamp.
class Note {
  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  factory Note.create({String title = '', String body = ''}) => Note(
        id: _newId(),
        title: title,
        body: body,
        updatedAt: DateTime.now(),
      );

  factory Note.fromJson(Map<String, Object?> json) => Note(
        id: (json['id'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
                DateTime.now(),
      );

  final String id;
  String title;
  String body;
  DateTime updatedAt;

  bool get isBlank => title.trim().isEmpty && body.trim().isEmpty;

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        body.toLowerCase().contains(q);
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static String _newId() {
    final rand = Random();
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
        rand.nextInt(0x10000).toRadixString(36).padLeft(4, '0');
  }
}
