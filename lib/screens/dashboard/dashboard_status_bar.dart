import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

/// Full-width status bar pinned to the bottom of the dashboard.
class DashboardStatusBar extends StatelessWidget {
  const DashboardStatusBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onAction,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: DashboardColors.toolbarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Page $currentPage / $totalPages',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 18),
            onPressed: () => onAction('Home'),
          ),
          IconButton(
            icon: const Icon(Icons.first_page, color: Colors.white, size: 18),
            onPressed: () => onAction('First page'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 18),
            onPressed: () => onAction('Previous page'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
            onPressed: () => onAction('Next page'),
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: Colors.white, size: 18),
            onPressed: () => onAction('Last page'),
          ),
        ],
      ),
    );
  }
}
