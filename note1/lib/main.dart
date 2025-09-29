import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:note1/core/configs/theme/app_theme.dart';
import 'package:note1/firebase_options.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubi.dart';
import 'package:note1/pretension/splash/pages/splash.dart';
import 'package:note1/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Supabase.initialize(
    url: 'https://djmzaivntfscxzekwhxg.supabase.co', // Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqbXphaXZudGZzY3h6ZWt3aHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1OTQyNzEsImV4cCI6MjA3NDE3MDI3MX0.KePn0o0x6rKGrrtnoX5d99giBIcU6DW4m2gR-dBaPCw', // anon key
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme, // Light mode
            darkTheme: AppTheme.darkTheme, // Dark mode
            themeMode: mode, // lấy từ ThemeCubit
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
