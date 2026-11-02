import 'package:plotsynth_app/models/text_snapshot.dart';

class Project {
  final String id;
  String name;     
  DateTime createdAt;         // Can be renamed by the author
  DateTime updatedAt;    // Updates when saved
  final List<TextSnapshot> outlineHistory;
  final List<TextSnapshot> writeHistory;
  bool isFavorite;          // Toggled with stars (Dart creates getter/setter automatically!)

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.outlineHistory,
    required this.writeHistory,
    this.isFavorite = false, // Defaults to false
  });

  // Latest saved outline:
  String get currentOutline =>
      outlineHistory.isEmpty ? '' : outlineHistory.last.content;

  // Latest saved story chapter (added for symmetry!):
  String get currentStory =>
      writeHistory.isEmpty ? '' : writeHistory.last.content;

  // Helper method to find a project by ID:
  static Project? findById(List<Project> projects, String targetId) {
    for (final project in projects) {
      if (project.id == targetId) return project;
    }
    return null;
  }

  // המרה ממופע Dart למפה עבור SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0, // המרת בוליאן למספר שלם
      
    };
  }

  // המרה משורת SQLite חזרה למופע Dart
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      outlineHistory: [],
      writeHistory: [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isFavorite: map['isFavorite'] == 1, // המרת מספר שלם לבוליאן
    );
  }
}