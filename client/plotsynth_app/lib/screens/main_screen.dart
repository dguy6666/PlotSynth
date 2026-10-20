// import 'package:flutter/material.dart';
// import 'project_workspace_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Projects'),
//         actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search)),
//         IconButton(onPressed: () {}, icon: Icon(Icons.sync)),
//         IconButton(onPressed: () {}, icon: Icon(Icons.account_box))],
//       ),
//       drawer: Drawer(
//         child: SafeArea(child: 
//         Column(
//           children: const [
//             ListTile(leading: Icon(Icons.sort_by_alpha),title: Text("Sort By A-Z"),),
//             ListTile(leading: Icon(Icons.sort),title: Text("Sort By Last Modified"),),
//             Divider(),
//             ListTile(leading: Icon(Icons.settings),title: Text("Settings"),)
//           ]
//         )
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           itemCount: 6, // Number of items to test
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2, // 2 columns (must be an integer)
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//             childAspectRatio: 1.0, // 1.0 makes each card a square
//           ),
//           itemBuilder: (context, index) {
//             return Card(
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ProjectWorkspaceScreen(),
//                         ),
//                       );
//                 },
//                 child: Text('Project $index'),
//               ),
//             );
//           },
//         ),
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../widgets/add_new_project_card.dart';
import '../widgets/project_card.dart';
import 'project_workspace_screen.dart';
import 'settings_screen.dart';

enum ProjectSortMode { lastModified, nameAZ, favoritesFirst }

