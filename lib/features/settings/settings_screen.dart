import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/storage_service.dart';
import '../editor/level_editor_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SettingsScreen({
    super.key,
    required this.storageService,
    required this.themeModeNotifier,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _hapticEnabled;
  late bool _reduceMotion;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.storageService.isSoundEnabled();
    _hapticEnabled = widget.storageService.isHapticEnabled();
    _reduceMotion = widget.storageService.isReduceMotion();
    _themeMode = widget.storageService.getThemeMode();
  }

  // ── Theme ──────────────────────────────────────────────────────────────────

  Future<void> _applyTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    widget.themeModeNotifier.value = mode;
    await widget.storageService.setThemeMode(mode);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── APPEARANCE ───────────────────────────────────────────────────
          _SectionHeader(title: 'APPEARANCE'),
          _SettingsCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Icon(Icons.brightness_6_rounded,
                          color: colorScheme.primary, size: 22),
                      const SizedBox(width: 12),
                      const Text(
                        'Theme',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _ThemeSegmentedControl(
                    current: _themeMode,
                    onChanged: _applyTheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── PREFERENCES ──────────────────────────────────────────────────
          _SectionHeader(title: 'PREFERENCES'),
          _SettingsCard(
            isDark: isDark,
            child: Column(
              children: [
                _SwitchRow(
                  icon: Icons.volume_up_rounded,
                  iconColor: Colors.blue,
                  label: 'Sound Effects',
                  subtitle: 'Game audio & UI sounds',
                  value: _soundEnabled,
                  onChanged: (val) async {
                    setState(() => _soundEnabled = val);
                    await widget.storageService.setSoundEnabled(val);
                  },
                ),
                _Divider(),
                _SwitchRow(
                  icon: Icons.vibration_rounded,
                  iconColor: Colors.orange,
                  label: 'Haptic Feedback',
                  subtitle: 'Vibration on taps & events',
                  value: _hapticEnabled,
                  onChanged: (val) async {
                    setState(() => _hapticEnabled = val);
                    await widget.storageService.setHapticEnabled(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ACCESSIBILITY ─────────────────────────────────────────────────
          _SectionHeader(title: 'ACCESSIBILITY'),
          _SettingsCard(
            isDark: isDark,
            child: _SwitchRow(
              icon: Icons.animation_rounded,
              iconColor: Colors.teal,
              label: 'Reduce Motion',
              subtitle: 'Minimize animations & transitions',
              value: _reduceMotion,
              onChanged: (val) async {
                setState(() => _reduceMotion = val);
                await widget.storageService.setReduceMotion(val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── DATA & PROGRESS ──────────────────────────────────────────────
          _SectionHeader(title: 'DATA & PROGRESS'),
          _SettingsCard(
            isDark: isDark,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: AppColors.error, size: 22),
              ),
              title: const Text(
                'Reset Progress',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              subtitle:
                  const Text('Clear all saved levels, stars & scores'),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.error),
              onTap: () => _confirmReset(context),
            ),
          ),
          const SizedBox(height: 16),

          // ── SUPPORT ───────────────────────────────────────────────────────
          _SectionHeader(title: 'SUPPORT'),
          _SettingsCard(
            isDark: isDark,
            child: Column(
              children: [
                ListTile(
                  leading: const _IconBadge(
                      icon: Icons.privacy_tip_outlined,
                      color: Colors.green),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('100% offline & local data storage'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Privacy Policy'),
                      content: const Text(
                        'Arrow Matrix: Vector Escape operates 100% offline.\n\n'
                        '• No analytics or personal data is collected.\n'
                        '• Game progress is saved locally on your device.\n'
                        '• No network requests are made.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('CLOSE'),
                        ),
                      ],
                    ),
                  ),
                ),
                _Divider(),
                ListTile(
                  leading: const _IconBadge(
                      icon: Icons.description_outlined,
                      color: Colors.blue),
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Offline single-player puzzle game'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Terms of Service'),
                      content: const Text(
                        'Arrow Matrix: Vector Escape is a single-player offline puzzle game.\n\n'
                        '• Free to play with no mandatory purchases.\n'
                        '• All levels and content are unlocked through gameplay.\n'
                        '• Have fun solving vector matrix puzzles!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('CLOSE'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ABOUT ─────────────────────────────────────────────────────────
          _SectionHeader(title: 'ABOUT'),
          _SettingsCard(
            isDark: isDark,
            child: Column(
              children: [
                ListTile(
                  leading: const _IconBadge(
                      icon: Icons.info_outline_rounded,
                      color: Colors.teal),
                  title: const Text('About Arrow Matrix'),
                  subtitle: const Text('Version 1.0.0 — Vector Escape Puzzle'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Arrow Matrix: Vector Escape',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2026 Arrow Matrix Team. All rights reserved.',
                  ),
                ),
                if (kDebugMode) ...[
                  _Divider(),
                  ListTile(
                    leading: const _IconBadge(
                        icon: Icons.edit_note_rounded,
                        color: Colors.amber),
                    title: const Text('Level Editor (Debug Only)'),
                    subtitle: const Text('Visual canvas, solver validator, exporter'),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: Colors.amber),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelEditorScreen(
                          storageService: widget.storageService,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
            'This will remove all saved levels, stars, and statistics. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await widget.storageService.resetProgress();
              // After clear(), re-seed the theme so the notifier stays correct
              await widget.storageService.setThemeMode(ThemeMode.system);
              widget.themeModeNotifier.value = ThemeMode.system;
              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Progress has been reset.')),
                );
                setState(() {
                  _soundEnabled = true;
                  _hapticEnabled = true;
                  _reduceMotion = false;
                  _themeMode = ThemeMode.system;
                });
              }
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Segmented Control ──────────────────────────────────────────────────

class _ThemeSegmentedControl extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmentedControl(
      {required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
      (ThemeMode.light, Icons.wb_sunny_rounded, 'Light'),
      (ThemeMode.dark, Icons.nights_stay_rounded, 'Dark'),
    ];

    return Row(
      children: options.map((opt) {
        final (mode, icon, label) = opt;
        final selected = current == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? primary
                    : primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      color: selected ? Colors.white : primary, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _SettingsCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.gridBorderDark : AppColors.gridBorderLight,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _IconBadge(icon: icon, color: iconColor),
      title: Text(label,
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        indent: 56,
        endIndent: 16,
        color: Colors.grey.withValues(alpha: 0.15));
  }
}
