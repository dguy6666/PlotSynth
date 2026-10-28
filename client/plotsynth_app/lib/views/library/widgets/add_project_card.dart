

import 'package:flutter/material.dart';


class AddProjectCard extends StatelessWidget {

  final VoidCallback onTap;
  

  const AddProjectCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12.0);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays inside rounded card corners
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 40),
                SizedBox(height: 8),
                Text(
                  'New Project',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

