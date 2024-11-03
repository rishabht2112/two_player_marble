import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_notifier.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int timer = 10; // 10-second timer per turn
  Timer? turnTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    turnTimer?.cancel(); // Cancel any active timer on dispose
    super.dispose();
  }

  void startTimer() {
    turnTimer?.cancel(); // Cancel the previous timer before starting a new one
    timer = 10;
    turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (this.timer > 0) {
        setState(() => this.timer--);
      } else {
        ref.read(gameProvider.notifier).togglePlayer();  // Automatically switch player when time is up
        startTimer(); // Restart timer for the next player
      }
    });
  }

  void resetTimer() {
    turnTimer?.cancel(); // Cancel the existing timer
    timer = 10; // Reset the timer to the initial value
    startTimer(); // Start a new timer
  }

  @override
  Widget build(BuildContext context) {
    final gameBoard = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final currentPlayer = gameNotifier.currentPlayer;

    // Stop the timer if game ends
    if (gameNotifier.gameWon || gameNotifier.isDraw) {
      turnTimer?.cancel();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Two Player Marble Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[700]!, Colors.blueAccent],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        leading: IconButton(
          icon: Icon(Icons.gamepad_outlined, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.gamepad_outlined, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Status
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                color: gameNotifier.gameWon ? Colors.green[100] : Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    gameNotifier.gameWon
                        ? "${currentPlayer == Player.player1 ? "Player 1" : "Player 2"} Wins!"
                        : gameNotifier.isDraw
                        ? "It's a Draw!"
                        : "Current Turn: ${currentPlayer == Player.player1 ? "Player 1" : "Player 2"}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Text(
                  "Time Remaining: $timer seconds",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Game Board
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int x = index ~/ 4;
                      int y = index % 4;
                      final cell = gameBoard.board[x][y];

                      return GestureDetector(
                        onTap: () {
                          if (!gameNotifier.gameWon && !gameNotifier.isDraw) {
                            bool successfulMove = gameNotifier.placeMarble(x, y);
                            if (successfulMove) {
                              startTimer();
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            gradient: cell == Player.player1
                                ? LinearGradient(colors: [Colors.blue[300]!, Colors.blue[700]!])
                                : cell == Player.player2
                                ? LinearGradient(colors: [Colors.red[300]!, Colors.red[700]!])
                                : LinearGradient(colors: [Colors.grey[100]!, Colors.grey[300]!]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: cell != null
                                ? const Icon(Icons.circle, color: Colors.white, size: 40)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Reset Button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  gameNotifier.resetGame();
                  resetTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 5,
                ),
                child: const Text(
                  "Reset Game",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Game History
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Game History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: gameNotifier.history.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text("Moves : ${gameNotifier.history[index]}",
                                  style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
