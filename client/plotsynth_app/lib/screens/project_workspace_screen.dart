// import 'package:flutter/material.dart';


// class ProjectWorkspaceScreen extends StatefulWidget {
//   const ProjectWorkspaceScreen({super.key});

//   @override
//   State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
// }

// class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
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
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Represents a canonical narrative fact learned or added to the Editor tab.
class NarrativeFact {
  String id;
  String subject;
  String predicate;
  String objectValue;
  String category; // 'Character', 'World Rule', 'Location', 'Chronology'
  String chapterSpan;

  NarrativeFact({
    required this.id,
    required this.subject,
    required this.predicate,
    required this.objectValue,
    this.category = 'Character',
    this.chapterSpan = 'Ch. 1+',
  });

  NarrativeFact copy() => NarrativeFact(
        id: id,
        subject: subject,
        predicate: predicate,
        objectValue: objectValue,
        category: category,
        chapterSpan: chapterSpan,
      );

  String get formattedAssertion => '$subject — $predicate: $objectValue';
}

/// Represents a dictionary entry (either standard English or custom story lore).
class DictionaryEntry {
  final String word;
  final String partOfSpeech;
  final String definition;
  final bool isCustomLore;

  const DictionaryEntry({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    this.isCustomLore = false,
  });
}

/// Prefix Tree (Trie) node for O(L) real-time dictionary word lookup.
class _TrieNode {
  final Map<String, _TrieNode> children = {};
  final List<DictionaryEntry> entries = [];
}

class LoreTrie {
  final _TrieNode _root = _TrieNode();

  void clear() => _root.children.clear();

  void insert(DictionaryEntry entry) {
    _TrieNode current = _root;
    final key = entry.word.toLowerCase();
    for (int i = 0; i < key.length; i++) {
      final ch = key[i];
      current = current.children.putIfAbsent(ch, () => _TrieNode());
    }
    current.entries.add(entry);
  }

  List<DictionaryEntry> searchPrefix(String prefix) {
    _TrieNode current = _root;
    final clean = prefix.trim().toLowerCase();
    for (int i = 0; i < clean.length; i++) {
      final ch = clean[i];
      if (!current.children.containsKey(ch)) {
        return [];
      }
      current = current.children[ch]!;
    }
    final results = <DictionaryEntry>[];
    _collect(current, results);
    return results;
  }

  void _collect(_TrieNode node, List<DictionaryEntry> acc) {
    acc.addAll(node.entries);
    final sortedKeys = node.children.keys.toList()..sort();
    for (final k in sortedKeys) {
      _collect(node.children[k]!, acc);
    }
  }
}

/// Shared project entity passed from MainScreen to ProjectWorkspaceScreen.
class ProjectData {
  final String id;
  String name;
  DateTime lastModified;
  bool isFavorite;
  String? customImageUrl;
  int? coverColorValue;
  String ideasText;
  List<String> savedIdeasSnapshots;
  Map<String, String> chaptersText;
  String activeChapter;
  List<NarrativeFact> learnedFacts;
  List<DictionaryEntry> customLoreWords;

  ProjectData({
    required this.id,
    required this.name,
    required this.lastModified,
    this.isFavorite = false,
    this.customImageUrl,
    this.coverColorValue,
    this.ideasText = '',
    List<String>? savedIdeasSnapshots,
    Map<String, String>? chaptersText,
    this.activeChapter = 'Chapter 1',
    List<NarrativeFact>? learnedFacts,
    List<DictionaryEntry>? customLoreWords,
  })  : savedIdeasSnapshots = savedIdeasSnapshots ?? [],
        chaptersText = chaptersText ??
            {
              'Chapter 1': '',
              'Chapter 2': '',
              'Chapter 3': '',
            },
        learnedFacts = learnedFacts ?? [],
        customLoreWords = customLoreWords ?? [];
}

class ProjectWorkspaceScreen extends StatefulWidget {
  final ProjectData? project;
  final bool showMlLoadingTips;
  final VoidCallback? onProjectUpdated;

  const ProjectWorkspaceScreen({
    super.key,
    this.project,
    this.showMlLoadingTips = true,
    this.onProjectUpdated,
  });

