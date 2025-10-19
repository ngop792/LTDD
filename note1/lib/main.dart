import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🔹 Imports nội bộ
import 'package:note1/core/configs/theme/app_colors.dart';
import 'package:note1/core/configs/theme/app_theme.dart';
import 'package:note1/core/localization/app_translations.dart';
import 'package:note1/firebase_options.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubit.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';
import 'package:note1/pretension/splash/pages/splash.dart';
import 'package:note1/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Khởi tạo GetStorage
  await GetStorage.init();

  // ✅ HydratedBloc (lưu trạng thái Theme & Settings)
  HydratedStorage storage;
  if (kIsWeb) {
    storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory.web,
    );
  } else {
    final dir = await getApplicationDocumentsDirectory();
    storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(dir.path),
    );
  }

  HydratedBloc.storage = storage;

  // ✅ Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://djmzaivntfscxzekwhxg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRqbXphaXZudGZzY3h6ZWt3aHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1OTQyNzEsImV4cCI6MjA3NDE3MDI3MX0.KePn0o0x6rKGrrtnoX5d99giBIcU6DW4m2gR-dBaPCw',
  );

  // ✅ Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Service Locator (Dependency Injection)
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              // 🔹 Cỡ chữ
              final scale = switch (settings.fontSize) {
                'small' => 0.9,
                'large' => 1.2,
                _ => 1.0,
              };

              // 🔹 Màu chủ đạo
              final accent =
                  accentColors[settings.accentIndex % accentColors.length];
              AppColors.setPrimary(accent);

              final light = AppTheme.lightTheme(accent);
              final dark = AppTheme.darkTheme(accent);

              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: light,
                darkTheme: dark,
                themeMode: mode,
                translations: AppTranslations(),
                supportedLocales: const [Locale('vi'), Locale('en')],
                locale: Get.locale ?? Locale(settings.language),
                fallbackLocale: const Locale('en'),

                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

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
