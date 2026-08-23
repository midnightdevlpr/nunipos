import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.name,
    required this.price,
    required this.icon,
    this.description = '',
    this.code = '',
    this.barcode = '',
    this.quantityOnHand = 0,
    this.quantityUnit = 'pcs',
    this.cost = 0,
  });

  final String name;
  final double price;
  final IconData icon;
  final String description;
  final String code;
  final String barcode;
  final num quantityOnHand;
  final String quantityUnit;
  final double cost;
}
