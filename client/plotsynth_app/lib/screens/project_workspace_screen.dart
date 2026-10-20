import 'package:flutter/material.dart';


class ProjectWorkspaceScreen extends StatefulWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Projects'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: Icon(Icons.sync)),
        IconButton(onPressed: () {}, icon: Icon(Icons.account_box))],
      ),
    );
  }
}