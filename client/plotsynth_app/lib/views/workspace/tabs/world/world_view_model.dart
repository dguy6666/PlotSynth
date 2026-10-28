import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';

class WorldViewModel extends ChangeNotifier {
  final Project project;
  WorldViewModel({required this.project});

  bool isGraphView = false;

  void toggleView() {
    isGraphView = !isGraphView;
    notifyListeners();
  }
}