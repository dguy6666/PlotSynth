import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';


class TimelineViewModel extends ChangeNotifier {
  final Project project;
  TimelineViewModel({required this.project});
}