import 'package:flutter/material.dart';

class ProjectScreen extends StatefulWidget {
  final String projectName;

  const ProjectScreen({super.key, required this.projectName});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late PageController _pageController;
  int _currentTabIndex = 0; // Default: 'Ideas' tab (index 0)[cite: 2]

  // Controllers to store text for all 5 tabs in memory[cite: 2]
  final List<TextEditingController> _controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  final List<String> _savedMemory = List.generate(5, (_) => '');
  bool _showSavedIndicator = false;

  final List<TabItemData> _tabItems = [
    TabItemData(label: 'Ideas', icon: Icons.lightbulb_outline, activeIcon: Icons.lightbulb), // Default Ideas[cite: 2]
    TabItemData(label: 'Book', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),   // Book tab[cite: 2]
    TabItemData(label: 'Entities', icon: Icons.people_outline, activeIcon: Icons.people),
    TabItemData(label: 'Timeline', icon: Icons.timeline_outlined, activeIcon: Icons.timeline),
    TabItemData(label: 'Notes', icon: Icons.article_outlined, activeIcon: Icons.article),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveContent() {
    setState(() {
      _savedMemory[_currentTabIndex] = _controllers[_currentTabIndex].text;
      _showSavedIndicator = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSavedIndicator = false;
        });
      }
    });
  }

  void _openAnalyzeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AnalyzeChangesModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.projectName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE57373),
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Canvas Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0B8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentTabIndex = index;
                            _showSavedIndicator = false;
                          });
                        },
                        itemCount: _tabItems.length,
                        itemBuilder: (context, index) {
                          return TextField(
                            controller: _controllers[index],
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Start to write your ${_tabItems[index].label.toLowerCase()}..',
                              hintStyle: TextStyle(color: Colors.brown.withOpacity(0.5)),
                              border: InputBorder.none,
                            ),
                          );
                        },
                      ),
                    ),
                    // Action Buttons Row: Analyze & Save
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE57373), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          onPressed: _openAnalyzeModal,
                          child: const Row(
                            children: [
                              Text(
                                'Analyze ',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.crop_square, size: 16, color: Color(0xFFE57373)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          onPressed: _saveContent,
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: _showSavedIndicator ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check, size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Saved',
                                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar with Growing Active Tab (~50% expansion)
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF9D19E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabItems.length, (index) {
                  final isSelected = _currentTabIndex == index;

                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isSelected ? 72 : 46, // Expands width ~50%
                      height: isSelected ? 56 : 38,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFECC4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: const Color(0xFFE5A663), width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          isSelected ? _tabItems[index].activeIcon : _tabItems[index].icon,
                          size: isSelected ? 28 : 22,
                          color: const Color(0xFF4A3419),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  TabItemData({required this.label, required this.icon, required this.activeIcon});
}

// Modal handling the Analyze, Detected Changes, and Minimalist Edit flow
class AnalyzeChangesModal extends StatefulWidget {
  const AnalyzeChangesModal({super.key});

  @override
  State<AnalyzeChangesModal> createState() => _AnalyzeChangesModalState();
}

class _AnalyzeChangesModalState extends State<AnalyzeChangesModal> {
  bool _isLoading = true;
  bool _isEditing = false;
  late TextEditingController _detectedChangesController;

  @override
  void initState() {
    super.initState();
    _detectedChangesController = TextEditingController(
      text: "• Detected new scene sequence in Chapter 2.\n"
          "• Relationship dynamics updated.\n"
          "• Key event logged to timeline.",
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _detectedChangesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF9D19E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const SizedBox(
                height: 230,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6B4823)),
                    SizedBox(height: 20),
                    Text(
                      'Analyzing story notes and logic...',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Changes detected:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECC4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.brown.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _isEditing
                              ? TextField(
                                  controller: _detectedChangesController,
                                  maxLines: null,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(border: InputBorder.none),
                                )
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 32.0),
                                    child: Text(
                                      _detectedChangesController.text,
                                      style: const TextStyle(fontSize: 14, height: 1.5),
                                    ),
                                  ),
                                ),
                        ),
                        // Minimalist pencil icon button
                        Positioned(
                          top: 0,
                          left: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _isEditing ? const Color(0xFFF4BE81) : Colors.white60,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_outlined, size: 18, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFECC4),
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Changes applied successfully.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Add changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}