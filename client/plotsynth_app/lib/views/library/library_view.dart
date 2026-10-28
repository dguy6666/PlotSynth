import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/views/workspace/workspace_view.dart';
import 'package:plotsynth_app/views/library/widgets/add_project_card.dart';
import 'package:plotsynth_app/views/library/widgets/library_app_bar.dart';
import 'package:plotsynth_app/views/library/widgets/project_card.dart';

import 'library_view_model.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final LibraryViewModel viewModel = LibraryViewModel();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
    listenable: viewModel, // מקשיב ל-notifyListeners
    builder: (context, child) {
      return Scaffold(
        appBar: LibraryAppBar(
          currentSort: viewModel.currentSort,
          isFavoritesOnly: viewModel.showOnlyFavorites,
          onSortOrderToggle: viewModel.toggleSortDirection,
          isAscending: viewModel.isAscending,
          onToggleFavorites: viewModel.toggleFavoritesOnly,
          onSortSelected: (sort) {
            viewModel.setSortOption(sort);
          },
          onSearchChanged: (query) {
            viewModel.search(query);
          },
          onSyncPressed: () {},
          onProfilePressed: () {},
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.grid_3x3),
                  title: const Text("3 projects per row"),
                  selected: false,
                  onTap: () {
                    
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    // Push to settings view
                  },
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.builder(
            // Last slot is always "Add New", followed by the filtered projects
            itemCount: viewModel.displayedProjects.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              // First item: Add Project button
              if (index == viewModel.displayedProjects.length) {
                return AddProjectCard(
                  onTap: () {
                    
                    //var allProjectsProvider = Provider.of<ProjectsProvider>(context, listen:false);
                    Project newProject = viewModel.createNewProject();
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkspaceView(project: newProject,),
                      ),
                    );
                
                  }
                );
              }

              // Remaining items: Project cards (offset by 1)
              //List<Project> allProjects = context.read<ProjectsProvider>().allProjects;

              final project = viewModel.displayedProjects[index];
              return ProjectCard(
                project: project,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkspaceView(project: project,),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    
  }
  );
  
  
}
}