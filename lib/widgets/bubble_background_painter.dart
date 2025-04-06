import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  final Color color;

  BubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Create the path for the bubble shape
    final path = Path();
    path.lineTo(0, size.height * 1.15); // Start curve lower down
    // Add a quadratic bezier curve for the bottom swoosh
    path.quadraticBezierTo(
      size.width / 2, // Control point x (middle)
      size.height * 1.15, // Control point y (below the bottom edge for curve)
      size.width, // End point x (right edge)
      size.height * 0.85, // End point y (matches left side)
    );
    path.lineTo(size.width, 0); // Line to top-right
    path.close(); // Close path back to top-left

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if the color changes
    return oldDelegate is BubblePainter && oldDelegate.color != color;
  }
}

// Helper Widget to use the painter
class BubbleHeaderBackground extends StatelessWidget {
  final double height;

  const BubbleHeaderBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: BubblePainter(
          color:
              Theme.of(context).colorScheme.primary, // Use primary theme color
        ),
      ),
    );
  }
}
