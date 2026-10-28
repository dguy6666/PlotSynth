import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/models/text_snapshot.dart';


class OutlineViewModel extends ChangeNotifier {
  final Project project;
  OutlineViewModel({required this.project});



  void saveOutline(String newText){
    // Creates a brand-new snapshot with a fresh ID and timestamp:
    final newSnapshot = TextSnapshot.create(newText);

    // Adds it to the history list:
    project.outlineHistory.add(newSnapshot);

    project.lastModified = DateTime.now();

    notifyListeners(); // Refreshes UI to show "Saved!"
  }

  int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    
    // Splits by any whitespace (spaces, multiple spaces, tabs, and newlines \n):
    return trimmed.split(RegExp(r'\s+')).length;
  }
}