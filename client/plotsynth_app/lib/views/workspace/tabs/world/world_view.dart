import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'world_view_model.dart';

class WorldView extends StatelessWidget {
  final Project project;
  final WorldViewModel viewModel;

  WorldView({super.key, required this.project})
      : viewModel = WorldViewModel(project: project);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('World & Canon 🌐')),
          body: const Center(child: Text('Bento Cards & Graph view go here')),
        );
      },
    );
  }
}