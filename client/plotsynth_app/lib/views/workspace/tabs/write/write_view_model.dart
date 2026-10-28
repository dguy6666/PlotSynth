import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';


class WriteViewModel extends ChangeNotifier {
  final Project project;
  WriteViewModel({required this.project});

  int currentChapter = 1;

  void setChapter(int chapter) {
    currentChapter = chapter;
    notifyListeners();
  }
}