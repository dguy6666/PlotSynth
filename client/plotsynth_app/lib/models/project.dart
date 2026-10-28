import 'package:plotsynth_app/models/text_snapshot.dart';

class Project {
  final String id;
  String name;              // Can be renamed by the author
  DateTime lastModified;    // Updates when saved
  final List<TextSnapshot> outlineHistory;
  final List<TextSnapshot> storyHistory;
  bool isFavorite;          // Toggled with stars (Dart creates getter/setter automatically!)

  Project({
    required this.id,
    required this.name,
    required this.lastModified,
    required this.outlineHistory,
    required this.storyHistory,
    this.isFavorite = false, // Defaults to false
  });

  // Latest saved outline:
  String get currentOutline =>
      outlineHistory.isEmpty ? '' : outlineHistory.last.content;

  // Latest saved story chapter (added for symmetry!):
  String get currentStory =>
      storyHistory.isEmpty ? '' : storyHistory.last.content;

  // Helper method to find a project by ID:
  static Project? findById(List<Project> projects, String targetId) {
    for (final project in projects) {
      if (project.id == targetId) return project;
    }
    return null;
  }
}