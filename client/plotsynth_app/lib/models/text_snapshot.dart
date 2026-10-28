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