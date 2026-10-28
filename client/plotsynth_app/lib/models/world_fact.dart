class WorldFact {
  final String id;
  final String subject;        // e.g. "Fitin Kingdom"
  final String statement;      // e.g. "Infested with thieves"
  final int validFromChapter;
  final int? validToChapter;

  WorldFact({
  required this.id,
  required this.subject,
  required this.statement,
  required this.validFromChapter,
  this.validToChapter
  });
}