import 'package:flutter/material.dart';

class SharingPersonModel {
  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final bool isLive;
  final Color fallbackColor;
  final double? relativeX;
  final double? relativeY;

  const SharingPersonModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.isLive = false,
    this.fallbackColor = const Color(0xFF6B7280),
    this.relativeX,
    this.relativeY,
  });

  SharingPersonModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? imageUrl,
    bool? isLive,
    Color? fallbackColor,
    double? relativeX,
    double? relativeY,
  }) {
    return SharingPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      isLive: isLive ?? this.isLive,
      fallbackColor: fallbackColor ?? this.fallbackColor,
      relativeX: relativeX ?? this.relativeX,
      relativeY: relativeY ?? this.relativeY,
    );
  }
}
