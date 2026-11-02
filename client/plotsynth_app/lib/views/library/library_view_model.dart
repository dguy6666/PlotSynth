import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/models/sort_option.dart';
import 'package:plotsynth_app/repositories/project_repository.dart'; // 1. ייבוא ה-Repository

class LibraryViewModel extends ChangeNotifier {
  // 2. מופע של ה-Repository שמקשר ל-DatabaseService
  final ProjectRepository _repository = ProjectRepository();

  // הרשימה מתחילה ריקה ונטענת ישירות מ-SQLite
  List<Project> _allProjects = [];
  bool isLoading = false;

  SortOption currentSort = SortOption.date;
  bool isAscending = false;
  bool showOnlyFavorites = false;
  String _searchQuery = '';

  LibraryViewModel() {
    // טעינת הפרויקטים הקיימים מ-SQLite ברגע שה-ViewModel נוצר
    loadProjects();
  }

  // 3. שליפת כל הפרויקטים מה-Database דרך ה-Repository
  Future<void> loadProjects() async {
    isLoading = true;
    notifyListeners();

    try {
      _allProjects = await _repository.getAllProjects();
    } catch (e) {
      debugPrint("Error loading projects: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Project> get displayedProjects {
    List<Project> list;
    if (showOnlyFavorites) {
      list = _allProjects.where((p) => p.isFavorite).toList();
    } else {
      list = List.from(_allProjects);
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
    }

    list.sort((a, b) {
      int cmp;
      if (currentSort == SortOption.name) {
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        cmp = a.updatedAt.compareTo(b.updatedAt);
      }

      return isAscending ? cmp : -cmp;
    });

    return list;
  }

  // 4. יצירה ושמירה של פרויקט חדש ב-Database
  Future<Project> createNewProject(String name) async {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      outlineHistory: [],
      writeHistory: [],
      isFavorite: false,
    );

    try {
      // קריאה ל-Repository -> קורא ל-DatabaseService -> נשמר ב-SQLite!
      await _repository.insertProject(newProject);
      _allProjects.add(newProject);
      notifyListeners();
    } catch (e) {
      debugPrint("Error inserting new project: $e");
    }

    return newProject;
  }

  List<Project> get allProjects => _allProjects;

  Future<void> renameProject(String projectId, String newName) async {
    final index = _allProjects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _allProjects[index];
      project.name = newName;
      project.updatedAt = DateTime.now();
      notifyListeners();

      try {
        await _repository.updateProject(project);
      } catch (e) {
        debugPrint("Error renaming project: $e");
      }
    }
  }

  Future<void> deleteProject(String projectId) async {
    _allProjects.removeWhere((p) => p.id == projectId);
    notifyListeners();

    try {
      await _repository.deleteProject(projectId);
    } catch (e) {
      debugPrint("Error deleting project: $e");
    }
  }

  void setSortOption(SortOption option) {
    currentSort = option;
    isAscending = (option == SortOption.name);
    notifyListeners();
  }

  void toggleSortDirection() {
    isAscending = !isAscending;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    showOnlyFavorites = !showOnlyFavorites;
    notifyListeners();
  }

  // עדכון מועדף כולל עדכון ב-DB
  Future<void> toggleProjectFavorite(String projectId) async {
    final index = _allProjects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _allProjects[index];
      project.isFavorite = !project.isFavorite;
      notifyListeners();

      try {
        await _repository.updateProject(project);
      } catch (e) {
        debugPrint("Error updating favorite: $e");
      }
    }
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }
}