  @override
  State<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends State<ProjectWorkspaceScreen> {
  late final ProjectData _project;
  late final PageController _pageController;

  // Default tab is index 2 ('Ideas') as specified in the design
  int _currentTabIndex = 2;
  int _newlyAddedFactsBadge = 0;

  @override
  void initState() {
    super.initState();
    _project = widget.project ??
        ProjectData(
          id: 'default',
          name: 'Untitled Project',
          lastModified: DateTime.now(),
        );
    _pageController = PageController(initialPage: _currentTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _touchProject() {
    _project.lastModified = DateTime.now();
    widget.onProjectUpdated?.call();
  }

  void _switchToTab(int index) {
    if (_currentTabIndex == index) return;
    setState(() {
      _currentTabIndex = index;
      if (index == 1) {
        _newlyAddedFactsBadge = 0;
      }
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Opens the 3-stage Analyze Modal matching the hand-drawn sketch:
  /// 1. Initial loading state
  /// 2. "Changes detected:" view with minimalistic top-left pencil edit button, Cancel, and Add changes
  /// 3. Brief loading when adding changes, then closes directly without a second popup
  Future<void> _openAnalyzeModal(String sourceText, {required String sourceLabel}) async {
    final extracted = _extractFactsFromText(sourceText, sourceLabel: sourceLabel);

    final added = await showDialog<List<NarrativeFact>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AnalyzeChangesDialog(
        initialFacts: extracted,
        showLoadingTip: widget.showMlLoadingTips,
      ),
    );

    if (added != null && added.isNotEmpty && mounted) {
      setState(() {
        _project.learnedFacts.addAll(added);
        _newlyAddedFactsBadge += added.length;
        _touchProject();
      });
    }
  }

  List<NarrativeFact> _extractFactsFromText(String rawText, {required String sourceLabel}) {
    final results = <NarrativeFact>[];
    final clean = rawText.trim();
    final rng = Random();

    if (clean.isNotEmpty) {
      final sentences = clean
          .split(RegExp(r'[.!?;\n]+'))
          .map((s) => s.trim())
          .where((s) => s.length > 6)
          .toList();

      for (final sentence in sentences.take(3)) {
        final lower = sentence.toLowerCase();
        if (lower.contains(' has ') || lower.contains(' have ')) {
          final parts = sentence.split(RegExp(r'\s+ha(s|ve)\s+', caseSensitive: false));
          if (parts.length >= 2) {
            results.add(
              NarrativeFact(
                id: 'fact_${DateTime.now().microsecondsSinceEpoch}_${results.length}',
                subject: parts[0].trim(),
                predicate: 'possesses attribute',
                objectValue: parts.sublist(1).join(' ').trim(),
                category: 'Character',
                chapterSpan: sourceLabel,
              ),
            );
            continue;
          }
        }
        if (lower.contains(' is in ') || lower.contains(' traveled to ') || lower.contains(' lives in ')) {
          results.add(
            NarrativeFact(
              id: 'fact_${DateTime.now().microsecondsSinceEpoch}_${results.length}',
              subject: sentence.split(' ').take(2).join(' '),
              predicate: 'located at',
              objectValue: sentence,
              category: 'Location',
              chapterSpan: sourceLabel,
            ),
          );
          continue;
        }
        if (lower.contains('cannot') || lower.contains('must') || lower.contains('magic') || lower.contains('rule')) {
          results.add(
            NarrativeFact(
              id: 'fact_${DateTime.now().microsecondsSinceEpoch}_${results.length}',
              subject: 'World Canon',
              predicate: 'enforces rule',
              objectValue: sentence,
              category: 'World Rule',
              chapterSpan: 'Global',
            ),
          );
          continue;
        }
      }
    }

    // Fallback sample facts (as requested: "analyze would just add random facts to editor in pop up window")
    final samplePool = <NarrativeFact>[
      NarrativeFact(
        id: 'fact_${DateTime.now().microsecondsSinceEpoch}_a',
        subject: 'Kaelen Vance',
        predicate: 'eye color',
        objectValue: 'Amber-gold (shifted after the Eclipse ritual)',
        category: 'Character',
        chapterSpan: sourceLabel,
      ),
      NarrativeFact(
        id: 'fact_${DateTime.now().microsecondsSinceEpoch}_b',
        subject: 'Aetherium Casting',
        predicate: 'world constraint',
        objectValue: 'Cannot be channeled while touching cold iron',
        category: 'World Rule',
        chapterSpan: 'Global',
      ),
      NarrativeFact(
        id: 'fact_${DateTime.now().microsecondsSinceEpoch}_c',
        subject: 'Citadel of Verath',
        predicate: 'travel distance',
        objectValue: '4 days north of the Glass Marsh by horseback',
        category: 'Location',
        chapterSpan: sourceLabel,
      ),
      NarrativeFact(
        id: 'fact_${DateTime.now().microsecondsSinceEpoch}_d',
        subject: 'The Silent Treaty',
        predicate: 'chronological anchor',
        objectValue: 'Signed 14 years prior to Chapter 1 opening',
        category: 'Chronology',
        chapterSpan: sourceLabel,
      ),
      NarrativeFact(
        id: 'fact_${DateTime.now().microsecondsSinceEpoch}_e',
        subject: 'Lyra Thorne',
        predicate: 'carries artifact',
        objectValue: 'Silver compass with a cracked meridian ring',
        category: 'Character',
        chapterSpan: sourceLabel,
      ),
    ];

    while (results.length < 3) {
      final candidate = samplePool[rng.nextInt(samplePool.length)].copy();
      candidate.id = 'fact_${DateTime.now().microsecondsSinceEpoch}_${results.length}';
      if (!results.any((r) => r.objectValue == candidate.objectValue)) {
        results.add(candidate);
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_project.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFD9534F),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2D241E), width: 1.5),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentTabIndex = index;
            if (index == 1) {
              _newlyAddedFactsBadge = 0;
            }
          });
        },
        children: [
          _TimelineTabView(project: _project),
          _EditorTabView(
            project: _project,
            onChanged: () => setState(_touchProject),
          ),
          _IdeasTabView(
            project: _project,
            onSaved: _touchProject,
            onAnalyzeRequested: (text) => _openAnalyzeModal(text, sourceLabel: 'Ideas Draft'),
          ),
          _StoryTabView(
            project: _project,
            onSaved: _touchProject,
            onAnalyzeRequested: (text, chapter) =>
                _openAnalyzeModal(text, sourceLabel: chapter),
          ),
          _DictionaryTabView(
            project: _project,
            onChanged: () => setState(_touchProject),
          ),
        ],
      ),
      bottomNavigationBar: _buildExpandingBottomTabBar(),
    );
  }

  /// Bottom navigation bar with 5 tabs (Timeline, Editor, Ideas, Story, Dictionary)
  /// When a tab is selected, it smoothly expands by 50% (flex 15 vs 10 + scale animation)
  Widget _buildExpandingBottomTabBar() {
    const items = <_BottomTabSpec>[
      _BottomTabSpec(label: 'Timeline', icon: Icons.timeline_rounded),
      _BottomTabSpec(label: 'Editor', icon: Icons.edit_outlined),
      _BottomTabSpec(label: 'Ideas', icon: Icons.lightbulb_outline_rounded),
      _BottomTabSpec(label: 'Story', icon: Icons.menu_book_rounded),
      _BottomTabSpec(label: 'Dictionary', icon: Icons.book_outlined),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EB),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(items.length, (index) {
            final isSelected = _currentTabIndex == index;
            final spec = items[index];
            final showBadge = index == 1 && _newlyAddedFactsBadge > 0;

            // Active tab takes 1.5x the width (50% bigger) of inactive tabs
            return Expanded(
              flex: isSelected ? 15 : 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: GestureDetector(
                  onTap: () => _switchToTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF3B34C)
                          : const Color(0xFFFADBB8),
                      borderRadius: BorderRadius.circular(isSelected ? 18 : 14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A3728)
                            : const Color(0xFFE2BE96),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.22 : 0.92,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutBack,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                spec.icon,
                                size: isSelected ? 24 : 20,
                                color: const Color(0xFF2D241E),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                spec.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSelected ? 11.5 : 10,
                                  fontWeight:
                                      isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: const Color(0xFF2D241E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showBadge)
                          Positioned(
                            top: 4,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB91C1C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+$_newlyAddedFactsBadge',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomTabSpec {
  final String label;
  final IconData icon;
  const _BottomTabSpec({required this.label, required this.icon});
}

// ============================================================================
// ANALYZE MODAL WINDOW (Matches Sketch: Loading -> Changes Detected + Pencil Edit -> Add Changes Loading)
// ============================================================================

class _AnalyzeChangesDialog extends StatefulWidget {
  final List<NarrativeFact> initialFacts;
  final bool showLoadingTip;

  const _AnalyzeChangesDialog({
    required this.initialFacts,
    required this.showLoadingTip,
  });

  @override
  State<_AnalyzeChangesDialog> createState() => _AnalyzeChangesDialogState();
}

enum _AnalyzeStage { scanning, reviewChanges, committing }

class _AnalyzeChangesDialogState extends State<_AnalyzeChangesDialog> {
  _AnalyzeStage _stage = _AnalyzeStage.scanning;
  bool _isEditMode = false;
  late List<NarrativeFact> _editableFacts;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _editableFacts = widget.initialFacts.map((f) => f.copy()).toList();
    _controllers = _editableFacts
        .map((f) => TextEditingController(text: f.formattedAssertion))
        .toList();

    // Stage 1 -> Stage 2 after simulated NLP / ML extraction
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) {
        setState(() => _stage = _AnalyzeStage.reviewChanges);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllersToFacts() {
    for (int i = 0; i < _editableFacts.length; i++) {
      final raw = _controllers[i].text.trim();
      if (raw.isEmpty) continue;
      final dashParts = raw.split('—');
      if (dashParts.length >= 2) {
        _editableFacts[i].subject = dashParts[0].trim();
        final rest = dashParts.sublist(1).join('—').trim();
        final colonParts = rest.split(':');
        if (colonParts.length >= 2) {
          _editableFacts[i].predicate = colonParts[0].trim();
          _editableFacts[i].objectValue = colonParts.sublist(1).join(':').trim();
        } else {
          _editableFacts[i].objectValue = rest;
        }
      } else {
        _editableFacts[i].objectValue = raw;
      }
    }
  }

  Future<void> _handleAddChanges() async {
    _syncControllersToFacts();
    setState(() => _stage = _AnalyzeStage.committing);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      Navigator.of(context).pop(_editableFacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF6C995),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF2D241E), width: 1.8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, minHeight: 360),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildStageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    if (_stage == _AnalyzeStage.scanning) {
      return Column(
        key: const ValueKey('scanning'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 36),
          const CircularProgressIndicator(
            color: Color(0xFF4A3728),
            strokeWidth: 3,
          ),
          const SizedBox(height: 22),
          const Text(
            'Scanning draft for narrative facts...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D241E),
            ),
          ),
          if (widget.showLoadingTip) ...[
            const SizedBox(height: 12),
            const Text(
              'Tip: PlotSynth extracts Character Attributes, World Rules, Locations, and Timeline spans without generating or altering your prose.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF5C4430),
              ),
            ),
          ],
          const SizedBox(height: 36),
        ],
      );
    }

    if (_stage == _AnalyzeStage.committing) {
      return const Column(
        key: ValueKey('committing'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 48),
          CircularProgressIndicator(
            color: Color(0xFF4A3728),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Adding changes to Editor Canon...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D241E),
            ),
          ),
          SizedBox(height: 48),
        ],
      );
    }

    // Stage 2: Review detected changes (matches sketch layout)
    return Column(
      key: const ValueKey('review'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Changes detected:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D241E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 220, maxHeight: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFADBB8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2D241E), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-left minimalistic pencil edit button as drawn in the sketch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (_isEditMode) _syncControllersToFacts();
                      setState(() => _isEditMode = !_isEditMode);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isEditMode
                            ? const Color(0xFFF3B34C)
                            : const Color(0xFFF6C995),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2D241E), width: 1.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF2D241E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEditMode ? 'Done' : 'Edit',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D241E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '${_editableFacts.length} facts extracted',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E4720),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _editableFacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final fact = _editableFacts[idx];
                    if (_isEditMode) {
                      return TextField(
                        controller: _controllers[idx],
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF2D241E)),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFFFF7EB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7EB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2BE96)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3B34C).withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              fact.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A3728),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fact.formattedAssertion,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D241E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D241E),
                  backgroundColor: const Color(0xFFFADBB8),
                  side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleAddChanges,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D241E),
                  backgroundColor: const Color(0xFFF3B34C),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add changes',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 0: TIMELINE TAB VIEW (3 View Modes, Database-Ready)
