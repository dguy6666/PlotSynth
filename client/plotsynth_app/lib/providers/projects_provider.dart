

import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
//import 'package:plotsynth_app/models/project_sort.dart';

class ProjectsProvider extends ChangeNotifier{
  
  List<Project> allProjects = [
    Project(
      id: '1',
      name: 'Cyberpunk Odyssey',
      lastModified: DateTime.now().subtract(const Duration(days: 2)),
      ideasText: List.empty(),
      storyText: List.empty(),
    ),
    Project(
      id: '2',
      name: 'Whispers in the Dark',
      lastModified: DateTime.now().subtract(const Duration(hours: 4)),
      ideasText: List.empty(),
      storyText: List.empty(),
    ),
    Project(
      id: '3',
      name: 'Aether Chronicles',
      lastModified: DateTime.now().subtract(const Duration(days: 10)),
      ideasText: List.empty(),
      storyText: List.empty(),
    ),
  ];

  // // Filters and sorts projects dynamically
  // List<Project> visibleProjects() {
  //   // 1. Filter by search query
  //   List<Project> list = allProjects.where((p) {
  //     return p.name.toLowerCase().contains(searchQuery.toLowerCase());
  //   }).toList();

  //   // 2. Sort the filtered list
  //   switch (currentSort) {
  //     case ProjectSortOption.nameAZ:
  //       list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  //       break;
  //     case ProjectSortOption.nameZA:
  //       list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
  //       break;
  //     case ProjectSortOption.lastModified:
  //       list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  //       break;
  //     case ProjectSortOption.firstModified:
  //       list.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  //       break;
  //     case ProjectSortOption.favoritesOnly:
  //       // Default to last modified order for favorites
  //       list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  //       break;
  //   }

  //   return list;
  // }

  Project createNewProject() {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Project',
      lastModified: DateTime.now(),
      ideasText: List.empty(),
      storyText: List.empty(),
      
    );

    return newProject;

    
  }
}