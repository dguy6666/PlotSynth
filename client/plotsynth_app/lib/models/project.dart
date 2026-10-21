

class Project{
  final String id;
  final String name;
  final DateTime lastModified;
  final String ideasText;
  final String storyText;
  

  const Project({
    required this.id,
    required this.name,
    required this.lastModified,
    this.ideasText = "",
    this.storyText = "",
    
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