import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message; // Mensaje opcional debajo del indicador.

  const LoadingIndicator({this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(), // Indicador circular animado.
          if (message != null) ...[
            SizedBox(height: 10),
            Text(
              message!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ],
        ],
      ),
    );
  }
}
