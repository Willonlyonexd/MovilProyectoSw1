import 'package:flutter/material.dart';

class AnimatedMovingGradientText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final List<Color> gradientColors; // Colores para el gradiente
  final Duration duration; // Duración de la animación

  const AnimatedMovingGradientText({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.gradientColors,
    this.duration = const Duration(seconds: 5), // Animación más larga
  }) : super(key: key);

  @override
  _AnimatedMovingGradientTextState createState() =>
      _AnimatedMovingGradientTextState();
}

class _AnimatedMovingGradientTextState extends State<AnimatedMovingGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // Repetir animación infinitamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final double animationValue = _controller.value;

            return LinearGradient(
              colors: widget.gradientColors,
              stops: List.generate(
                widget.gradientColors.length,
                (index) => index / (widget.gradientColors.length - 1),
              ),
              begin: Alignment(-2.0 + animationValue * 4, 0.0), // Ajustamos el rango
              end: Alignment(2.0 + animationValue * 4, 0.0),   // para continuidad
              tileMode: TileMode.mirror, // Efecto de reflejo en los bordes
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.textStyle.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}