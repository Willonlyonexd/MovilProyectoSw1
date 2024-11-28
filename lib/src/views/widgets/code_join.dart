import 'package:flutter/material.dart';

class CodeInputField extends StatefulWidget {
  final int length; // Longitud del código
  final void Function(String)
      onCompleted; // Callback cuando el usuario complete el código

  const CodeInputField({
    Key? key,
    this.length = 4, // Por defecto, 4 dígitos
    required this.onCompleted,
  }) : super(key: key);

  @override
  _CodeInputFieldState createState() => _CodeInputFieldState();
}

class _CodeInputFieldState extends State<CodeInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Mover al siguiente campo si no es el último
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // Llamar al callback cuando todos los campos estén llenos
        final code = _controllers.map((controller) => controller.text).join();
        widget.onCompleted(code);
      }
    } else {
      // Mover al campo anterior si está vacío
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple, width: 2),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLength: 1,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '', // Ocultar el contador de caracteres
              ),
              onChanged: (value) => _onTextChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
