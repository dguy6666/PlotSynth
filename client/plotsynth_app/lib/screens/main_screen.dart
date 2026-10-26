import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plotsynth_app/providers/projects_provider.dart';
import 'package:plotsynth_app/widgets/add_new_project_card.dart';
import 'package:plotsynth_app/widgets/project_card.dart';
import 'project_workspace_screen.dart';
import '../widgets/main_screen_app_bar.dart';
import '../models/project_sort.dart';
import '../models/project.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current search text
  String _searchQuery = '';

  // Default sort option
  ProjectSortOption _currentSort = ProjectSortOption.lastModified;

  // List<Project> _allProjects = context
  
  

  // // Filters and sorts projects dynamically
  // List<Project> get _visibleProjects {
  //   // 1. Filter by search query
  //   List<Project> list = _allProjects.where((p) {
  //     return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
  //   }).toList();

  //   // 2. Sort the filtered list
  //   switch (_currentSort) {
  //     case ProjectSortOption.nameAZ:
  //       list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  //       break;
  //     case ProjectSortOption.nameZA:
  //       list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
  //       break;
  //     case ProjectSortOption.lastModified:
  //       list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  //       break;
  //     case ProjectSortOption.firstModified:
  //       list.sort((a, b) => a.lastModified.compareTo(b.lastModified));
  //       break;
  //     case ProjectSortOption.favoritesOnly:
  //       // Default to last modified order for favorites
  //       list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
  //       break;
  //   }

  //   return list;
  // }

  

  @override
  Widget build(BuildContext context) {
    // final visibleList = _visibleProjects;
    
    return Scaffold(
      appBar: MainScreenAppBar(
        currentSort: _currentSort,
        onSortSelected: (sort) {
          setState(() {
            _currentSort = sort;
          });
        },
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        onSyncPressed: () {},
        onProfilePressed: () {},
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Sort By A-Z"),
                selected: _currentSort == ProjectSortOption.nameAZ,
                onTap: () {
                  setState(() => _currentSort = ProjectSortOption.nameAZ);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Sort By Last Modified"),
                selected: _currentSort == ProjectSortOption.lastModified,
                onTap: () {
                  setState(() => _currentSort = ProjectSortOption.lastModified);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  // Push to settings screen
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          // Slot 0 is always "Add New", followed by the filtered projects
          itemCount: 1,//visibleList.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            // First item: Add Project button
            if (index == 0) {
              return AddNewProjectCard(
                onTap: () {
                  
                  //var allProjectsProvider = Provider.of<ProjectsProvider>(context, listen:false);
                  Project newProject = context.read<ProjectsProvider>().createNewProject();
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectWorkspaceScreen(project: newProject,),
                    ),
                  );
              
                }
              );
            }

            // Remaining items: Project cards (offset by 1)
            //List<Project> allProjects = context.read<ProjectsProvider>().allProjects;

            final project = context.read<ProjectsProvider>().allProjects[0];//visibleList[index - 1];
            return ProjectCard(
              project: project,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectWorkspaceScreen(project: project,),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}