enum ProjectFilterMode { all, favoritesOnly, customCoverOnly }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _appVersion = 'v0.4.0-beta';
  static bool _tutorialShownThisSession = false;

  ProjectSortMode _sortMode = ProjectSortMode.lastModified;
  ProjectFilterMode _filterMode = ProjectFilterMode.all;
  String _searchQuery = '';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  // Settings & Cloud state (No login required, optional cloud login)
  bool _offlineModeOnly = true;
  bool _aesEncryptionEnabled = true;
  bool _showMlLoadingTips = true;
  String? _loggedInEmail;

  late final List<ProjectData> _projects;

  @override
  void initState() {
    super.initState();
    _projects = [
      ProjectData(
        id: 'proj_1',
        name: 'Chronicles of Verath',
        lastModified: DateTime.now().subtract(const Duration(minutes: 25)),
        isFavorite: true,
        ideasText:
            'Kaelen Vance has amber-gold eyes after surviving the Eclipse ritual.\nAetherium magic cannot be channeled near cold iron.',
        savedIdeasSnapshots: [
          'Initial world seed: Kaelen Vance and the Citadel of Verath.',
        ],
        learnedFacts: [
          NarrativeFact(
            id: 'f1',
            subject: 'Kaelen Vance',
            predicate: 'eye color',
            objectValue: 'Amber-gold',
            category: 'Character',
            chapterSpan: 'Ch. 1+',
          ),
          NarrativeFact(
            id: 'f2',
            subject: 'Aetherium Magic',
            predicate: 'world rule',
            objectValue: 'Nullified by cold iron contact',
            category: 'World Rule',
            chapterSpan: 'Global',
          ),
        ],
        customLoreWords: [
          const DictionaryEntry(
            word: 'Aetherium',
            partOfSpeech: 'Magic Substance',
            definition: 'Crystalline resonance drawn from post-Eclipse ley lines.',
            isCustomLore: true,
          ),
          const DictionaryEntry(
            word: 'Verath',
            partOfSpeech: 'Location',
            definition: 'The northern mountain citadel governing the Silent Treaty.',
            isCustomLore: true,
          ),
        ],
      ),
      ProjectData(
        id: 'proj_2',
        name: 'The Glass Meridian',
        lastModified: DateTime.now().subtract(const Duration(hours: 6)),
        isFavorite: false,
        coverColorValue: 0xFF2B6CB0,
        ideasText: 'A clockwork archipelago where tides shift every four hours.',
      ),
      ProjectData(
        id: 'proj_3',
        name: 'Ashes of Solitude',
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        isFavorite: false,
        ideasText: 'Detective noir set in a subterranean dome colony.',
      ),
    ];

    // Show welcome tutorial automatically on first opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tutorialShownThisSession && mounted) {
        _tutorialShownThisSession = true;
        _showWelcomeTutorialDialog();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjectData> get _filteredAndSortedProjects {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _projects.where((p) {
      if (_filterMode == ProjectFilterMode.favoritesOnly && !p.isFavorite) {
        return false;
      }
      if (_filterMode == ProjectFilterMode.customCoverOnly &&
          p.customImageUrl == null &&
          p.coverColorValue == null) {
        return false;
      }
      if (query.isNotEmpty) {
        final inName = p.name.toLowerCase().contains(query);
        final inIdeas = p.ideasText.toLowerCase().contains(query);
        return inName || inIdeas;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (_sortMode == ProjectSortMode.favoritesFirst) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
      }
      if (_sortMode == ProjectSortMode.nameAZ) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return b.lastModified.compareTo(a.lastModified);
    });

    return filtered;
  }

  void _showWelcomeTutorialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: Color(0xFF8C5A2B)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome to PlotSynth',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your zero-generation narrative continuity workstation:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text('• Tap "+" to create a new story project.'),
            SizedBox(height: 6),
            Text(
              '• Long-press or right-click any project card to Rename, Add Image, Favorite, or Delete.',
            ),
            SizedBox(height: 6),
            Text(
              '• Inside a project, you start on the Ideas tab. Swipe left/right or tap bottom tabs (which expand 50% when active).',
            ),
            SizedBox(height: 6),
            Text(
              '• Tap "Analyze" to detect narrative facts and review/edit them before adding to your Canon Editor.',
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF3B34C),
              foregroundColor: const Color(0xFF2D241E),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Start Writing',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewProjectDialog() async {
    final nameCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7EB),
        title: const Text('New Project'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Project Title',
            hintText: 'e.g., The Obsidian Crown',
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF3B34C),
              foregroundColor: const Color(0xFF2D241E),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created == true) {
      final title =
          nameCtrl.text.trim().isEmpty ? 'Project ${_projects.length + 1}' : nameCtrl.text.trim();
      final newProj = ProjectData(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        name: title,
        lastModified: DateTime.now(),
      );
      setState(() => _projects.insert(0, newProj));
      if (mounted) {
        _openProjectWorkspace(newProj);
      }
    }
  }

  Future<void> _renameProjectDialog(ProjectData project) async {
    final nameCtrl = TextEditingController(text: project.name);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7EB),
        title: const Text('Rename Project'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New Project Name'),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF3B34C),
              foregroundColor: const Color(0xFF2D241E),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      setState(() {
        project.name = nameCtrl.text.trim();
        project.lastModified = DateTime.now();
      });
    }
  }

  Future<void> _changeProjectImageDialog(ProjectData project) async {
    final urlCtrl = TextEditingController(text: project.customImageUrl ?? '');
    int? chosenColor = project.coverColorValue;

    const palette = <int>[
      0xFF8C5A2B,
      0xFF2B6CB0,
      0xFF2F855A,
      0xFF9B2C2C,
      0xFF6B46C1,
      0xFFB7791F,
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF7EB),
          title: const Text('Project Cover Image / Icon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/cover.png',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Or pick a custom emblem color:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  for (final hex in palette)
                    GestureDetector(
                      onTap: () => setModalState(() {
                        chosenColor = hex;
                        urlCtrl.clear();
                      }),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: chosenColor == hex ? Colors.black : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setModalState(() {
                    chosenColor = null;
                    urlCtrl.clear();
                  });
                },
                icon: const Icon(Icons.restore_rounded, size: 18),
                label: const Text('Reset to Default Folder + Papers Icon'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF3B34C),
                foregroundColor: const Color(0xFF2D241E),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() {
        project.customImageUrl = urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim();
        project.coverColorValue = chosenColor;
        project.lastModified = DateTime.now();
      });
    }
  }

  Future<void> _confirmDeleteProject(ProjectData project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7EB),
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to permanently delete "${project.name}" and all of its learned facts, ideas, and story chapters?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _projects.removeWhere((p) => p.id == project.id));
    }
  }

  void _showAccountCloudSheet() {
    final emailCtrl = TextEditingController(text: _loggedInEmail ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF7EB),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4C5EC),
                  child: Icon(
                    _loggedInEmail == null ? Icons.person_outline : Icons.cloud_done_rounded,
                    color: const Color(0xFF2D241E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loggedInEmail == null ? 'Local Guest Mode' : 'Cloud Account Active',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _loggedInEmail ??
                            'No login required. Sign in optionally to back up to Supabase Cloud.',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF6E4720)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loggedInEmail == null) ...[
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email for Optional Cloud Backup',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF3B34C),
                    foregroundColor: const Color(0xFF2D241E),
                  ),
                  onPressed: () {
                    if (emailCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _loggedInEmail = emailCtrl.text.trim();
                        _offlineModeOnly = false;
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Connect Cloud Backup'),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _loggedInEmail = null;
                      _offlineModeOnly = true;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Switch Back to Offline Guest Mode'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openProjectWorkspace(ProjectData project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectWorkspaceScreen(
          project: project,
          showMlLoadingTips: _showMlLoadingTips,
          onProjectUpdated: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleProjects = _filteredAndSortedProjects;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Projects'),
        actions: [
          IconButton(
            tooltip: 'Search & Filter Projects',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded),
          ),
          IconButton(
            tooltip: _offlineModeOnly
                ? 'Offline SQLite Storage Active'
                : 'Cloud Sync Connected',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    _offlineModeOnly
                        ? 'Local SQLite Database synced (${_projects.length} projects saved offline).'
                        : 'Synced with Supabase PostgreSQL Cloud (${_loggedInEmail ?? "Account"}).',
                  ),
                ),
              );
            },
            icon: Icon(_offlineModeOnly ? Icons.sync_rounded : Icons.cloud_done_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: _showAccountCloudSheet,
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4C5EC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2D241E), width: 1.5),
                ),
                child: Icon(
                  _loggedInEmail == null ? Icons.diamond_outlined : Icons.check_rounded,
                  size: 18,
                  color: const Color(0xFF2D241E),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF7EB),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'PlotSynth Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D241E),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_rounded),
                title: const Text('Name (A-Z)'),
                selected: _sortMode == ProjectSortMode.nameAZ,
                trailing: _sortMode == ProjectSortMode.nameAZ
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() => _sortMode = ProjectSortMode.nameAZ);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Last Modified'),
                selected: _sortMode == ProjectSortMode.lastModified,
                trailing: _sortMode == ProjectSortMode.lastModified
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() => _sortMode = ProjectSortMode.lastModified);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: const Text('Favorites First'),
                selected: _sortMode == ProjectSortMode.favoritesFirst,
                trailing: _sortMode == ProjectSortMode.favoritesFirst
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() => _sortMode = ProjectSortMode.favoritesFirst);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Welcome Tutorial'),
                onTap: () {
                  Navigator.pop(context);
                  _showWelcomeTutorialDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        offlineModeOnly: _offlineModeOnly,
                        aesEncryptionEnabled: _aesEncryptionEnabled,
                        showMlLoadingTips: _showMlLoadingTips,
                        onOfflineModeChanged: (v) => setState(() => _offlineModeOnly = v),
                        onEncryptionChanged: (v) =>
                            setState(() => _aesEncryptionEnabled = v),
                        onShowMlTipsChanged: (v) =>
                            setState(() => _showMlLoadingTips = v),
                        onReplayTutorial: _showWelcomeTutorialDialog,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'PlotSynth $_appVersion',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A6248),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Expandable Search + Filters bar
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _isSearchVisible
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Search projects or ideas...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.clear_rounded),
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFFFFDF9),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2BE96)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: _filterMode == ProjectFilterMode.all,
                                selectedColor: const Color(0xFFF3B34C),
                                onSelected: (_) =>
                                    setState(() => _filterMode = ProjectFilterMode.all),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('★ Favorites'),
                                selected: _filterMode == ProjectFilterMode.favoritesOnly,
                                selectedColor: const Color(0xFFF3B34C),
                                onSelected: (_) => setState(
                                  () => _filterMode = ProjectFilterMode.favoritesOnly,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Custom Cover'),
                                selected: _filterMode == ProjectFilterMode.customCoverOnly,
                                selectedColor: const Color(0xFFF3B34C),
                                onSelected: (_) => setState(
                                  () => _filterMode = ProjectFilterMode.customCoverOnly,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Responsive GridView for Phones, Tablets, and Web
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int columns = 2;
                  if (constraints.maxWidth >= 900) {
                    columns = 4;
                  } else if (constraints.maxWidth >= 600) {
                    columns = 3;
                  }

                  return GridView.builder(
                    itemCount: visibleProjects.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      // Index 0 returns AddNewProjectCard; Index > 0 returns ProjectCard for index - 1
                      if (index == 0) {
                        return AddNewProjectCard(
                          onTap: _createNewProjectDialog,
                        );
                      }

                      final project = visibleProjects[index - 1];
                      return ProjectCard(
                        title: project.name,
                        lastModified: project.lastModified,
                        isFavorite: project.isFavorite,
                        customImageUrl: project.customImageUrl,
                        coverColorValue: project.coverColorValue,
                        onTap: () => _openProjectWorkspace(project),
                        onToggleFavorite: () {
                          setState(() => project.isFavorite = !project.isFavorite);
                        },
                        onRename: () => _renameProjectDialog(project),
                        onChangeImage: () => _changeProjectImageDialog(project),
                        onDelete: () => _confirmDeleteProject(project),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Bottom Version Number Footer on MainScreen
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Text(
                'PlotSynth $_appVersion • ${_offlineModeOnly ? "Offline SQLite Mode" : "Cloud Sync Active"}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF8C6D4F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}