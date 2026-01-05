import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.isDarkMode,
    this.title = 'No tasks yet',
    this.message = 'Start your productive day by adding your first task using the button below',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ]
              : [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF8B5CF6).withOpacity(0.2),
                        const Color(0xFF6366F1).withOpacity(0.2),
                      ]
                    : [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: isDarkMode
                  ? const Color(0xFFD8B4FE)
                  : const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '✨',
            style: TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }
}
