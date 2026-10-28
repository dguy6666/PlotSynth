import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/models/sort_option.dart';


//enum SortOption {date,name}
class LibraryViewModel extends ChangeNotifier {
  final List<Project> _allProjects = [
    Project(id: '1', name: "new project", lastModified: DateTime.now(), outlineHistory: [], storyHistory: [], isFavorite: false),
    Project(id: '2', name: "ban", lastModified: DateTime.now().subtract(Duration(days: 12)), outlineHistory: [], storyHistory: [], isFavorite: false)
  ];
  SortOption currentSort = SortOption.date;
  bool isAscending = false;
  bool showOnlyFavorites = false;
  String _searchQuery = '';

  List<Project> get displayedProjects {
    // 1. סינון לפי מועדפים אם המשתמש הפעיל את הכפתור
    List<Project> list;
    if (showOnlyFavorites) {
      list = _allProjects.where((p) => p.isFavorite).toList();
    } else {
      list = List.from(_allProjects);
    }

    // 2. Filter by search query (case-insensitive):
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
    }
    
    list.sort((a, b) {
      int cmp;

      // 1. Choose what to compare
      if (currentSort == SortOption.name) {
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        cmp = a.lastModified.compareTo(b.lastModified);
      }

      // 2. Return positive or negative based on direction
      if (isAscending) {
        return cmp;
      } else {
        return -cmp; // Flips to descending
      }
    });
    
    return list;
  }

  Project createNewProject() {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Project',
      lastModified: DateTime.now(),
      outlineHistory: [],
      storyHistory: [],
      isFavorite: false,
    );
    _allProjects.add(newProject);
    notifyListeners();
    return newProject;
  }

  List<Project> get allProjects{
    return _allProjects;
  }
  
  // פונקציה לשינוי סוג המיון
  void setSortOption(SortOption option) {
    currentSort = option;
    if(option == SortOption.name)
    {
      isAscending = true;
    }
    else if(option == SortOption.date){
      isAscending = false;
    }
    notifyListeners(); // מרענן את המסך מיד!
  }


  void toggleSortDirection() {
    isAscending = !isAscending;
    notifyListeners();
  }

  // פונקציה להדלקה/כיבוי של סינון המועדפים בלבד
  void toggleFavoritesOnly() {
    showOnlyFavorites = !showOnlyFavorites;
    notifyListeners();
  }

  // פונקציה לסימון פרויקט בודד כמועדף (בלחיצה על לב בכרטיסייה)
  void toggleProjectFavorite(String projectId) {
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    project.isFavorite = !project.isFavorite;
    notifyListeners();
  }

  void search(String query){
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }
}