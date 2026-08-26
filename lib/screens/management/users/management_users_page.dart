import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../dashboard/dashboard_colors.dart';

/// The Management area's "Users & security" section. There's no multi-user
/// backend yet, so the Users tab honestly lists just the one signed-in
/// account rather than fabricated staff, and every action beyond viewing it
/// is wired to a "coming soon" notice.
class ManagementUsersPage extends StatefulWidget {
  const ManagementUsersPage({super.key});

  @override
  State<ManagementUsersPage> createState() => _ManagementUsersPageState();
}

class _ManagementUsersPageState extends State<ManagementUsersPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  bool _showInactiveUsers = true;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: DashboardColors.textMuted,
          indicatorColor: DashboardColors.accentBlue,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Security'),
          ],
        ),
        const Divider(color: DashboardColors.border, height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _UsersTab(
                showInactiveUsers: _showInactiveUsers,
                onShowInactiveUsersChanged: (value) => setState(() => _showInactiveUsers = value),
                onComingSoon: _showComingSoon,
              ),
              Center(
                child: Text(
                  'Security coming soon.',
                  style: const TextStyle(color: DashboardColors.textMuted, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({
    required this.showInactiveUsers,
    required this.onShowInactiveUsersChanged,
    required this.onComingSoon,
  });

  final bool showInactiveUsers;
  final ValueChanged<bool> onShowInactiveUsersChanged;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser.value;
    final nameParts = user?.name.trim().split(RegExp(r'\s+')) ?? const [];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DashboardColors.border)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolbarButton(icon: Icons.refresh, label: 'Refresh', onTap: () {}),
                _ToolbarButton(icon: Icons.add, label: 'Add user', onTap: () => onComingSoon('Adding a user')),
                const _ToolbarButton(icon: Icons.edit_outlined, label: 'Edit', onTap: null),
                const _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: null),
                const _ToolbarButton(icon: Icons.password_outlined, label: 'Reset password', onTap: null),
                _ToolbarSwitch(
                  label: 'Show inactive users',
                  value: showInactiveUsers,
                  onChanged: onShowInactiveUsersChanged,
                ),
                _ToolbarButton(icon: Icons.help_outline, label: 'Help', onTap: () => onComingSoon('Help')),
              ],
            ),
          ),
        ),
        const _TableHeader(),
        if (user != null)
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 14))),
                Expanded(flex: 3, child: Text(lastName, style: const TextStyle(color: Colors.white, fontSize: 14))),
                Expanded(flex: 5, child: Text(user.email, style: const TextStyle(color: Colors.white, fontSize: 14))),
                const Expanded(
                  flex: 3,
                  child: Text('Owner', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(
                  width: 80,
                  child: Icon(Icons.check, color: DashboardColors.accentGreen, size: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: DashboardColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('First name', style: style)),
          Expanded(flex: 3, child: Text('Last name', style: style)),
          Expanded(flex: 5, child: Text('Email', style: style)),
          Expanded(flex: 3, child: Text('Access level', style: style)),
          SizedBox(width: 80, child: Text('Active', style: style)),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? Colors.white : DashboardColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarSwitch extends StatelessWidget {
  const _ToolbarSwitch({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeThumbColor: DashboardColors.accentGreen,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
