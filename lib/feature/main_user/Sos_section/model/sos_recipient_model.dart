import 'package:flutter/material.dart';

class SosRecipientModel {
  final String id;
  final String contactName;
  final String relationship;
  final String deliveryStatus;
  final bool isShared;

  const SosRecipientModel({
    required this.id,
    required this.contactName,
    required this.relationship,
    this.deliveryStatus = 'delivered',
    this.isShared = true,
  });

  factory SosRecipientModel.fromJson(Map<String, dynamic> json) {
    return SosRecipientModel(
      id: json['id']?.toString() ?? '',
      contactName: json['contact_name']?.toString() ??
          json['name']?.toString() ??
          '',
      relationship: json['relationship']?.toString() ??
          json['relation']?.toString() ??
          'Contact',
      deliveryStatus: json['delivery_status']?.toString() ?? 'delivered',
      isShared: json['is_shared'] != false,
    );
  }

  Color get relationshipBgColor {
    final rel = relationship.toLowerCase();
    if (rel.contains('father') || rel.contains('mother') || rel.contains('parent')) {
      return const Color(0xFFFEF3C7);
    } else if (rel.contains('brother') || rel.contains('sister') || rel.contains('sibling')) {
      return const Color(0xFFF3E8FF);
    } else if (rel.contains('friend')) {
      return const Color(0xFFEFF6FF);
    } else if (rel.contains('partner') || rel.contains('spouse')) {
      return const Color(0xFFFCE7F3);
    }
    return const Color(0xFFECFDF5);
  }

  Color get relationshipTextColor {
    final rel = relationship.toLowerCase();
    if (rel.contains('father') || rel.contains('mother') || rel.contains('parent')) {
      return const Color(0xFFD97706);
    } else if (rel.contains('brother') || rel.contains('sister') || rel.contains('sibling')) {
      return const Color(0xFF7C3AED);
    } else if (rel.contains('friend')) {
      return const Color(0xFF2563EB);
    } else if (rel.contains('partner') || rel.contains('spouse')) {
      return const Color(0xFFDB2777);
    }
    return const Color(0xFF059669);
  }
}

