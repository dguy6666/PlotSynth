import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/models/text_snapshot.dart';
import 'package:plotsynth_app/repositories/project_repository.dart'; // <--- 1. ייבוא ה-Repository

class OutlineViewModel extends ChangeNotifier {
  final Project project;
  final ProjectRepository _repository = ProjectRepository(); // <--- 2. מופע של ה-Repository

  String currentText = '';
  bool isLoading = false;

  OutlineViewModel({required this.project}) {
    // בטעינת ה-ViewModel שולפים את הטקסט האחרון שנשמר בדיסק
    loadLatestOutline();
  }

  // טעינת הטקסט האחרון מ-SQLite בעת כניסה למסך
  Future<void> loadLatestOutline() async {
    isLoading = true;
    notifyListeners();

    try {
      final latestSnapshot = await _repository.getLatestSnapshot(project.id, 'outline');
      if (latestSnapshot != null) {
        currentText = latestSnapshot.content;
      }
    } catch (e) {
      debugPrint("Error loading outline: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // שמירה בדיסק (SQLite) דרך ה-Repository
  Future<void> saveOutline(String newText) async {
    currentText = newText;

    // יוצר סנאפשוט בזיכרון
    final newSnapshot = TextSnapshot.create(newText);
    project.outlineHistory.add(newSnapshot);
    project.updatedAt = DateTime.now();

    // <--- 3. שומר את הסנאפשוט ב-DB המקומי דרך ה-Repository!
    try {
      await _repository.saveSnapshot(
        projectId: project.id,
        tabType: 'outline',
        snapshot: newSnapshot,
      );
    } catch (e) {
      debugPrint("Error saving outline to DB: $e");
    }

    notifyListeners(); // מרענן את ה-UI
  }

  int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}