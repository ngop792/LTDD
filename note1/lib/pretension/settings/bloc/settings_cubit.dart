import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsState {
  final String language;
  final int accentIndex;
  final String fontSize;

  SettingsState({
    this.language = 'vi',
    this.accentIndex = 0,
    this.fontSize = 'normal',
  });

  SettingsState copyWith({
    String? language,
    int? accentIndex,
    String? fontSize,
  }) {
    return SettingsState(
      language: language ?? this.language,
      accentIndex: accentIndex ?? this.accentIndex,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'accentIndex': accentIndex,
      'fontSize': fontSize,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      language: map['language'] ?? 'vi',
      accentIndex: map['accentIndex'] ?? 0,
      fontSize: map['fontSize'] ?? 'normal',
    );
  }
}

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  void setLanguage(String lang) => emit(state.copyWith(language: lang));
  void setAccentIndex(int i) => emit(state.copyWith(accentIndex: i));
  void setFontSize(String size) => emit(state.copyWith(fontSize: size));

  @override
  SettingsState? fromJson(Map<String, dynamic> json) =>
      SettingsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => state.toMap();
}