// ============================================================================

class _TimelineTabView extends StatefulWidget {
  final ProjectData project;
  const _TimelineTabView({required this.project});

  @override
  State<_TimelineTabView> createState() => _TimelineTabViewState();
}

class _TimelineTabViewState extends State<_TimelineTabView>
    with AutomaticKeepAliveClientMixin {
  int _selectedMode = 0; // 0: Chronological, 1: Character Lanes, 2: Chapter Matrix

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chronologyFacts = widget.project.learnedFacts;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3 Timeline Modes Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFADBB8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2BE96)),
            ),
            child: Row(
              children: [
                _buildModeButton(0, 'Chronological', Icons.linear_scale_rounded),
                _buildModeButton(1, 'Character Arcs', Icons.people_outline_rounded),
                _buildModeButton(2, 'Chapter Grid', Icons.grid_view_rounded),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2C6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6C88A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.storage_rounded, size: 18, color: Color(0xFF8C5A2B)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Timeline Engine (3 Models) — Ready for SQLite / PostgreSQL temporal span binding.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E4720),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _buildModeBody(chronologyFacts),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(int modeIndex, String title, IconData icon) {
    final selected = _selectedMode == modeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = modeIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF3B34C) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2D241E)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF2D241E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBody(List<NarrativeFact> facts) {
    if (facts.isEmpty) {
      return const Center(
        child: Text(
          'No timeline nodes yet.\nClick "Analyze" in Ideas or Story to populate events.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF7A6248), fontSize: 14),
        ),
      );
    }

    if (_selectedMode == 0) {
      // Mode 0: Linear Chronological Chain
      return ListView.builder(
        itemCount: facts.length,
        itemBuilder: (context, index) {
          final f = facts[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3B34C),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2D241E), width: 1.5),
                    ),
                  ),
                  if (index < facts.length - 1)
                    Container(
                      width: 2,
                      height: 64,
                      color: const Color(0xFFD5A97A),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFADBB8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${f.chapterSpan} • ${f.category}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A6248),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.formattedAssertion,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D241E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    if (_selectedMode == 1) {
      // Mode 1: Character / Subject Swimlanes
      final grouped = <String, List<NarrativeFact>>{};
      for (final f in facts) {
        grouped.putIfAbsent(f.subject, () => []).add(f);
      }
      final subjects = grouped.keys.toList();
      return ListView.separated(
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final subj = subjects[i];
          final items = grouped[subj]!;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFADBB8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subj,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D241E),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map(
                        (e) => Chip(
                          backgroundColor: const Color(0xFFFFF7EB),
                          label: Text(
                            '${e.predicate}: ${e.objectValue}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      );
    }

    // Mode 2: Chapter Matrix
    final byChapter = <String, List<NarrativeFact>>{};
    for (final f in facts) {
      byChapter.putIfAbsent(f.chapterSpan, () => []).add(f);
    }
    final chapters = byChapter.keys.toList();
    return GridView.builder(
      itemCount: chapters.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, idx) {
        final ch = chapters[idx];
        final list = byChapter[ch]!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFADBB8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2BE96)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ch,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D241E),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: list
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${f.subject}: ${f.objectValue}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB 1: EDITOR TAB VIEW (Learned Facts + Edit + Save + Undo Stack + Contradiction Flag)
// ============================================================================

class _EditorTabView extends StatefulWidget {
  final ProjectData project;
  final VoidCallback onChanged;

  const _EditorTabView({
    required this.project,
    required this.onChanged,
  });

  @override
  State<_EditorTabView> createState() => _EditorTabViewState();
}

class _EditorTabViewState extends State<_EditorTabView>
    with AutomaticKeepAliveClientMixin {
  final List<List<NarrativeFact>> _undoStack = [];
  bool _savedBannerVisible = false;

  @override
  bool get wantKeepAlive => true;

  void _pushUndoSnapshot() {
    _undoStack.add(widget.project.learnedFacts.map((f) => f.copy()).toList());
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void _undoLastChange() {
    if (_undoStack.isEmpty) return;
    setState(() {
      widget.project.learnedFacts
        ..clear()
        ..addAll(_undoStack.removeLast());
    });
    widget.onChanged();
  }

  bool _hasContradiction(NarrativeFact fact) {
    return widget.project.learnedFacts.any(
      (other) =>
          other.id != fact.id &&
          other.subject.toLowerCase() == fact.subject.toLowerCase() &&
          other.predicate.toLowerCase() == fact.predicate.toLowerCase() &&
          other.objectValue.toLowerCase() != fact.objectValue.toLowerCase(),
    );
  }

  Future<void> _editOrCreateFact({NarrativeFact? existing}) async {
    final subjCtrl = TextEditingController(text: existing?.subject ?? '');
    final predCtrl = TextEditingController(text: existing?.predicate ?? '');
    final objCtrl = TextEditingController(text: existing?.objectValue ?? '');
    final spanCtrl = TextEditingController(text: existing?.chapterSpan ?? 'Ch. 1+');
    String category = existing?.category ?? 'Character';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF7EB),
          title: Text(existing == null ? 'Add Canon Fact' : 'Edit Canon Fact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Character', child: Text('Character')),
                    DropdownMenuItem(value: 'World Rule', child: Text('World Rule')),
                    DropdownMenuItem(value: 'Location', child: Text('Location')),
                    DropdownMenuItem(value: 'Chronology', child: Text('Chronology')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => category = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subjCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject (e.g., Kaelen Vance)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: predCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Attribute / Predicate (e.g., eye color)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: objCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Fact Value (e.g., Amber-gold)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: spanCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chapter Validity (e.g., Ch. 1–4)',
                  ),
                ),
              ],
            ),
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
              child: const Text('Save Fact'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && subjCtrl.text.trim().isNotEmpty) {
      _pushUndoSnapshot();
      setState(() {
        if (existing != null) {
          existing.subject = subjCtrl.text.trim();
          existing.predicate = predCtrl.text.trim();
          existing.objectValue = objCtrl.text.trim();
          existing.chapterSpan = spanCtrl.text.trim();
          existing.category = category;
        } else {
          widget.project.learnedFacts.add(
            NarrativeFact(
              id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
              subject: subjCtrl.text.trim(),
              predicate: predCtrl.text.trim().isEmpty ? 'note' : predCtrl.text.trim(),
              objectValue: objCtrl.text.trim(),
              category: category,
              chapterSpan: spanCtrl.text.trim(),
            ),
          );
        }
      });
      widget.onChanged();
    }
  }

  void _triggerInlineSaveIndicator() {
    widget.onChanged();
    setState(() => _savedBannerVisible = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _savedBannerVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final facts = widget.project.learnedFacts;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Learned Canon Facts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D241E),
                  ),
                ),
              ),
              if (_undoStack.isNotEmpty)
                IconButton(
                  tooltip: 'Undo (Stack)',
                  onPressed: _undoLastChange,
                  icon: const Icon(Icons.undo_rounded),
                ),
              OutlinedButton.icon(
                onPressed: () => _editOrCreateFact(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Fact'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D241E),
                  side: const BorderSide(color: Color(0xFF2D241E)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _triggerInlineSaveIndicator,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _savedBannerVisible ? const Color(0xFF84A98C) : const Color(0xFFF3B34C),
                  foregroundColor: const Color(0xFF2D241E),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF2D241E), width: 1.3),
                ),
                child: Text(
                  _savedBannerVisible ? 'Saved ✓' : 'Save',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: facts.isEmpty
                ? const Center(
                    child: Text(
                      'No learned facts yet.\nWrite in Ideas or Story and tap "Analyze" to populate.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7A6248)),
                    ),
                  )
                : ListView.separated(
                    itemCount: facts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final fact = facts[index];
                      final conflict = _hasContradiction(fact);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: conflict
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFFADBB8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: conflict
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFFE2BE96),
                            width: conflict ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF7EB),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${fact.category} • ${fact.chapterSpan}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6E4720),
                                          ),
                                        ),
                                      ),
                                      if (conflict) ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          '⚠ Contradiction Detected',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFB91C1C),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    fact.formattedAssertion,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D241E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Edit fact',
                              onPressed: () => _editOrCreateFact(existing: fact),
                              icon: const Icon(Icons.edit_outlined, size: 19),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Delete fact',
                              onPressed: () {
                                _pushUndoSnapshot();
                                setState(() => facts.removeAt(index));
                                widget.onChanged();
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 2: IDEAS TAB VIEW (DEFAULT TAB - Matches Sketch Yellow Editor + Analyze & Save)
// ============================================================================

class _IdeasTabView extends StatefulWidget {
  final ProjectData project;
  final VoidCallback onSaved;
  final ValueChanged<String> onAnalyzeRequested;

  const _IdeasTabView({
    required this.project,
    required this.onSaved,
    required this.onAnalyzeRequested,
  });

  @override
  State<_IdeasTabView> createState() => _IdeasTabViewState();
}

class _IdeasTabViewState extends State<_IdeasTabView>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;
  bool _justSavedInline = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.project.ideasText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Saves into memory & snapshot history stack without showing a popup dialog
  void _saveIdeasInline() {
    final text = _controller.text;
    widget.project.ideasText = text;
    if (text.trim().isNotEmpty &&
        (widget.project.savedIdeasSnapshots.isEmpty ||
            widget.project.savedIdeasSnapshots.last != text)) {
      widget.project.savedIdeasSnapshots.add(text);
    }
    widget.onSaved();
    setState(() => _justSavedInline = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSavedInline = false);
    });
  }

  void _showSavedHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF7EB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final snapshots = widget.project.savedIdeasSnapshots.reversed.toList();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Remembered Idea Saves (Stack History)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (snapshots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No saved snapshots yet. Click Save to store versions in memory.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshots.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final snap = snapshots[i];
                      return ListTile(
                        dense: true,
                        title: Text(
                          snap,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('Snapshot #${snapshots.length - i}'),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              _controller.text = snap;
                              widget.project.ideasText = snap;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Restore'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Subtle top status row showing remembered saves count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Brainstorm & Story Ideas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6E4720),
                ),
              ),
              InkWell(
                onTap: _showSavedHistorySheet,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: Color(0xFF6E4720)),
                      const SizedBox(width: 4),
                      Text(
                        'Saved in memory (${widget.project.savedIdeasSnapshots.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E4720),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Warm yellow rounded writing container matching the hand-drawn sketch
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEE99),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5C858), width: 1.4),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (val) => widget.project.ideasText = val,
                style: const TextStyle(
                  fontSize: 15.5,
                  height: 1.45,
                  color: Color(0xFF2D241E),
                ),
                decoration: const InputDecoration(
                  hintText: 'Start to write your ideas...',
                  hintStyle: TextStyle(
                    color: Color(0xFFD49B35),
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bottom Analyze and Save buttons matching sketch
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAnalyzeRequested(_controller.text),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text(
                    'Analyze',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D241E),
                    backgroundColor: const Color(0xFFFFF7EB),
                    side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveIdeasInline,
                  icon: Icon(
                    _justSavedInline ? Icons.check_circle_outline : Icons.bookmark_border_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _justSavedInline ? 'Saved ✓' : 'Save',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D241E),
                    backgroundColor: _justSavedInline
                        ? const Color(0xFFD8F3DC)
                        : const Color(0xFFFFF7EB),
                    side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3: STORY TAB VIEW (Full Story Editor + Writing Tools + Analyze & Save)
// ============================================================================

class _StoryTabView extends StatefulWidget {
  final ProjectData project;
  final VoidCallback onSaved;
  final void Function(String text, String chapter) onAnalyzeRequested;

  const _StoryTabView({
    required this.project,
    required this.onSaved,
    required this.onAnalyzeRequested,
  });

  @override
  State<_StoryTabView> createState() => _StoryTabViewState();
}

class _StoryTabViewState extends State<_StoryTabView>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _storyController;
  bool _justSaved = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final active = widget.project.activeChapter;
    _storyController = TextEditingController(
      text: widget.project.chaptersText[active] ?? '',
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final trimmed = _storyController.text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  void _switchChapter(String chapter) {
    widget.project.chaptersText[widget.project.activeChapter] = _storyController.text;
    setState(() {
      widget.project.activeChapter = chapter;
      _storyController.text = widget.project.chaptersText[chapter] ?? '';
    });
  }

  void _insertSnippet(String snippet) {
    final text = _storyController.text;
    final sel = _storyController.selection;
    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : text.length;
    final updated = text.replaceRange(start, end, snippet);
    _storyController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
    widget.project.chaptersText[widget.project.activeChapter] = updated;
    setState(() {});
  }

  void _saveStoryInline() {
    widget.project.chaptersText[widget.project.activeChapter] = _storyController.text;
    widget.onSaved();
    setState(() => _justSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chapters = widget.project.chaptersText.keys.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Story Writing Toolbar (Chapter selector + formatting tools + word counter)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFADBB8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.project.activeChapter,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D241E),
                      fontSize: 13.5,
                    ),
                    items: chapters
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _switchChapter(val);
                    },
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'New Chapter',
                  onPressed: () {
                    final nextName = 'Chapter ${chapters.length + 1}';
                    widget.project.chaptersText[nextName] = '';
                    _switchChapter(nextName);
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Insert Dialogue Quote',
                  onPressed: () => _insertSnippet('“”'),
                  icon: const Icon(Icons.format_quote_rounded, size: 18),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Insert Em-Dash',
                  onPressed: () => _insertSnippet(' — '),
                  icon: const Icon(Icons.horizontal_rule_rounded, size: 18),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Scene Break',
                  onPressed: () => _insertSnippet('\n\n* * *\n\n'),
                  icon: const Icon(Icons.more_horiz_rounded, size: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_wordCount words',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6E4720),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Comfortable Full Story Manuscript Canvas
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2BE96), width: 1.4),
              ),
              child: TextField(
                controller: _storyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (v) {
                  widget.project.chaptersText[widget.project.activeChapter] = v;
                  setState(() {});
                },
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2D241E),
                ),
                decoration: InputDecoration(
                  hintText:
                      'Write ${widget.project.activeChapter} here... Use Analyze below to check continuity.',
                  hintStyle: const TextStyle(color: Color(0xFFA68B6C)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAnalyzeRequested(
                    _storyController.text,
                    widget.project.activeChapter,
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text(
                    'Analyze',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D241E),
                    backgroundColor: const Color(0xFFFFF7EB),
                    side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveStoryInline,
                  icon: Icon(
                    _justSaved ? Icons.check_circle_outline : Icons.bookmark_border_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _justSaved ? 'Saved ✓' : 'Save',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D241E),
                    backgroundColor:
                        _justSaved ? const Color(0xFFD8F3DC) : const Color(0xFFFFF7EB),
                    side: const BorderSide(color: Color(0xFF2D241E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 4: DICTIONARY TAB VIEW (Trie-Backed English + Custom Story Lore Words)
// ============================================================================

class _DictionaryTabView extends StatefulWidget {
  final ProjectData project;
  final VoidCallback onChanged;

  const _DictionaryTabView({
    required this.project,
    required this.onChanged,
  });

  @override
  State<_DictionaryTabView> createState() => _DictionaryTabViewState();
}

class _DictionaryTabViewState extends State<_DictionaryTabView>
    with AutomaticKeepAliveClientMixin {
  final LoreTrie _trie = LoreTrie();
  final TextEditingController _searchController = TextEditingController();
  bool _onlyCustomLore = false;

  static const List<DictionaryEntry> _standardEnglishSeed = [
    DictionaryEntry(
      word: 'Alacrity',
      partOfSpeech: 'noun',
      definition: 'Brisk and cheerful readiness in action or response.',
    ),
    DictionaryEntry(
      word: 'Arcane',
      partOfSpeech: 'adjective',
      definition: 'Understood by few; mysterious or secret.',
    ),
    DictionaryEntry(
      word: 'Bastion',
      partOfSpeech: 'noun',
      definition: 'A projecting part of a fortification; a stronghold defending a principle.',
    ),
    DictionaryEntry(
      word: 'Cacophony',
      partOfSpeech: 'noun',
      definition: 'A harsh, discordant mixture of sounds.',
    ),
    DictionaryEntry(
      word: 'Ephemeral',
      partOfSpeech: 'adjective',
      definition: 'Lasting for a very short time; transitory.',
    ),
    DictionaryEntry(
      word: 'Harbinger',
      partOfSpeech: 'noun',
      definition: 'A person or thing that announces or signals the approach of another.',
    ),
    DictionaryEntry(
      word: 'Labyrinthine',
      partOfSpeech: 'adjective',
      definition: 'Irregular and twisting; intricately Plot-woven like a labyrinth.',
    ),
    DictionaryEntry(
      word: 'Meridian',
      partOfSpeech: 'noun',
      definition: 'A circle of constant longitude passing through a given place on the Earth.',
    ),
    DictionaryEntry(
      word: 'Obfuscate',
      partOfSpeech: 'verb',
      definition: 'To render obscure, unclear, or unintelligible.',
    ),
    DictionaryEntry(
      word: 'Palimpsest',
      partOfSpeech: 'noun',
      definition: 'A manuscript on which earlier writing has been effaced and reused.',
    ),
    DictionaryEntry(
      word: 'Soliloquy',
      partOfSpeech: 'noun',
      definition: 'An act of speaking one’s thoughts aloud when by oneself in a narrative.',
    ),
    DictionaryEntry(
      word: 'Verisimilitude',
      partOfSpeech: 'noun',
      definition: 'The appearance of being true or real within a fictional world.',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rebuildTrie();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _rebuildTrie() {
    _trie.clear();
    for (final entry in widget.project.customLoreWords) {
      _trie.insert(entry);
    }
    for (final entry in _standardEnglishSeed) {
      _trie.insert(entry);
    }
  }

  Future<void> _showAddWordDialog() async {
    final wordCtrl = TextEditingController();
    final posCtrl = TextEditingController(text: 'Lore Noun');
    final defCtrl = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7EB),
        title: const Text('Add Custom Dictionary Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordCtrl,
              decoration: const InputDecoration(
                labelText: 'Word / Invented Term (e.g., Aetherium)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: posCtrl,
              decoration: const InputDecoration(
                labelText: 'Type (e.g., Magic Term, Place, Title)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: defCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Definition & World Lore Usage',
              ),
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
            child: const Text('Add to Dictionary'),
          ),
        ],
      ),
    );

    if (added == true && wordCtrl.text.trim().isNotEmpty) {
      setState(() {
        widget.project.customLoreWords.insert(
          0,
          DictionaryEntry(
            word: wordCtrl.text.trim(),
            partOfSpeech: posCtrl.text.trim().isEmpty ? 'Lore' : posCtrl.text.trim(),
            definition: defCtrl.text.trim(),
            isCustomLore: true,
          ),
        );
        _rebuildTrie();
      });
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final matches = _trie
        .searchPrefix(_searchController.text)
        .where((e) => !_onlyCustomLore || e.isCustomLore)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search English & custom lore (Trie lookup)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFFFFDF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2BE96)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _showAddWordDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Word'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B34C),
                  foregroundColor: const Color(0xFF2D241E),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  side: const BorderSide(color: Color(0xFF2D241E), width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilterChip(
                selected: !_onlyCustomLore,
                label: const Text('Full Dictionary'),
                selectedColor: const Color(0xFFF3B34C),
                onSelected: (_) => setState(() => _onlyCustomLore = false),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _onlyCustomLore,
                label: Text('Story Lore Only (${widget.project.customLoreWords.length})'),
                selectedColor: const Color(0xFFF3B34C),
                onSelected: (_) => setState(() => _onlyCustomLore = true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: matches.isEmpty
                ? const Center(
                    child: Text(
                      'No matching words found. Tap "Add Word" to define a custom story term.',
                      style: TextStyle(color: Color(0xFF7A6248)),
                    ),
                  )
                : ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = matches[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: entry.isCustomLore
                              ? const Color(0xFFFFF2C6)
                              : const Color(0xFFFADBB8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: entry.isCustomLore
                                ? const Color(0xFFD97706)
                                : const Color(0xFFE2BE96),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  entry.word,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2D241E),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${entry.partOfSpeech})',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF6E4720),
                                  ),
                                ),
                                const Spacer(),
                                if (entry.isCustomLore)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3B34C),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Custom Lore',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.definition,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF2D241E),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}