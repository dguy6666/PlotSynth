import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';


class DictionaryViewModel extends ChangeNotifier {
  final Project project;
  DictionaryViewModel({required this.project});
}