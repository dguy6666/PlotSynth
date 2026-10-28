class NarrativeClaim {
  final String id;
  final String speakerId;      // Which character said or believes it
  final String statement;      // What they claimed
  final int inChapter;         // Where it happened
  final bool isKnownLie;       // Set to true if the author intended a deception
  final String? conflictingWorldFactId; // Links back to the WorldFact they are defying!

  NarrativeClaim
  ({
    required this.id,
    required this.speakerId,
    required this.statement,
    required this.inChapter,
    required this.isKnownLie,
    this.conflictingWorldFactId
    });
}