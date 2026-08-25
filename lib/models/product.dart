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
    this.active = true,
    this.color = 'Transparent',
    this.imagePath,
    this.defaultQuantity = true,
    this.isService = false,
    this.ageRestriction,
    this.markup = 0,
    this.priceIncludesTax = true,
    this.priceChangeAllowed = false,
    this.reorderPoint = 0,
    this.preferredQuantity = 0,
    this.lowStockWarning = false,
    this.lowStockWarningQuantity = 0,
    this.comments = const [],
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
  final bool active;
  final String color;
  final String? imagePath;
  final bool defaultQuantity;
  final bool isService;
  final int? ageRestriction;
  final double markup;
  final bool priceIncludesTax;
  final bool priceChangeAllowed;
  final num reorderPoint;
  final num preferredQuantity;
  final bool lowStockWarning;
  final num lowStockWarningQuantity;
  final List<String> comments;

  Product copyWith({
    String? name,
    double? price,
    IconData? icon,
    String? description,
    String? code,
    String? barcode,
    num? quantityOnHand,
    String? quantityUnit,
    double? cost,
    bool? active,
    String? color,
    String? imagePath,
    bool? defaultQuantity,
    bool? isService,
    int? ageRestriction,
    double? markup,
    bool? priceIncludesTax,
    bool? priceChangeAllowed,
    num? reorderPoint,
    num? preferredQuantity,
    bool? lowStockWarning,
    num? lowStockWarningQuantity,
    List<String>? comments,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      cost: cost ?? this.cost,
      active: active ?? this.active,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
      isService: isService ?? this.isService,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      markup: markup ?? this.markup,
      priceIncludesTax: priceIncludesTax ?? this.priceIncludesTax,
      priceChangeAllowed: priceChangeAllowed ?? this.priceChangeAllowed,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      preferredQuantity: preferredQuantity ?? this.preferredQuantity,
      lowStockWarning: lowStockWarning ?? this.lowStockWarning,
      lowStockWarningQuantity: lowStockWarningQuantity ?? this.lowStockWarningQuantity,
      comments: comments ?? this.comments,
    );
  }
}
