import 'package:flutter/material.dart';

/// BasicAppbar — AppBar tùy chỉnh có thể dùng cho mọi trang.
/// Hỗ trợ:
/// - Nút back bo tròn (giống Spotify)
/// - Tiêu đề tùy chỉnh
/// - Action (nút ⋮ hoặc IconButton)
/// - Tự đổi màu icon theo theme sáng/tối
class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title; // Tiêu đề ở giữa
  final Widget? action; // 1 nút action (ví dụ ⋮)
  final bool showBack; // Hiện nút back hay không
  final List<Widget> actions; // Danh sách các action bổ sung

  const BasicAppbar({
    Key? key,
    this.title,
    this.showBack = false,
    this.action,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // không tự sinh nút back
      title: title ?? const Text(''),
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            )
          : null,
      actions: [if (action != null) action!, ...actions],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
