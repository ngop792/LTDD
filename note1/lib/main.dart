import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubit.dart';
import 'package:note1/pretension/main_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:note1/core/configs/theme/app_theme.dart';
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/firebase_options.dart';
import 'package:note1/service_locator.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';
import 'package:note1/pretension/splash/pages/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo HydratedBloc (lưu state theme + settings vào storage)
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://djmzaivntfscxzekwhxg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqbXphaXZudGZzY3h6ZWt3aHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1OTQyNzEsImV4cCI6MjA3NDE3MDI3MX0.KePn0o0x6rKGrrtnoX5d99giBIcU6DW4m2gR-dBaPCw',
  );

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Service locator (nếu bạn có DI cho project)
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Danh sách màu accent có thể chọn
  static const accentColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              // Áp dụng cỡ chữ cho toàn app
              double scale = 1.0;
              if (settings.fontSize == 'small') scale = 0.9;
              if (settings.fontSize == 'large') scale = 1.2;

              // Chọn màu accent theo settings
              final accent =
                  accentColors[settings.accentIndex % accentColors.length];

              // ⭐ Cập nhật AppColors.primary runtime để tất cả nút & widget theo màu này
              AppColors.setPrimary(accent);

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(accent),
                darkTheme: AppTheme.darkTheme(accent),
                themeMode: mode, // từ ThemeCubit
                locale: Locale(settings.language), // đổi ngôn ngữ
                home: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                  child: const SplashPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
