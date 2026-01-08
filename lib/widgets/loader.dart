import 'dart:ui';
import 'package:flutter/material.dart';

class StatusLoader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StatusLoader({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.black.withValues(alpha: 0.18)),
        ),

        // Animated card
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1.0),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 12))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
                    child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                  ),

                  const SizedBox(height: 18),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),

                  // Smooth loader
                  const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.6)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
