import 'dart:ui';
import 'package:flutter/material.dart';

class BorderAnimationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color borderColor; // Color del borde animado
  final Color textColor;
  final Color buttonColor;
  final double borderWidth;

  const BorderAnimationButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.borderColor = Colors.blue,
    this.textColor = Colors.white,
    this.buttonColor = Colors.black,
    this.borderWidth = 2.0,
  }) : super(key: key);

  @override
  _BorderAnimationButtonState createState() => _BorderAnimationButtonState();
}

class _BorderAnimationButtonState extends State<BorderAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Repetir infinitamente la animación
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: BorderAnimationPainter(
              animationValue: _controller.value,
              borderColor: widget.borderColor,
              borderWidth: widget.borderWidth,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: widget.buttonColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BorderAnimationPainter extends CustomPainter {
  final double animationValue;
  final Color borderColor;
  final double borderWidth;

  BorderAnimationPainter({
    required this.animationValue,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final double perimeter = (size.width * 2 + size.height * 2);
    final double animatedLength = perimeter * animationValue;

    final Path path = Path()
      ..moveTo(0, 0) // Esquina superior izquierda
      ..lineTo(size.width, 0) // Línea superior
      ..lineTo(size.width, size.height) // Línea derecha
      ..lineTo(0, size.height) // Línea inferior
      ..close(); // Cerrar el contorno (hacia la izquierda)

    final PathMetric pathMetric = path.computeMetrics().first;
    final Path extractPath =
        pathMetric.extractPath(animatedLength, animatedLength + perimeter / 4);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
