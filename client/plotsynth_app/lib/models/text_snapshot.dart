class TextSnapshot {
  final String id;
  final DateTime timestamp;
  final String content;       // The saved text
  final int wordCount;         // Quick stat: e.g. 350 words

  int get charCount => content.length;
  TextSnapshot({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.wordCount,
  });
  
  // הופך מופע של המחלקה למפה שמתאימה לשורה ב-DB
  Map<String, dynamic> toMap(String projectId, String tabType) {
    return {
      'id': id,
      'projectId': projectId,
      'tabType': tabType,
      'content': content,
      'wordCount': wordCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // בונה אובייקט מתוך שורה שנשלפה מה-DB
  factory TextSnapshot.fromMap(Map<String, dynamic> map) {
    return TextSnapshot(
      id: map['id'],
      content: map['content'],
      wordCount: map['wordCount'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
  
  factory TextSnapshot.create(String text) {
    final trimmed = text.trim();
    final words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;

    return TextSnapshot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      content: text,
      wordCount: words,
    );
  }
}