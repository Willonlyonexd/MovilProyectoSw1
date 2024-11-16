import 'package:flutter/material.dart';

class CustomNeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CustomNeonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  _CustomNeonButtonState createState() => _CustomNeonButtonState();
}

class _CustomNeonButtonState extends State<CustomNeonButton> {
  bool isPressed = false; // Controla si el botón está presionado.

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isPressed ? widget.color.withOpacity(0.8) : widget.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isPressed
              ? [
                  // Efecto de neón al presionar
                  BoxShadow(
                    color: widget.color.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 3,
                  )
                ]
              : [
                  // Efecto suave cuando no está presionado
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
