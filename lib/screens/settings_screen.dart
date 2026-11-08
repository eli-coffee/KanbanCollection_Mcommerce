import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/strings.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  Map<String, String> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService().getProfile();
    if (!mounted) return;
    setState(() => _profile = p);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
    _loadProfile();
  }

  String _themeName(ThemeMode m) => switch (m) {
        ThemeMode.system => S.t('System'),
        ThemeMode.light => S.t('Light'),
        ThemeMode.dark => S.t('Dark'),
      };

  String get _langShort => _settings.language == AppLanguage.en ? 'ENG' : 'FIL';

  Future<void> _pickTheme() async {
    final choice = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(S.t('Choose theme'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            for (final m in ThemeMode.values)
              ListTile(
                title: Text(_themeName(m)),
                trailing:
                    _settings.themeMode == m ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, m),
              ),
          ],
        ),
      ),
    );
    if (choice != null) _settings.setTheme(choice);
  }

  Future<void> _pickLanguage() async {
    final choice = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(S.t('Choose language'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            for (final l in AppLanguage.values)
              ListTile(
                title: Text(l == AppLanguage.en ? 'English' : 'Filipino'),
                trailing:
                    _settings.language == l ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, l),
              ),
          ],
        ),
      ),
    );
    if (choice != null) _settings.setLanguage(choice);
  }

  void _setTts(bool on) {
    _settings.setTts(on);
    if (on) {
      TtsService.speak(S.t('Text-to-speech is on'));
    } else {
      TtsService.stop();
    }
  }

  // ------------------------------------------------------------- pieces
  Widget _pill({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 4),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label, {
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return _pill(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28),
          Expanded(
            child: Center(
              child: Text(S.t(label), style: const TextStyle(fontSize: 19)),
            ),
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(value,
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ),
          trailing ?? const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _profileCard() {
    final name = AuthService().currentUsername ?? 'Guest';
    final full = _profile['fullName'] ?? '';
    final contact = _profile['contact'] ?? '';

    return _pill(
      onTap: () => _open(const EditProfileScreen()),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.indigo, width: 4),
            ),
            child: UserAvatar(radius: 32, name: name),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                if (full.isNotEmpty) Text(full),
                if (contact.isNotEmpty) Text(contact),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        final heading = TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white : Colors.black,
        );
        Widget section(String t) => Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 0, 8),
              child: Text(S.t(t), style: heading),
            );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [Color(0xFF2A3140), Color(0xFF111319)]
                  : const [Color(0xFFCFDDE8), Color(0xFF3B4259)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ResponsiveCenter(
              maxWidth: 600,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 10),
                    child: Text(S.t('Profile'),
                        style: heading.copyWith(fontSize: 26)),
                  ),
                  _profileCard(),

                  section('Account'),
                  _item(Icons.manage_accounts_outlined, 'My Data',
                      onTap: () => _open(const EditProfileScreen())),
            

                  section('Accessibility'),
                  _item(Icons.language, 'Language',
                      value: _langShort, onTap: _pickLanguage),
                  _item(Icons.tune, 'Theme',
                      value: _themeName(_settings.themeMode),
                      onTap: _pickTheme),
                  _item(
                    Icons.volume_up_outlined,
                    'Text-To-Speech',
                    trailing: Switch(
                      value: _settings.ttsEnabled,
                      onChanged: _setTts,
                    ),
                    onTap: () => _setTts(!_settings.ttsEnabled),
                  ),

                  section('Support'),
                  _item(Icons.help_outline, 'Help Center',
                      onTap: () => _open(const HelpCenterScreen())),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}