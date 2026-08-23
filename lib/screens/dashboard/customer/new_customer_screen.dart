import 'package:flutter/material.dart';

import '../../../models/countries.dart';
import '../../../models/customer.dart';
import '../dashboard_colors.dart';

/// Full-page form for adding a new customer. Only Name is required.
class NewCustomerScreen extends StatefulWidget {
  const NewCustomerScreen({super.key});

  @override
  State<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  final _nameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _additionalStreetNameController = TextEditingController();
  final _plotIdentificationController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateProvinceController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  String _country = countries.first;
  bool _taxExempt = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxNumberController.dispose();
    _streetNameController.dispose();
    _buildingNumberController.dispose();
    _additionalStreetNameController.dispose();
    _plotIdentificationController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _stateProvinceController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _nameIsEmpty => _nameController.text.trim().isEmpty;

  void _confirm() {
    if (_nameIsEmpty) return;
    Navigator.of(context).pop(
      Customer(
        name: _nameController.text.trim(),
        taxNumber: _taxNumberController.text.trim(),
        streetName: _streetNameController.text.trim(),
        buildingNumber: _buildingNumberController.text.trim(),
        additionalStreetName: _additionalStreetNameController.text.trim(),
        plotIdentification: _plotIdentificationController.text.trim(),
        district: _districtController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        city: _cityController.text.trim(),
        stateProvince: _stateProvinceController.text.trim(),
        country: _country,
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        taxExempt: _taxExempt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: Row(
              children: [
                const Text(
                  'New customer',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormRow(
                      label: 'Name',
                      child: _CustomerField(controller: _nameController, hasError: _nameIsEmpty),
                    ),
                    _FormRow(label: 'Tax number', child: _CustomerField(controller: _taxNumberController)),
                    _FormRow(label: 'Street name', child: _CustomerField(controller: _streetNameController)),
                    _FormRow(
                      label: 'Building number',
                      child: _CustomerField(controller: _buildingNumberController),
                    ),
                    _FormRow(
                      label: 'Additional street name',
                      child: _CustomerField(controller: _additionalStreetNameController),
                    ),
                    _FormRow(
                      label: 'Plot identification',
                      child: _CustomerField(controller: _plotIdentificationController),
                    ),
                    _FormRow(label: 'District', child: _CustomerField(controller: _districtController)),
                    _FormRow(label: 'Postal code', child: _CustomerField(controller: _postalCodeController)),
                    _FormRow(label: 'City', child: _CustomerField(controller: _cityController)),
                    _FormRow(
                      label: 'State / Province',
                      child: _CustomerField(controller: _stateProvinceController),
                    ),
                    _FormRow(
                      label: 'Country',
                      child: DropdownButtonFormField<String>(
                        initialValue: _country,
                        dropdownColor: DashboardColors.toolbarBackground,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _fieldDecoration(),
                        items: [
                          for (final country in countries)
                            DropdownMenuItem(value: country, child: Text(country)),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _country = value);
                        },
                      ),
                    ),
                    _FormRow(
                      label: 'Phone number',
                      child: _CustomerField(controller: _phoneNumberController, keyboardType: TextInputType.phone),
                    ),
                    _FormRow(
                      label: 'Email',
                      child: _CustomerField(controller: _emailController, keyboardType: TextInputType.emailAddress),
                    ),
                    _FormRow(
                      label: 'Tax exempt',
                      compact: true,
                      child: Switch(
                        value: _taxExempt,
                        activeThumbColor: DashboardColors.accentGreen,
                        onChanged: (value) => setState(() => _taxExempt = value),
                      ),
                    ),
                  ],
                ),
              ),
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
                  onPressed: _nameIsEmpty ? null : _confirm,
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

InputDecoration _fieldDecoration({bool hasError = false}) {
  final borderColor = hasError ? DashboardColors.accentRed : DashboardColors.border;
  return InputDecoration(
    filled: true,
    fillColor: DashboardColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: borderColor)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: borderColor)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(color: hasError ? DashboardColors.accentRed : DashboardColors.accentBlue, width: 2),
    ),
  );
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.child, this.compact = false});

  final String label;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 180, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
          const SizedBox(width: 16),
          compact ? child : Expanded(child: child),
        ],
      ),
    );
  }
}

class _CustomerField extends StatelessWidget {
  const _CustomerField({required this.controller, this.hasError = false, this.keyboardType});

  final TextEditingController controller;
  final bool hasError;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: DashboardColors.accentBlue,
      decoration: _fieldDecoration(hasError: hasError),
    );
  }
}
