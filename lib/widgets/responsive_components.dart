import 'package:flutter/material.dart';
import '../core/theme/app_design_system.dart';

/// Screen scaffold enforcing max width constraints and safe area padding.
class ResponsiveScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final double maxWidth;

  const ResponsiveScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    required this.body,
    this.maxWidth = 550,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (title != null || titleWidget != null)
          ? AppBar(
              title: titleWidget ??
                  Text(
                    title!,
                    style: AppDesignSystem.titleStyle(context, size: 20),
                  ),
              centerTitle: true,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Dynamic card component adapting to theme and responsive layout.
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignSystem.spaceMd),
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppDesignSystem.darkSurface : AppDesignSystem.lightSurface;
    final border = borderColor ?? (isDark ? Colors.white12 : Colors.black12);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLg),
        border: Border.all(color: border, width: 1.5),
        boxShadow: AppDesignSystem.softShadow(isDark),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLg),
        child: content,
      );
    }

    return content;
  }
}
