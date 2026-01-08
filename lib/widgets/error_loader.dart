import 'package:flutter/material.dart';

class ErrorStatusDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const ErrorStatusDialog({super.key, required this.title, required this.subtitle, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final errorColor = Colors.redAccent;

    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 32, color: errorColor),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: errorColor),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: onRetry, child: const Text("Retry")),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
