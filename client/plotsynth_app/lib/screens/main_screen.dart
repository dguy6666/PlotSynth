import 'package:flutter/material.dart';
import 'project_workspace_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      drawer: Drawer(
        child: SafeArea(child: 
        Column(
          children: const [
            ListTile(leading: Icon(Icons.sort_by_alpha),title: Text("Sort By A-Z"),),
            ListTile(leading: Icon(Icons.sort),title: Text("Sort By Last Modified"),),
            Divider(),
            ListTile(leading: Icon(Icons.settings),title: Text("Settings"),)
          ]
        )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 6, // Number of items to test
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns (must be an integer)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0, // 1.0 makes each card a square
          ),
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectWorkspaceScreen(),
                        ),
                      );
                },
                child: Text('Project $index'),
              ),
            );
          },
        ),
      )
    );
  }
}