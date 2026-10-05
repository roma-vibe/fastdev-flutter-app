class Note {
  const Note({required this.id, required this.text, required this.createdAt});
  factory Note.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final text = json['text'];
    final createdAt = json['createdAt'];
    if (id is! String ||
        id.isEmpty ||
        text is! String ||
        text.trim().isEmpty ||
        createdAt is! String) {
      throw const FormatException('Invalid note data.');
    }
    return Note(
      id: id,
      text: text,
      createdAt: DateTime.parse(createdAt).toUtc(),
    );
  }
  static const maxTextLength = 500;
  static String validateText(String text) {
    final value = text.trim();
    if (value.isEmpty) throw const FormatException('Enter a note.');
    if (value.length > maxTextLength) {
      throw const FormatException('Keep notes under 500 characters.');
    }
    return value;
  }

  final String id;
  final String text;
  final DateTime createdAt;
  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
