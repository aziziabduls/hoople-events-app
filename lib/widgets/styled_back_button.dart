import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App-wide back button. Pops the current route by default and carries a
/// tooltip; pass [onPressed]/[color]/[tooltip] to override.
class StyledBackButton extends StatelessWidget {
  const StyledBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.tooltip = 'Back',
  });

  final VoidCallback? onPressed;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed:
            onPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              }
            },
        icon: const Icon(Icons.arrow_back),
        color: color,
        tooltip: tooltip,
      ),
    );
  }
}
