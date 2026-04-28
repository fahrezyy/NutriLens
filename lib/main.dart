import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'viewmodels/nutrilens_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NutriLensApp());
}

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NutriLensViewModel(),
      child: MaterialApp(
        title:           'NutriLens',
        debugShowCheckedModeBanner: false,
        theme:           AppTheme.dark,
        initialRoute:    '/',
        routes: {
          '/': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
