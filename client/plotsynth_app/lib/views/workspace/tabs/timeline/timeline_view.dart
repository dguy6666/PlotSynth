import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'timeline_view_model.dart';

class TimelineView extends StatelessWidget {
  final Project project;
  final TimelineViewModel viewModel;

  TimelineView({super.key, required this.project})
      : viewModel = TimelineViewModel(project: project);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Chronological Timeline ⏳')),
          body: const Center(child: Text('Chronological events list goes here')),
        );
      },
    );
  }
}