import 'package:flutter/material.dart';

class AddNewProjectCard extends StatelessWidget {
  // 1. Declare the data your widget needs as final variables
  final String title;
  final String lastModified;
  final VoidCallback onTap;

  // 2. Add constructor with 'required' parameters and super.key
  const AddNewProjectCard({
    super.key,
    required this.title,
    required this.lastModified,
    required this.onTap,
  });

  // 3. Build the UI tree
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 40),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  lastModified,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}