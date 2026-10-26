import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectWorkspaceScreen extends StatefulWidget {
  final Project project;
  const ProjectWorkspaceScreen({super.key, required this.project});

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  
  
  // Start on index 2 (the middle tab of 5: indices 0, 1, 2, 3, 4)
  int _currentIndex = 2;

  // Reusable body containing an expanded text input with two buttons beneath
  Widget _buildInputBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Expanded(
            child: TextField(
              maxLines: null, // Allows multiline to fill available height
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Enter text here...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Analyze'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // if(widget.project!.ideasText.isEmpty){
                    //   widget.project?.ideasText.add(TextVersion(versionNumber: 1, content: "", timestamp: DateTime.now()));
                    // }
                    // else{
                    //   widget.project?.ideasText.add(TextVersion(versionNumber: 1, content: "", timestamp: DateTime.now()));
                    // }
                    // widget.project?.ideasText.add(TextVersion(versionNumber: 1, content: "", timestamp: DateTime.now()));
                    
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const Center(child: Text('Tab 1')),
      const Center(child: Text('Tab 2')),
      _buildInputBody(), // Middle tab (index 2)
      _buildInputBody(), // Right of middle (index 3)
      const Center(child: Text('Tab 5')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Needed for 4+ tabs
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'TimeLine'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Ideas'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Story'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Dictionary'),
        ],
      ),
    );
  }

}

