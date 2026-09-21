import 'package:flutter/material.dart';

class MissionContent extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const MissionContent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        
        // Target Image from Assets
        Image.asset(
          image,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if the image path is wrong or missing
            return const Icon(
              Icons.gps_fixed,
              size: 100,
              color: Color(0xFF8B5CF6),
            );
          },
        ),
        
        const SizedBox(height: 40),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}