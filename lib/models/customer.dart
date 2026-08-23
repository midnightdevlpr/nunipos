class Customer {
  const Customer({
    required this.name,
    this.taxNumber = '',
    this.streetName = '',
    this.buildingNumber = '',
    this.additionalStreetName = '',
    this.plotIdentification = '',
    this.district = '',
    this.postalCode = '',
    this.city = '',
    this.stateProvince = '',
    this.country = '',
    this.phoneNumber = '',
    this.email = '',
    this.loyaltyCard = '',
    this.taxExempt = false,
  });

  static const walkIn = Customer(name: 'Walk-in customer');

  final String name;
  final String taxNumber;
  final String streetName;
  final String buildingNumber;
  final String additionalStreetName;
  final String plotIdentification;
  final String district;
  final String postalCode;
  final String city;
  final String stateProvince;
  final String country;
  final String phoneNumber;
  final String email;
  final String loyaltyCard;
  final bool taxExempt;

  bool get isWalkIn => identical(this, walkIn);

  String get displayAddress {
    final parts = [
      streetName,
      buildingNumber,
      additionalStreetName,
      plotIdentification,
      district,
      postalCode,
      city,
      stateProvince,
      country,
    ].where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  String get displayTaxNumber => taxNumber.isEmpty ? 'N/A' : taxNumber;
  String get displayEmail => email.isEmpty ? 'N/A' : email;
  String get displayPhoneNumber => phoneNumber.isEmpty ? 'N/A' : phoneNumber;
}
