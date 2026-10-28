class DictionaryTerm {
  final String id;
  final String word;        // e.g. "Fitin", "Pyromancy"
  final String definition;  // e.g. "The dangerous northern kingdom"
  final String category;    // "Place", "Spell", "Title"
  final DateTime addedAt;

  DictionaryTerm
  ({
    required this.id,
    required this.word,
    required this.definition,
    required this.category,
    required this.addedAt
  });
}