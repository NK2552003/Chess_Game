import 'dart:async';

import 'package:chess_game/components/deadpiece.dart';
import 'package:chess_game/components/hepler_method.dart';
import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;

  int selectedRow = -1;
  int selectedCol = -1;
  //representing the moves here

  List<List<int>> validMoves = [];
  //list of white pieces that has been taken by black player
  List<ChessPiece> whitePiecesTaken = [];
  //list of black pieces that has been taken by while player
  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn = true;
  //checkmate
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  int _minutes = 20;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _minutes--;
          _seconds = 59;
        }
        if (_minutes == 0 && _seconds == 0) {
          _timer?.cancel();
          // Game over!
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: const Text("Time's up!",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600)),
                    actions: [
                      TextButton(
                          onPressed: resetGame,
                          child: const Text(
                            "Play Again",
                          )),
                    ],
                  ));
        }
      });
    });
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          imagePath: 'images/pown.png',
          isWhite: false);

      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          imagePath: 'images/pown.png',
          isWhite: true);
    }

    //pace rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        imagePath: 'images/rook.png',
        isWhite: false);
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        imagePath: 'images/rook.png',
        isWhite: false);
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook, imagePath: 'images/rook.png', isWhite: true);
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook, imagePath: 'images/rook.png', isWhite: true);
    //place knights

    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        imagePath: 'images/knight.png',
        isWhite: false);
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        imagePath: 'images/knight.png',
        isWhite: false);
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        imagePath: 'images/knight.png',
        isWhite: true);
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        imagePath: 'images/knight.png',
        isWhite: true);
    //place king
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        imagePath: 'images/king.png',
        isWhite: false);
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king, imagePath: 'images/king.png', isWhite: true);
    //place queen
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        imagePath: 'images/queen.png',
        isWhite: false);
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        imagePath: 'images/queen.png',
        isWhite: true);
    //place bishop
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        imagePath: 'images/bishop.png',
        isWhite: false);
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        imagePath: 'images/bishop.png',
        isWhite: false);
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        imagePath: 'images/bishop.png',
        isWhite: true);
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        imagePath: 'images/bishop.png',
        isWhite: true);
    board = newBoard;
  }

  //user selection
  void pieceSelected(int row, int col) {
    setState(() {
      //no piece has been selected yet
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedCol = col;
          selectedRow = row;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedCol = col;
        selectedRow = row;
      }
      //if there is a piece selected and user taps on another square that is a valid move
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      //if the piece is selected calculate the moves of piece
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    //different directions based on their color
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        // Can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // 2 steps ahead if not occupied and pawn is at starting position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Pawn can capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        // Horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1] // right
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // All eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1] // down 2 right 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.king:
        // All eight directions
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.queen:
        // All eight directions
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.bishop:
        // Directions diagonally
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1] // down right
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      default:
        break;
    }
    return candidateMoves;
  }

  //calculate real valid moves
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  //ability to move pieces
  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    //checking if the piece being moved is a king
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;
    //see if any king are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text("CheckMate!",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                actions: [
                  TextButton(
                      onPressed: resetGame,
                      child: const Text(
                        "Play Again",
                      )),
                ],
              ));
    }
    isWhiteTurn = !isWhiteTurn;
  }

  //iskingincheck method
  bool isKingInCheck(bool isWhiteKing) {
    //get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    //save the current board state
    ChessPiece? originalDestinationPage = board[endRow][endCol];

    //original king position
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check is our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //return the board to its original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPage;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  //is it checkmate
  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    _minutes = 20;
    _seconds = 0;
    _startTimer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Center(
                    child: Text(
                  checkStatus ? "CHECK!" : "",
                  style:const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.red),
                )),
                //white pieces taken
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: whitePiecesTaken.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemBuilder: (context, index) => DeadPiece(
                      imagePath: whitePiecesTaken[index].imagePath,
                      isWhite: true,
                    ),
                  ),
                ),
                //chess Board
                Expanded(
                  flex: 3,
                  child: GridView.builder(
                      itemCount: 8 * 8,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8),
                      itemBuilder: (context, index) {
                        int row = index ~/ 8;
                        int col = index % 8;
                        bool isSelected =
                            selectedCol == col && selectedRow == row;
                        //checking the valid move
                        bool isValidMove = false;
                        for (var position in validMoves) {
                          if (position[0] == row && position[1] == col) {
                            isValidMove = true;
                          }
                        }

                        return Square(
                          isValidMove: isValidMove,
                          onTap: () => pieceSelected(row, col),
                          isWhite: isWhite(index),
                          piece: board[row][col],
                          isSelected: isSelected,
                        );
                      }),
                ),
                //black pieces taken
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: blackPiecesTaken.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8),
                    itemBuilder: (context, index) => DeadPiece(
                      imagePath: blackPiecesTaken[index].imagePath,
                      isWhite: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
