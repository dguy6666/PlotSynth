import 'package:flutter/material.dart';
import 'package:plotsynth_app/models/project.dart';
import 'outline_view_model.dart';

class OutlineView extends StatefulWidget {
  final Project project;
  const OutlineView({super.key, required this.project});

  @override
  State<OutlineView> createState() => _OutlineViewState();
}

class _OutlineViewState extends State<OutlineView> {
  late final OutlineViewModel viewModel;
  late final TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    viewModel = OutlineViewModel(project: widget.project);

    // 1. Pre-fill the text box with the project's saved outline:
    _textController = TextEditingController(text: widget.project.currentOutline);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

    
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Outline')),
          body: Padding(
            padding: const EdgeInsets.all(16.0), // Outer screen padding
            child: Column(
              children: [
                // 1. Text box fills all available vertical space:
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:  const Color(0xFF2A2A2A), // Warm Readest fill
                      borderRadius: BorderRadius.circular(20), // Rounded square
                      // No border / no outline!
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,     // Allows unlimited lines
                      expands: true,      // Fills the full height of the container!
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: InputBorder.none, // Removes all default underlines & borders
                        hintText: 'Start typing your ideas, character traits, and world rules...',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Row of 2 buttons pinned beneath the text box:
                Row(
                  children: [
                    // Left button (Save / Secondary):
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          viewModel.saveOutline(_textController.text);

                          // Quick subtle feedback (no annoying popup, just as you planned!):
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft saved to history! ✓'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right button (AI Action / Primary):
                    Expanded(
                      flex: 2, // Slightly wider for emphasis
                      child: FilledButton.icon(
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Audit'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}