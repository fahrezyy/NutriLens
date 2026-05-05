import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'viewmodels/nutrilens_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/landing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NutriLensApp());
}

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutriLensViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp(
        title: 'NutriLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const LandingScreen(),
      ),
    );
  }
}
