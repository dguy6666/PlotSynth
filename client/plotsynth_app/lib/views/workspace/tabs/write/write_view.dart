import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'write_view_model.dart';

class WriteView extends StatelessWidget {
  final Project project;
  final WriteViewModel viewModel;

  WriteView({super.key, required this.project})
      : viewModel = WriteViewModel(project: project);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manuscript Editor 📖')),
          body: const Center(child: Text('Scene text & Consistency check go here')),
        );
      },
    );
  }
}