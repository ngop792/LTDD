import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) => emit(themeMode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final themeStr = json['theme'] as String?;
    if (themeStr == 'light') return ThemeMode.light;
    if (themeStr == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {
      'theme': state == ThemeMode.light
          ? 'light'
          : state == ThemeMode.dark
          ? 'dark'
          : 'system',
    };
  }
}
