import 'package:chess_game/components/piece.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? selectedColor;

    if (isSelected) {
      selectedColor = const Color.fromARGB(255, 11, 113, 64);
    } else if (isValidMove) {
      selectedColor = Colors.green;
    } else {
      selectedColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: selectedColor,
        margin: EdgeInsets.all(isValidMove ? 2 : 0),
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                color: piece!.isWhite ? Colors.white : Colors.black,
              )
            : null,
      ),
    );
  }
}
