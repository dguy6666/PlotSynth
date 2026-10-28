import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/views/workspace/tabs/dictionary/dictionary_view.dart';
import 'package:plotsynth_app/views/workspace/tabs/outline/outline_view.dart';
import 'package:plotsynth_app/views/workspace/tabs/timeline/timeline_view.dart';
import 'package:plotsynth_app/views/workspace/tabs/world/world_view.dart';
import 'package:plotsynth_app/views/workspace/tabs/write/write_view.dart';
import 'package:plotsynth_app/views/workspace/widgets/workspace_bottom_bar.dart';


class WorkspaceView extends StatefulWidget {
  final Project project;
  const WorkspaceView({super.key, required this.project});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  int _currentTabIndex = 2;

// List of your 5 independent Views:
  late final List<Widget> _tabs = [
    TimelineView(project: widget.project),      // Tab 0
    WorldView(project: widget.project),       // Tab 1
    OutlineView(project: widget.project), // Tab 2
    WriteView(project: widget.project),   // Tab 3
    DictionaryView(project: widget.project), // Tab 4
  ];

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body shows the currently selected tab:
      body: IndexedStack(
        index: _currentTabIndex,
        children: _tabs,
      ),

      // The Bottom Bar stays identical and permanently visible:
      bottomNavigationBar: WorkspaceBottomBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index; // Switches tab!
          });
        },
      ),
    );
  }

}

