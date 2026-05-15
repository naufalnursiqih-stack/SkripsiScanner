// lib/presentation/widgets/custom_button.dart

import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outlined, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final double? height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final isDisabled = onPressed == null || isLoading;

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            child: child,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.secondary,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );

      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 50,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            child: child,
          ),
        );

      case ButtonVariant.danger:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: height ?? 50,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
    }
  }
}
