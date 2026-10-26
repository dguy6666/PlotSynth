

import 'package:plotsynth_app/models/text_version.dart';

class Project{
  final String id;
  final String name;
  final DateTime lastModified;
  final List<TextVersion> ideasText;
  final List<TextVersion> storyText;
  

  const Project({
    required this.id,
    required this.name,
    required this.lastModified,
    required this.ideasText,
    required this.storyText,
    
  });

  static Project? findById(List<Project> projects, String targetId) {
    for (final project in projects) {
      if (project.id == targetId) {
        return project;
      }
    }
    return null;
  }
}