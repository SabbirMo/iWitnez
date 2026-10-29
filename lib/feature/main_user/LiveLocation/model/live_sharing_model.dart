import 'package:flutter/material.dart';

class SharingPersonModel {
  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final bool isLive;
  final bool isSharingWith;
  final Color fallbackColor;
  final double? latitude;
  final double? longitude;

  const SharingPersonModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.isLive = false,
    this.isSharingWith = true,
    this.fallbackColor = const Color(0xFF6B7280),
    this.latitude,
    this.longitude,
  });

  SharingPersonModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? imageUrl,
    bool? isLive,
    bool? isSharingWith,
    Color? fallbackColor,
    double? latitude,
    double? longitude,
  }) {
    return SharingPersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      isLive: isLive ?? this.isLive,
      isSharingWith: isSharingWith ?? this.isSharingWith,
      fallbackColor: fallbackColor ?? this.fallbackColor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
