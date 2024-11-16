import 'package:flutter/material.dart';

class RoomCodeDisplay extends StatelessWidget {
  final String roomCode;

  const RoomCodeDisplay({Key? key, required this.roomCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Código: $roomCode',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
