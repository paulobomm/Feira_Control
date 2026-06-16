import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/feirante/providers/feirante_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FeiraControlApp());
}

class FeiraControlApp extends StatelessWidget {
  const FeiraControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => FeiranteProvider()),
      ],
      child: MaterialApp.router(
        title: 'FeiraControl',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
