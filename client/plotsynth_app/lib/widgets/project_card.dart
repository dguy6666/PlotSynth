// import 'package:flutter/material.dart';

// class ProjectCard extends StatelessWidget {
//   // 1. Declare the data your widget needs as final variables
//   final String title;
//   final String lastModified;
//   final VoidCallback onTap;

//   // 2. Add constructor with 'required' parameters and super.key
//   const ProjectCard({
//     super.key,
//     required this.title,
//     required this.lastModified,
//     required this.onTap,
//   });

//   // 3. Build the UI tree
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Icon(Icons.folder, size: 40),
//                 const SizedBox(height: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   lastModified,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  String _formatDate(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12.0);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays inside rounded card corners
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
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
                  'Modified: ${_formatDate(project.lastModified)}',
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
    );
  }
}
//   final String title;
//   final DateTime lastModified;
//   final bool isFavorite;
//   final String? customImageUrl;
//   final int? coverColorValue;
//   final VoidCallback onTap;
//   final VoidCallback onToggleFavorite;
//   final VoidCallback onRename;
//   final VoidCallback onChangeImage;
//   final VoidCallback onDelete;

//   const ProjectCard({
//     super.key,
//     required this.title,
//     required this.lastModified,
//     required this.isFavorite,
//     this.customImageUrl,
//     this.coverColorValue,
//     required this.onTap,
//     required this.onToggleFavorite,
//     required this.onRename,
//     required this.onChangeImage,
//     required this.onDelete,
//   });

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final diff = now.difference(date);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inHours < 1) return '${diff.inMinutes}m ago';
//     if (diff.inDays < 1) return '${diff.inHours}h ago';
//     if (diff.inDays < 7) return '${diff.inDays}d ago';
//     final day = date.day.toString().padLeft(2, '0');
//     final month = date.month.toString().padLeft(2, '0');
//     return '$day/$month/${date.year}';
//   }

//   void _showContextMenu(BuildContext context, Offset globalPosition) async {
//     final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
//     final selected = await showMenu<String>(
//       context: context,
//       position: RelativeRect.fromRect(
//         globalPosition & const Size(40, 40),
//         Offset.zero & overlay.size,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       color: const Color(0xFFFFF7EB),
//       items: [
//         PopupMenuItem<String>(
//           value: 'favorite',
//           child: Row(
//             children: [
//               Icon(
//                 isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
//                 color: isFavorite ? const Color(0xFFD97706) : const Color(0xFF4A3728),
//                 size: 20,
//               ),
//               const SizedBox(width: 10),
//               Text(isFavorite ? 'Remove Favorite' : 'Favorite'),
//             ],
//           ),
//         ),
//         const PopupMenuItem<String>(
//           value: 'rename',
//           child: Row(
//             children: [
//               Icon(Icons.edit_outlined, color: Color(0xFF4A3728), size: 20),
//               SizedBox(width: 10),
//               Text('Rename'),
//             ],
//           ),
//         ),
//         const PopupMenuItem<String>(
//           value: 'image',
//           child: Row(
//             children: [
//               Icon(Icons.image_outlined, color: Color(0xFF4A3728), size: 20),
//               SizedBox(width: 10),
//               Text('Add / Change Image'),
//             ],
//           ),
//         ),
//         const PopupMenuDivider(),
//         const PopupMenuItem<String>(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C), size: 20),
//               SizedBox(width: 10),
//               Text(
//                 'Delete',
//                 style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );

//     if (selected == 'favorite') {
//       onToggleFavorite();
//     } else if (selected == 'rename') {
//       onRename();
//     } else if (selected == 'image') {
//       onChangeImage();
//     } else if (selected == 'delete') {
//       onDelete();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Offset tapPosition = Offset.zero;

//     return Card(
//       color: const Color(0xFFFADBB8),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(22),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: GestureDetector(
//         onTapDown: (details) => tapPosition = details.globalPosition,
//         onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
//         onLongPress: () => _showContextMenu(context, tapPosition),
//         child: InkWell(
//           onTap: onTap,
//           splashColor: const Color(0xFFE5B37A).withValues(alpha: 0.35),
//           child: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       _buildProjectVisual(),
//                       const SizedBox(height: 12),
//                       Text(
//                         title,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF2D241E),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatDate(lastModified),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 11.5,
//                           color: Color(0xFF7A6248),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Outside quick-favorite button in top-right corner
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: IconButton(
//                   visualDensity: VisualDensity.compact,
//                   tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
//                   onPressed: onToggleFavorite,
//                   icon: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 200),
//                     transitionBuilder: (child, anim) =>
//                         ScaleTransition(scale: anim, child: child),
//                     child: Icon(
//                       isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
//                       key: ValueKey<bool>(isFavorite),
//                       color: isFavorite
//                           ? const Color(0xFFD97706)
//                           : const Color(0xFF8C6D4F).withValues(alpha: 0.7),
//                       size: 22,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectVisual() {
//     if (customImageUrl != null && customImageUrl!.trim().isNotEmpty) {
//       return Container(
//         width: 64,
//         height: 64,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0xFF8C6D4F).withValues(alpha: 0.3)),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Image.network(
//           customImageUrl!,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _buildMinimalistFolderWithPapers(),
//         ),
//       );
//     }

//     if (coverColorValue != null) {
//       final color = Color(coverColorValue!);
//       return Container(
//         width: 64,
//         height: 64,
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.22),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
//         ),
//         child: Center(
//           child: Icon(
//             Icons.auto_stories_outlined,
//             color: color,
//             size: 32,
//           ),
//         ),
//       );
//     }

//     return _buildMinimalistFolderWithPapers();
//   }

//   /// Minimalistic folder with stacked papers icon matching the hand-drawn sketch
//   Widget _buildMinimalistFolderWithPapers() {
//     return SizedBox(
//       width: 64,
//       height: 60,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Back paper sheet (tilted left)
//           Positioned(
//             top: 4,
//             left: 14,
//             child: Transform.rotate(
//               angle: -0.12,
//               child: Container(
//                 width: 28,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFFDF9),
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: const Color(0xFF5C4430), width: 1.3),
//                 ),
//               ),
//             ),
//           ),
//           // Middle paper sheet (tilted right)
//           Positioned(
//             top: 3,
//             right: 14,
//             child: Transform.rotate(
//               angle: 0.10,
//               child: Container(
//                 width: 28,
//                 height: 34,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF7EB),
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: const Color(0xFF5C4430), width: 1.3),
//                 ),
//               ),
//             ),
//           ),
//           // Front folder body
//           Positioned(
//             bottom: 4,
//             child: Container(
//               width: 48,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3C186),
//                 borderRadius: BorderRadius.circular(7),
//                 border: Border.all(color: const Color(0xFF4A3728), width: 1.5),
//               ),
//               child: Center(
//                 child: Container(
//                   width: 22,
//                   height: 2,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF4A3728).withValues(alpha: 0.45),
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }