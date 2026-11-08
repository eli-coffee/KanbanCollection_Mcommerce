import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'utils/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SettingsService().load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (_, _) => MaterialApp(
                    builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler
                  .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15),
            ),
            child: LangScope(
              notifier: SettingsService(),
              child: child!,
            ),
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'Kanban Collectibles',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: SettingsService().themeMode,
        home: const LoginScreen(),
      ),
    );
  }
}