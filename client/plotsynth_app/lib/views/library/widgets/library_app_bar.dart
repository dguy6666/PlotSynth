import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/sort_option.dart';


class LibraryAppBar extends StatefulWidget implements PreferredSizeWidget {
  final SortOption currentSort;
  final bool isAscending;
  final bool isFavoritesOnly;
  final VoidCallback onToggleFavorites;
  final ValueChanged<SortOption> onSortSelected;
  final VoidCallback onSortOrderToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSyncPressed;
  final VoidCallback onProfilePressed;

  const LibraryAppBar({
    super.key,
    required this.currentSort,
    required this.isAscending,
    required this.isFavoritesOnly,
    required this.onToggleFavorites,
    required this.onSortSelected,
    required this.onSortOrderToggle,
    required this.onSearchChanged,
    required this.onSyncPressed,
    required this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 80.0);

  @override
  State<LibraryAppBar> createState() => _LibraryAppBarState();
}

class _LibraryAppBarState extends State<LibraryAppBar> {
  final SearchController _searchController = SearchController();

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
              controller: _searchController,
              hintText: 'Search projects...',
              constraints: const BoxConstraints(minHeight: 38.0, maxHeight: 46.0),
              leading: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.search, size: 20),
              ),
              trailing: [
                // 2. Vertical dividing line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: SizedBox(
                    height: 20.0,
                    child: VerticalDivider(
                      width: 1.0,
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    tooltip: 'Clear search',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _clearSearch,
                  ),
                
              ],
              onChanged: widget.onSearchChanged,
              elevation: const WidgetStatePropertyAll(0.5),
            ),
            const SizedBox(height: 10),

            // Row 3: Filter / Sort Chips (Horizontal Scroll)
            Row(
                children: [
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: const Text('Favorites'),
                    selected: widget.isFavoritesOnly,
                    selectedColor: Theme.of(context).disabledColor,
                    onSelected: (selected) {
                      widget.onToggleFavorites();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: const Text('Last Modified'),
                    selected: widget.currentSort == SortOption.date,
                    selectedColor: Theme.of(context).disabledColor,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onSortSelected(SortOption.date);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    showCheckmark: false,
                    avatar: const Icon(Icons.sort_by_alpha, size: 16),
                    label: const Text('A-Z'),
                    selected: widget.currentSort == SortOption.name,
                    selectedColor: Theme.of(context).disabledColor,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onSortSelected(SortOption.name);
                      }
                    },
                  ),

                  const Spacer(),

                  // 3. Borderless chip that only shows its shape/color on hover:
                  ActionChip(
                    onPressed: widget.onSortOrderToggle,
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: Colors.transparent, // Invisible background at rest
                    side: BorderSide.none,                // Removes the outline border completely
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isAscending ? 'Ascending' : 'Descending',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          widget.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
           ]
            ),
            
          
        ),
      ),
    );
  
}
}