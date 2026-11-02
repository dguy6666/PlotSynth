

// import 'package:flutter/material.dart';
// import 'package:plotsynth_app/models/project.dart';
// import 'package:plotsynth_app/views/library/library_view_model.dart';
// import 'package:plotsynth_app/views/library/widgets/show_delete_confirm_dialog.dart';
// import 'package:plotsynth_app/views/library/widgets/show_project_name_dialog.dart';

// enum ProjectMenuAction { rename, delete, changeIcon }

// // Helper function to trigger actions from either 3-dots or long-click
// void _handleMenuAction(BuildContext context, ProjectMenuAction action, Project project, LibraryViewModel viewModel) async {
//   switch (action) {
//     case ProjectMenuAction.rename:
//       final newName = await showProjectNameDialog(
//         context: context,
//         initialValue: project.name,
//         actionLabel: 'Rename',
//         title: 'Rename Project',
//       );
//       if (newName != null) viewModel.renameProject(project.id, newName);
//       break;

//     case ProjectMenuAction.delete:
//       final confirmed = await showDeleteConfirmDialog(context, project.name);
//       if (confirmed) viewModel.deleteProject(project.id);
//       break;

//     case ProjectMenuAction.changeIcon:
//       // Hook icon picker dialog here
//       break;
//   }
// }

// void _showContextMenu(BuildContext context, Offset position, Project project, LibraryViewModel viewModel) async {
//   final selected = await showMenu<ProjectMenuAction>(
//     context: context,
//     position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
//     items: const [
//       PopupMenuItem(
//         value: ProjectMenuAction.rename,
//         child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Rename')]),
//       ),
//       PopupMenuItem(
//         value: ProjectMenuAction.changeIcon,
//         child: Row(children: [Icon(Icons.image, size: 18), SizedBox(width: 8), Text('Change Icon')]),
//       ),
//       PopupMenuItem(
//         value: ProjectMenuAction.delete,
//         child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
//       ),
//     ],
//   );
//   if (selected != null && context.mounted) {
//     _handleMenuAction(context, selected, project, viewModel);
//   }
// }

// class ProjectCard extends StatelessWidget {
//   final Project project;
//   final VoidCallback? onTap;

//   const ProjectCard({
//     super.key,
//     required this.project,
//     this.onTap,
//   });

//   String _formatDate(DateTime dt) {
//     final year = dt.year;
//     final month = dt.month.toString().padLeft(2, '0');
//     final day = dt.day.toString().padLeft(2, '0');
//     return '$year-$month-$day';
//   }


//   @override
// Widget build(BuildContext context) {
//   final theme = Theme.of(context);
//   final borderRadius = BorderRadius.circular(16); // או רדיוס הפינות המוגדר אצלך
  
//   return Card(
//     elevation: 2,
//     clipBehavior: Clip.antiAlias, // שומר על האפקט של ה-InkWell בתוך הפינות המעוגלות
//     shape: RoundedRectangleBorder(borderRadius: borderRadius),
//     child: InkWell(
//       borderRadius: borderRadius,
//       onTap: onTap,
//       // לחיצה ארוכה פותחת את התפריט הצף
//       onLongPress: () => _showContextMenu(context),
//       child: Stack(
//         children: [
//           // 1. תוכן הכרטיסייה המקורי במרכז
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.folder_rounded,
//                     size: 44,
//                     color: theme.colorScheme.primary,
//                   ),
//                   const SizedBox(height: 10),
//                   Flexible(
//                     child: Text(
//                       project.name,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Modified: ${_formatDate(project.updatedAt)}',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // 2. פינה שמאלית עליונה: תפריט 3 נקודות
//           Positioned(
//             top: 4,
//             left: 4,
//             child: PopupMenuButton<ProjectMenuAction>(
//               icon: Icon(
//                 Icons.more_vert,
//                 size: 20,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//               onSelected: (action) => _handleMenuAction(context, action),
//               itemBuilder: (ctx) => const [
//                 PopupMenuItem(
//                   value: ProjectMenuAction.rename,
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit_outlined, size: 18),
//                       SizedBox(width: 8),
//                       Text('Rename'),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: ProjectMenuAction.changeIcon,
//                   child: Row(
//                     children: [
//                       Icon(Icons.image_outlined, size: 18),
//                       SizedBox(width: 8),
//                       Text('Change Icon'),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: ProjectMenuAction.delete,
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_outline, color: Colors.red, size: 18),
//                       SizedBox(width: 8),
//                       Text('Delete', style: TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // 3. פינה ימנית עליונה: כפתור כוכב (isFavorite)
//           Positioned(
//             top: 4,
//             right: 4,
//             child: IconButton(
//               iconSize: 22,
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//               icon: Icon(
//                 project.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
//                 color: project.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
//               ),
//               onPressed: () {
//                 // מפעיל עדכון מועדף ב-ViewModel
//                 widget.
//                 widget.toggleProjectFavorite(project.id);
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }

import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';

enum ProjectMenuAction { rename, changeIcon, delete }

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback onToggleFavorite;
  final ValueChanged<ProjectMenuAction> onMenuSelected;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    required this.onToggleFavorite,
    required this.onMenuSelected,
  });

  String _formatDate(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final selected = await showMenu<ProjectMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const [
        PopupMenuItem(
          value: ProjectMenuAction.rename,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ProjectMenuAction.changeIcon,
          child: Row(
            children: [
              Icon(Icons.image_outlined, size: 18),
              SizedBox(width: 8),
              Text('Change Icon'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ProjectMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (selected != null) {
      onMenuSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12.0);

    return GestureDetector(
      // פתיחת תפריט בקליק ימני (Desktop/Web) או בלחיצה ארוכה (Android/Tablet)
      onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
      onLongPressStart: (details) => _showContextMenu(context, details.globalPosition),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays inside rounded card corners
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Stack(
          children: [
            // גוף הכרטיס המקורי שלך
            InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          project.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Modified: ${_formatDate(project.updatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // כפתור 3 נקודות בפינה השמאלית העליונה
            Positioned(
              top: 4,
              left: 4,
              child: PopupMenuButton<ProjectMenuAction>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                onSelected: onMenuSelected,
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: ProjectMenuAction.rename,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ProjectMenuAction.changeIcon,
                    child: Row(
                      children: [
                        Icon(Icons.image_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Change Icon'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ProjectMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // כפתור כוכב בפינה הימנית העליונה (isFavorite)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                iconSize: 22,
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  project.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: project.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                onPressed: onToggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}