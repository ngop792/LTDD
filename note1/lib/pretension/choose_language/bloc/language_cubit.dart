import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('vi'); // mặc định Tiếng Việt

  void setLanguage(String lang) => emit(lang);
}
