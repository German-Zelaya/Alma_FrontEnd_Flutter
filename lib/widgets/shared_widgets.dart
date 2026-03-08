import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
//  APP BUTTON — Gradient & Solid
// ═══════════════════════════════════════════════════════════
enum AppButtonStyle { gradient, solid, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final Widget? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.gradient,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (style) {
      case AppButtonStyle.gradient:
        return _GradientButton(label: label, onPressed: onPressed, isLoading: isLoading, icon: icon);
      case AppButtonStyle.solid:
        return _SolidButton(label: label, onPressed: onPressed, isLoading: isLoading, icon: icon);
      case AppButtonStyle.outline:
        return _OutlineButton(label: label, onPressed: onPressed, icon: icon);
      case AppButtonStyle.ghost:
        return _GhostButton(label: label, onPressed: onPressed);
    }
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  const _GradientButton({required this.label, this.onPressed, this.isLoading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(label, style: AppTextStyles.buttonText),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  const _SolidButton({required this.label, this.onPressed, this.isLoading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label, style: AppTextStyles.buttonText),
              ],
            ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  const _OutlineButton({required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(label, style: AppTextStyles.buttonTextDark),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _GhostButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.buttonTextDark),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  APP CARD
// ═══════════════════════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool useGradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: useGradient ? AppDecorations.gradientCard : AppDecorations.card,
        child: child,
      ),
    );
  }
}

class AppInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;
  final Color? color;

  const AppInfoCard({super.key, required this.label, required this.value, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: 8)],
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.heading3.copyWith(color: color ?? AppColors.primary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  APP BADGE
// ═══════════════════════════════════════════════════════════
enum BadgeType { high, medium, low, status, custom }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final Color? customColor;

  const AppBadge({super.key, required this.label, this.type = BadgeType.status, this.customColor});

  Color get _color {
    switch (type) {
      case BadgeType.high: return AppColors.badgeHigh;
      case BadgeType.medium: return AppColors.badgeMedium;
      case BadgeType.low: return AppColors.badgeLow;
      case BadgeType.status: return AppColors.badgeStatus;
      case BadgeType.custom: return customColor ?? AppColors.badgeStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  APP INPUT
// ═══════════════════════════════════════════════════════════
class AppInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? label;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BOTTOM NAVIGATION
// ═══════════════════════════════════════════════════════════
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Crecimiento'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTextStyles.bodySecondary.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  GRADIENT SCAFFOLD — base de todas las pantallas
// ═══════════════════════════════════════════════════════════
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: body,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  HABIT CHECK ITEM
// ═══════════════════════════════════════════════════════════
class HabitCheckItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool checked;
  final Color color;
  final VoidCallback onTap;

  const HabitCheckItem({
    super.key,
    required this.label,
    required this.icon,
    required this.checked,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: checked ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: checked ? color : AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: checked ? color : AppColors.textLight, size: 20),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body.copyWith(color: checked ? color : AppColors.textSecondary, fontWeight: checked ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            Icon(checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: checked ? color : AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TASK ITEM
// ═══════════════════════════════════════════════════════════
class TaskItem extends StatelessWidget {
  final String title;
  final BadgeType priority;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.title,
    required this.priority,
    required this.completed,
    required this.onToggle,
    required this.onDelete,
  });

  String get _priorityLabel {
    switch (priority) {
      case BadgeType.high: return 'Alta';
      case BadgeType.medium: return 'Media';
      case BadgeType.low: return 'Baja';
      default: return 'Media';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              completed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: completed ? AppColors.primary : AppColors.textLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(decoration: completed ? TextDecoration.lineThrough : null, color: completed ? AppColors.textLight : AppColors.textPrimary)),
                const SizedBox(height: 4),
                AppBadge(label: _priorityLabel, type: priority),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textLight), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textLight), onPressed: onDelete),
        ],
      ),
    );
  }
}
