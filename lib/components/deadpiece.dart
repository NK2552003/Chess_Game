import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      color: isWhite
          ? const Color.fromARGB(255, 221, 219, 219)
          : const Color.fromARGB(255, 32, 32, 32),
    );
  }
}
