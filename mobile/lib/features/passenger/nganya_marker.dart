import 'package:flutter/material.dart';

class NganyaMarker extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const NganyaMarker({super.key, required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Pin with photo or icon
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
            Positioned(
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(photoUrl!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/branding/app_icon.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
