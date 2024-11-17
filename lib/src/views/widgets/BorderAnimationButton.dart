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
              borderRadius: 30, // Radio del borde redondeado
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
  final double borderRadius;

  BorderAnimationPainter({
    required this.animationValue,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // Creamos el rectángulo con bordes redondeados
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Creamos el Path del borde redondeado
    final Path path = Path()..addRRect(roundedRect);

    // Calculamos el perímetro total
    final PathMetric pathMetric = path.computeMetrics().first;
    final double perimeter = pathMetric.length;

    // Calculamos la posición animada y el segmento visible
    final double start = perimeter * animationValue;
    final double end = start + perimeter / 2; // Visible la mitad del perímetro

    // Manejo continuo: usar % para que la animación sea fluida
    final Path segment = Path();
    if (end > perimeter) {
      segment.addPath(
        pathMetric.extractPath(start, perimeter),
        Offset.zero,
      );
      segment.addPath(
        pathMetric.extractPath(0, end - perimeter),
        Offset.zero,
      );
    } else {
      segment.addPath(
        pathMetric.extractPath(start, end),
        Offset.zero,
      );
    }

    // Dibujamos el borde animado
    canvas.drawPath(segment, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
