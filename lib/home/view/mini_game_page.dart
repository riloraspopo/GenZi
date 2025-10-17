import 'package:flutter/material.dart';
import 'dart:math';

class MiniGamePage extends StatefulWidget {
  const MiniGamePage({super.key});

  @override
  State<MiniGamePage> createState() => _MiniGamePageState();
}

class _MiniGamePageState extends State<MiniGamePage> {
  int _targetNumber = 0;
  int _attempts = 0;
  int _maxAttempts = 7;
  String _message = '';
  bool _gameWon = false;
  bool _gameLost = false;
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
      _attempts = 0;
      _message = 'Tebak angka antara 1 sampai 100!';
      _gameWon = false;
      _gameLost = false;
    });
    _guessController.clear();
  }

  void _makeGuess() {
    if (_guessController.text.isEmpty) return;

    final guess = int.tryParse(_guessController.text);
    if (guess == null || guess < 1 || guess > 100) {
      setState(() {
        _message = 'Masukkan angka yang valid antara 1 sampai 100';
      });
      _guessController.clear();
      _focusNode.requestFocus(); // Keep focus after clearing
      return;
    }

    setState(() {
      _attempts++;

      if (guess == _targetNumber) {
        _gameWon = true;
        _message = 'Selamat! Kamu menang dalam $_attempts percobaan!';
      } else if (_attempts >= _maxAttempts) {
        _gameLost = true;
        _message = 'Permainan Berakhir! Angkanya adalah $_targetNumber';
      } else {
        if (guess < _targetNumber) {
          _message =
              'Terlalu kecil! Coba angka yang lebih besar. (${_maxAttempts - _attempts} percobaan tersisa)';
        } else {
          _message =
              'Terlalu besar! Coba angka yang lebih kecil. (${_maxAttempts - _attempts} percobaan tersisa)';
        }
      }
    });

    // Only clear and refocus if game is still ongoing
    if (!_gameWon && !_gameLost) {
      _guessController.clear();
      _focusNode.requestFocus(); // Keep keyboard open
    } else {
      _focusNode.unfocus(); // Close keyboard when game ends
    }
  }

  @override
  void dispose() {
    _guessController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Permainan Tebak Angka',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add some top spacing
                  const SizedBox(height: 40),
                  // Game Title
                  Icon(Icons.casino, size: 80, color: Colors.blue.shade700),
                  const SizedBox(height: 20),

                  // Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _gameWon
                            ? Colors.green.shade700
                            : _gameLost
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Attempts counter
                  if (!_gameWon && !_gameLost)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Percobaan $_attempts/$_maxAttempts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Input field and guess button
                  if (!_gameWon && !_gameLost) ...[
                    Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _guessController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Masukkan tebakanmu',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          onSubmitted: (_) => _makeGuess(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: _makeGuess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Tebak!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // New game button
                  if (_gameWon || _gameLost) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _startNewGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Main Lagi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Game rules
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Cara Bermain:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Tebak angka antara 1 sampai 100\n'
                          '• Kamu punya 7 kesempatan untuk menemukannya\n'
                          '• Gunakan petunjuk untuk memandu tebakanmu\n'
                          '• Selamat bermain!',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
