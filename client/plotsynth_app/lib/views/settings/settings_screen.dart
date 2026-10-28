import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool offlineModeOnly;
  final bool aesEncryptionEnabled;
  final bool showMlLoadingTips;
  final ValueChanged<bool> onOfflineModeChanged;
  final ValueChanged<bool> onEncryptionChanged;
  final ValueChanged<bool> onShowMlTipsChanged;
  final VoidCallback onReplayTutorial;

  const SettingsScreen({
    super.key,
    required this.offlineModeOnly,
    required this.aesEncryptionEnabled,
    required this.showMlLoadingTips,
    required this.onOfflineModeChanged,
    required this.onEncryptionChanged,
    required this.onShowMlTipsChanged,
    required this.onReplayTutorial,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _offlineOnly;
  late bool _aesEncryption;
  late bool _showMlTips;
  double _editorFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _offlineOnly = widget.offlineModeOnly;
    _aesEncryption = widget.aesEncryptionEnabled;
    _showMlTips = widget.showMlLoadingTips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Storage & Synchronization'),
          _buildSettingsCard(
            children: [
              SwitchListTile(
                value: _offlineOnly,
                activeThumbColor: const Color(0xFF8C5A2B),
                title: const Text(
                  'Offline-First Mode (Local SQLite)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Work without an account or internet. Disable to sync with Supabase Cloud when signed in.',
                ),
                secondary: const Icon(Icons.cloud_off_outlined, color: Color(0xFF6E4720)),
                onChanged: (val) {
                  setState(() => _offlineOnly = val);
                  widget.onOfflineModeChanged(val);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: _aesEncryption,
                activeThumbColor: const Color(0xFF8C5A2B),
                title: const Text(
                  'AES-256 Manuscript Encryption',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Encrypt story drafts and canonical lore files at rest.',
                ),
                secondary: const Icon(Icons.enhanced_encryption_outlined, color: Color(0xFF6E4720)),
                onChanged: (val) {
                  setState(() => _aesEncryption = val);
                  widget.onEncryptionChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Analysis Engine & Editor'),
          _buildSettingsCard(
            children: [
              SwitchListTile(
                value: _showMlTips,
                activeThumbColor: const Color(0xFF8C5A2B),
                title: const Text(
                  'Show Tips During ML Analysis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Display continuity tips inside the Analyze loading window.',
                ),
                secondary: const Icon(Icons.psychology_outlined, color: Color(0xFF6E4720)),
                onChanged: (val) {
                  setState(() => _showMlTips = val);
                  widget.onShowMlTipsChanged(val);
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Default Editor Font Size',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          '${_editorFontSize.toInt()} pt',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8C5A2B),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _editorFontSize,
                      min: 12,
                      max: 24,
                      divisions: 6,
                      activeColor: const Color(0xFF8C5A2B),
                      onChanged: (val) => setState(() => _editorFontSize = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Help & Onboarding'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.school_outlined, color: Color(0xFF6E4720)),
                title: const Text(
                  'Replay Welcome Tutorial',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('View the walkthrough of PlotSynth tabs and gestures.'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReplayTutorial();
                },
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.info_outline_rounded, color: Color(0xFF6E4720)),
                title: Text(
                  'Zero-Generation Guarantee',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'PlotSynth strictly analyzes your canon for plot holes and never writes or replaces your prose.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Color(0xFF7A6248),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFADBB8).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5C198)),
      ),
      child: Column(children: children),
    );
  }
}