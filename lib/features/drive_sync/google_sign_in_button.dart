import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 符合 Google Sign-In 品牌规范的登录按钮：标准 "G" 标志、Roboto Medium、
/// 浅色 / 深色主题使用规范指定的底色与描边。
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF131314) : Colors.white;
    final border = dark ? const Color(0xFF8E918F) : const Color(0xFF747775);
    final foreground = dark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final enabled = onPressed != null && !loading;

    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Material(
        color: background,
        shape: StadiumBorder(side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 20,
                    child: loading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: foreground,
                          )
                        : SvgPicture.asset('assets/icon/google_g.svg'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: foreground,
                      ),
                    ),
                  ),
                  // 与左侧标志等宽，使文字在按钮内视觉居中。
                  const SizedBox(width: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
