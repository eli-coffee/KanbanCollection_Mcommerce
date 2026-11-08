import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../utils/strings.dart';

class AppBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<Widget> icons; // Home, Cart, Notification, Profile, Settings

  const AppBottomBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.icons,
  });

  static const _keys = ['Home', 'Cart', 'Notification', 'Profile', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) => Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _keys.length; i++)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onTap(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 58),
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: i == index
                                        ? Colors.white
                                        : Colors.white54,
                                    size: 24,
                                  ),
                                  child: Center(child: icons[i]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 16,
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  S.t(_keys[i]),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: i == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }
}