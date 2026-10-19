import 'package:flutter/material.dart';
import 'project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projects Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF7EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF6C995)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _projects = ['Main Novel Draft', 'World Compendium', 'Character Logs'];

  void _showAddProjectDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF9EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What is the name of the project?',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4BE81),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final String projectName = textController.text.trim();
                if (projectName.isNotEmpty) {
                  setState(() => _projects.add(projectName));
                  Navigator.pop(dialogContext); // Close dialog

                  // Transition directly to the ProjectScreen in project.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectScreen(projectName: projectName),
                    ),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900 ? 5 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF6E6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF9D7AC)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.folder_copy, size: 40, color: Colors.black87),
                  SizedBox(height: 10),
                  Text('Workspace Menu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('ORGANIZE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort A to Z'),
              onTap: () {
                setState(() => _projects.sort());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFAD7A9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu, color: Colors.black87),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Projects',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8DEF8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black87, size: 22),
              ),
              onSelected: (val) {},
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'login', child: Text('Log In')),
                const PopupMenuItem(value: 'logout', child: Text('Log Out')),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              itemCount: _projects.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                // The "+" Add project card
                if (index == _projects.length) {
                  return Material(
                    color: const Color(0xFFFFECC4),
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _showAddProjectDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFF2A45C).withOpacity(0.5), width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 42, color: Color(0xFFF2A45C)),
                        ),
                      ),
                    ),
                  );
                }

                // Project Cards
                final projectName = _projects[index];
                return Material(
                  color: const Color(0xFFF9D19E),
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      // Transition to project.dart when tapping an existing project square
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectScreen(projectName: projectName),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.topic_rounded, size: 46, color: Color(0xFF6B4823)),
                          const SizedBox(height: 10),
                          Text(
                            projectName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C2713),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}