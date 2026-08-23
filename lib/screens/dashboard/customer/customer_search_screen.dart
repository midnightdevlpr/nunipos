import 'package:flutter/material.dart';

import '../../../models/customer.dart';
import '../dashboard_colors.dart';
import 'new_customer_screen.dart';

/// Full-screen customer search: filter by name/tax number/email/phone/loyalty
/// card, preview the match, and confirm to attach it to the sale.
class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key, required this.customers, required this.initial});

  final List<Customer> customers;
  final Customer? initial;

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final _nameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loyaltyCardController = TextEditingController();

  late Customer? _selected = widget.initial;
  late final List<Customer> _addedCustomers = List.of(widget.customers);

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _taxNumberController,
      _emailController,
      _phoneController,
      _loyaltyCardController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _loyaltyCardController.dispose();
    super.dispose();
  }

  List<Customer> get _results {
    final name = _nameController.text.trim().toLowerCase();
    final taxNumber = _taxNumberController.text.trim().toLowerCase();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim().toLowerCase();
    final loyaltyCard = _loyaltyCardController.text.trim().toLowerCase();

    final all = [Customer.walkIn, ..._addedCustomers];
    return all.where((customer) {
      if (name.isNotEmpty && !customer.name.toLowerCase().contains(name)) return false;
      if (taxNumber.isNotEmpty && !customer.taxNumber.toLowerCase().contains(taxNumber)) return false;
      if (email.isNotEmpty && !customer.email.toLowerCase().contains(email)) return false;
      if (phone.isNotEmpty && !customer.phoneNumber.toLowerCase().contains(phone)) return false;
      if (loyaltyCard.isNotEmpty && !customer.loyaltyCard.toLowerCase().contains(loyaltyCard)) return false;
      return true;
    }).toList();
  }

  Future<void> _addNewCustomer() async {
    final customer = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(builder: (_) => const NewCustomerScreen()),
    );
    if (customer == null) return;
    setState(() {
      _addedCustomers.add(customer);
      _selected = customer;
    });
  }

  void _confirm() {
    if (_selected == null) return;
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: DashboardColors.border),
                        bottom: BorderSide(color: DashboardColors.border),
                      ),
                    ),
                    child: const Text(
                      'Search customer',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: DashboardColors.border)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Selected customer',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _SearchField(controller: _nameController, hint: 'Name', autofocus: true),
                      _SearchField(controller: _taxNumberController, hint: 'Tax number'),
                      _SearchField(controller: _emailController, hint: 'Email'),
                      _SearchField(controller: _phoneController, hint: 'Phone number'),
                      _SearchField(controller: _loyaltyCardController, hint: 'Loyalty card'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final customer = results[index];
                            final isSelected = customer == _selected;
                            return InkWell(
                              onTap: () => setState(() => _selected = customer),
                              child: Container(
                                width: double.infinity,
                                color: isSelected ? DashboardColors.accentBlue : null,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      customer.isWalkIn ? '---' : customer.displayPhoneNumber,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  color: DashboardColors.border,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addNewCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DashboardColors.accentGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.person_add_alt, size: 18),
                          label: const Text('Add new customer'),
                        ),
                        const SizedBox(height: 24),
                        if (_selected == null)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info, color: DashboardColors.accentRed, size: 72),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Customer not selected',
                                    style: TextStyle(
                                      color: DashboardColors.accentRed,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Select customer from the list',
                                    style: TextStyle(color: DashboardColors.accentRed.withValues(alpha: 0.85)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          Text(
                            _selected!.name,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(height: 20),
                          _DetailRow(label: 'Address:', value: _selected!.displayAddress),
                          _DetailRow(label: 'Tax number:', value: _selected!.displayTaxNumber),
                          _DetailRow(label: 'Email:', value: _selected!.displayEmail),
                          _DetailRow(label: 'Phone number:', value: _selected!.displayPhoneNumber),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _selected = null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: DashboardColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Clear selected customer'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _selected == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DashboardColors.accentGreen.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('OK'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hint, this.autofocus = false});

  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.search, color: DashboardColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: DashboardColors.accentBlue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: DashboardColors.textMuted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
