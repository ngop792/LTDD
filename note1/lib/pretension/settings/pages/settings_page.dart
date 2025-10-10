import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note1/pretension/choose_mode/bloc/theme_cubit.dart';
import 'package:note1/pretension/settings/bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const accentColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final settingsCubit = context.read<SettingsCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56, // chiều cao AppBar
        leadingWidth: 40, // giới hạn vùng leading
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Hero(
            tag: 'settings_icon',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, // kích thước vòng tròn
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16, // icon vừa vòng tròn
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Cài đặt",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const SizedBox(height: 10),

              _buildSectionHeader("Giao diện"),
              _buildCard(
                context,
                children: [
                  // Ngôn ngữ
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text("Ngôn ngữ"),
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'vi',
                          child: Text('Tiếng Việt'),
                        ),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) {
                        if (v != null) settingsCubit.setLanguage(v);
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Chế độ sáng / tối
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.light_mode_outlined),
                        title: const Text("Chế độ sáng"),
                        value: mode == ThemeMode.light,
                        onChanged: (v) => themeCubit.setMode(
                          v ? ThemeMode.light : ThemeMode.dark,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Màu chủ đạo
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined),
                    title: const Text("Màu chủ đạo"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(accentColors.length, (i) {
                        final selected = settings.accentIndex == i;
                        return GestureDetector(
                          onTap: () => settingsCubit.setAccentIndex(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                      width: 2,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                            child: CircleAvatar(
                              backgroundColor: accentColors[i],
                              radius: selected ? 14 : 12,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Divider(height: 1),

                  // Cỡ chữ
                  ListTile(
                    leading: const Icon(Icons.text_fields_outlined),
                    title: const Text("Cỡ chữ"),
                    trailing: DropdownButton<String>(
                      value: settings.fontSize,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'small', child: Text('Nhỏ')),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Bình thường'),
                        ),
                        DropdownMenuItem(value: 'large', child: Text('Lớn')),
                      ],
                      onChanged: (v) {
                        if (v != null) settingsCubit.setFontSize(v);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader("Tài khoản & bảo mật"),
              _buildCard(
                context,
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text("Đổi mật khẩu"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Chưa làm chức năng này")),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text("Điều lệ & Bảo mật"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {
                      // TODO: mở trang điều lệ & bảo mật
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  "Phiên bản 1.0.0",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  // ===== Widget phụ trợ =====
  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: isDark
          ? Colors.grey.shade900.withOpacity(0.6)
          : Colors.grey.shade100.withOpacity(0.8),
      child: Column(children: children),
    );
  }
}
