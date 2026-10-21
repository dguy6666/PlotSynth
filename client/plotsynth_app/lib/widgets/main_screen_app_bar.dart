import 'package:flutter/material.dart';
import '../models/project_sort.dart';

class MainScreenAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ProjectSortOption currentSort;
  final ValueChanged<ProjectSortOption> onSortSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSyncPressed;
  final VoidCallback onProfilePressed;

  const MainScreenAppBar({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
    required this.onSearchChanged,
    required this.onSyncPressed,
    required this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 80.0);

  @override
  State<MainScreenAppBar> createState() => _MainScreenAppBarState();
}

class _MainScreenAppBarState extends State<MainScreenAppBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
  }

@override
Widget build(BuildContext context) {
  const double bottomHeight = 100.0;

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    // Places the text directly between the drawer hamburger icon and the actions
    title: const Text(
      'Projects',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.sync_rounded),
        tooltip: 'Sync',
        onPressed: widget.onSyncPressed,
      ),
      IconButton(
        icon: const CircleAvatar(
          radius: 14,
          child: Icon(Icons.person, size: 18),
        ),
        tooltip: 'Profile',
        onPressed: widget.onProfilePressed,
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(bottomHeight),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Search Bar
            SearchBar(
              hintText: 'Search projects...',
              constraints: const BoxConstraints(minHeight: 38.0, maxHeight: 46.0),
              leading: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search, size: 20),
              ),
              trailing: _searchController.text.isNotEmpty
              ? [
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                  ),
                ]
              : null,
              onChanged: widget.onSearchChanged,
              elevation: const WidgetStatePropertyAll(0.5),
            ),
            const SizedBox(height: 10),

            // Row 3: Filter / Sort Chips (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: const Text('Favorites'),
                    selected: widget.currentSort == ProjectSortOption.favoritesOnly,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onSortSelected(ProjectSortOption.favoritesOnly);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.sort_by_alpha, size: 16),
                    label: const Text('A-Z'),
                    selected: widget.currentSort == ProjectSortOption.nameAZ,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onSortSelected(ProjectSortOption.nameAZ);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: const Text('Last Modified'),
                    selected: widget.currentSort == ProjectSortOption.lastModified,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onSortSelected(ProjectSortOption.lastModified);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}