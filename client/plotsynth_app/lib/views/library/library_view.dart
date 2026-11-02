import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/views/library/widgets/show_delete_confirm_dialog.dart';
import 'package:plotsynth_app/views/library/widgets/show_project_name_dialog.dart';
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
                  onTap: () async{
                    final name = await showProjectNameDialog(
                      context: context,
                      actionLabel: 'Create',
                      title: 'New Project',
                    );
                    if (name != null) {
                      final Project newProject = await viewModel.createNewProject(name);
                      if(context.mounted){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkspaceView(project: newProject,),
                          ),
                        );
                      }
                    }

                    
                  }
                );
              }

              // Remaining items: Project cards (offset by 1)
              //List<Project> allProjects = context.read<ProjectsProvider>().allProjects;

              // final project = viewModel.displayedProjects[index];
              // return ProjectCard(
              //   project: project,
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => WorkspaceView(project: project,),
              //       ),
              //     );
              //   },
              // );
              final project = viewModel.displayedProjects[index];

              return ProjectCard(
                project: project,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkspaceView(project: project),
                    ),
                  );
                },
                onToggleFavorite: () {
                  // ה-View רק מפעיל את הפקודה ב-ViewModel
                  viewModel.toggleProjectFavorite(project.id);
                },
                onMenuSelected: (action) async {
                  switch (action) {
                    case ProjectMenuAction.rename:
                      final newName = await showProjectNameDialog(
                        context: context,
                        initialValue: project.name,
                        actionLabel: 'Rename',
                        title: 'Rename Project',
                      );
                      // העברת הפקודה ל-ViewModel
                      if (newName != null) {
                        viewModel.renameProject(project.id, newName);
                      }
                      break;

                    case ProjectMenuAction.delete:
                      final confirmed = await showDeleteConfirmDialog(context, project.name);
                      // העברת הפקודה ל-ViewModel
                      if (confirmed) {
                        viewModel.deleteProject(project.id);
                      }
                      break;

                    case ProjectMenuAction.changeIcon:
                      break;
                  }
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