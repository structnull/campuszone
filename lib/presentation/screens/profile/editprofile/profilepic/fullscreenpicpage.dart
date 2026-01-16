import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class FullScreenPicture extends StatelessWidget {
  final String imageUrl;
  const FullScreenPicture({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the Scaffold background to transparent.
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Full-screen semi-transparent background using Color.fromRGBO. (NOT WORKING)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(0, 0, 0, 0.3),
          ),
          // Centered interactive image.
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/profile.png',
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
