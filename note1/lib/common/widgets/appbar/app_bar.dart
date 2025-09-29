import 'package:flutter/material.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool showBack;
  final List<Widget> actions;

  const BasicAppbar({
    Key? key,
    this.title,
    this.showBack = false,
    this.actions = const [], // 👈 mặc định rỗng, không bắt buộc phải truyền
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // không tự thêm nút back
      title: title ?? const Text(''),
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.03)
                      : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 15,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            )
          : null,
      actions: actions, // 👈 truyền actions vào AppBar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
