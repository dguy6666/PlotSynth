import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'dictionary_view_model.dart';

class DictionaryView extends StatelessWidget {
  final Project project;
  final DictionaryViewModel viewModel;

  DictionaryView({super.key, required this.project})
      : viewModel = DictionaryViewModel(project: project);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Custom Dictionary 📚')),
          body: const Center(child: Text('Learned invented words go here')),
        );
      },
    );
  }
}