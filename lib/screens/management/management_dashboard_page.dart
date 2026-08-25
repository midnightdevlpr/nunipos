import 'package:flutter/material.dart';

import '../dashboard/dashboard_colors.dart';

/// The Management area's "Dashboard" section. There's no real sales-history
/// data model yet, so every panel here honestly shows an empty state
/// instead of fabricated numbers.
class ManagementDashboardPage extends StatefulWidget {
  const ManagementDashboardPage({super.key});

  @override
  State<ManagementDashboardPage> createState() => _ManagementDashboardPageState();
}

class _ManagementDashboardPageState extends State<ManagementDashboardPage> {
  late int _year = DateTime.now().year;
  late DateTimeRange _reportRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  bool _showBarValues = true;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _reportRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DashboardColors.accentBlue,
            surface: DashboardColors.toolbarBackground,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) setState(() => _reportRange = range);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildMonthlySalesCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildTotalSalesCard()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: DashboardColors.border)),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Periodic Reports ( ${_formatDate(_reportRange.start)} - ${_formatDate(_reportRange.end)} )',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _EmptyCard(title: 'Top Products')),
                const SizedBox(width: 16),
                Expanded(child: _EmptyCard(title: 'Hourly Sales')),
                const SizedBox(width: 16),
                Expanded(child: _buildBigNumberCard('Total Sales (Amount)', '0')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _EmptyCard(
                    title: 'Top Product Groups',
                    subtitle: 'Top selling product groups in selected period',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EmptyCard(
                    title: 'Top Customers',
                    subtitle: 'Lead customers in selected period (top 5)',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySalesCard() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: DashboardColors.border)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Sales - $_year',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sales data grouped by month',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
              _CompactIconButton(icon: Icons.refresh, tooltip: 'Refresh', onTap: () => setState(() {})),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _showBarValues,
                  activeThumbColor: DashboardColors.accentBlue,
                  onChanged: (value) => setState(() => _showBarValues = value),
                ),
              ),
              _CompactIconButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous year',
                onTap: () => setState(() => _year--),
              ),
              _CompactIconButton(
                icon: Icons.chevron_right,
                tooltip: 'Next year',
                onTap: () => setState(() => _year++),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final _ in _months)
                        Expanded(
                          child: _showBarValues
                              ? const Text(
                                  '0',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: DashboardColors.textMuted, fontSize: 13),
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
                const Divider(color: DashboardColors.border, height: 1),
                const SizedBox(height: 6),
                const Text('Month', style: TextStyle(color: DashboardColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSalesCard() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: DashboardColors.border)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Sales',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 16),
          const Text(
            '0.00',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Top performing month:',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text('---', maxLines: 1, style: TextStyle(color: DashboardColors.textMuted, fontSize: 13)),
          const SizedBox(height: 4),
          const Text(
            '0.00',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBigNumberCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: DashboardColors.border)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
          ),
          Expanded(
            child: Center(
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 18),
      onPressed: onTap,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: DashboardColors.border)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
          const Expanded(
            child: Center(
              child: Text(
                'No data to display',
                textAlign: TextAlign.center,
                style: TextStyle(color: DashboardColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
