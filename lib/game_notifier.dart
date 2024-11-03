import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Player { player1, player2 }

class GameBoard {
  List<List<Player?>> board = List.generate(4, (_) => List.filled(4, null));
  List<List<List<Player?>>> history = [];  // To store the board states for history view

  bool placeMarble(Player player, int x, int y) {
    if (board[x][y] == null) {
      board[x][y] = player;
      _addToHistory();
      return true;
    }
    return false;
  }

  void moveMarblesCounterclockwise() {
    List<List<Player?>> newBoard = List.generate(4, (_) => List.filled(4, null));

    // Define counterclockwise movement for outer and inner rings
    List<List<int>> outerRing = [
      [0, 0], [0, 1], [0, 2], [0, 3],
      [1, 3], [2, 3], [3, 3], [3, 2],
      [3, 1], [3, 0], [2, 0], [1, 0],
    ];
    List<List<int>> innerRing = [
      [1, 1], [1, 2], [2, 2], [2, 1],
    ];

    for (int i = 0; i < outerRing.length; i++) {
      var next = outerRing[(i + 1) % outerRing.length];
      newBoard[next[0]][next[1]] = board[outerRing[i][0]][outerRing[i][1]];
    }
    for (int i = 0; i < innerRing.length; i++) {
      var next = innerRing[(i + 1) % innerRing.length];
      newBoard[next[0]][next[1]] = board[innerRing[i][0]][innerRing[i][1]];
    }

    board = newBoard;
    _addToHistory();
  }

  bool checkWinningCondition(Player player) {
    // Check rows, columns, and diagonals for 4 consecutive marbles
    for (int i = 0; i < 4; i++) {
      if (_checkLine(player, [board[i][0], board[i][1], board[i][2], board[i][3]]) ||
          _checkLine(player, [board[0][i], board[1][i], board[2][i], board[3][i]])) {
        return true;
      }
    }
    // Diagonals
    if (_checkLine(player, [board[0][0], board[1][1], board[2][2], board[3][3]]) ||
        _checkLine(player, [board[0][3], board[1][2], board[2][1], board[3][0]])) {
      return true;
    }
    return false;
  }

  bool _checkLine(Player player, List<Player?> line) {
    return line.every((cell) => cell == player);
  }

  bool isFull() {
    return board.every((row) => row.every((cell) => cell != null));
  }

  void _addToHistory() {
    history.add(List.generate(4, (i) => List.from(board[i])));
  }
}

class GameNotifier extends StateNotifier<GameBoard> {
  GameNotifier() : super(GameBoard());

  Player currentPlayer = Player.player1;
  bool gameWon = false;
  bool isDraw = false;

  bool placeMarble(int x, int y) {
    if (!gameWon && state.placeMarble(currentPlayer, x, y)) {
      if (state.checkWinningCondition(currentPlayer)) {
        gameWon = true;
      } else if (state.isFull()) {
        isDraw = true;
      } else {
        state.moveMarblesCounterclockwise();
        state = GameBoard()..board = state.board; // Force UI update
        togglePlayer();
      }
      return true; // Return true if the marble was placed successfully
    }
    return false; // Return false if the marble placement was unsuccessful
  }


  void togglePlayer() {
    if (!gameWon && !isDraw) {
      currentPlayer = currentPlayer == Player.player1 ? Player.player2 : Player.player1;
    }
  }

  void resetGame() {
    state = GameBoard();
    currentPlayer = Player.player1;
    gameWon = false;
    isDraw = false;
  }

  List<List<List<Player?>>> get history => state.history;
}

final gameProvider = StateNotifierProvider<GameNotifier, GameBoard>((ref) => GameNotifier());
