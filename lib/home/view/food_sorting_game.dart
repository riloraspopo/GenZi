import 'package:flutter/material.dart';

class FoodSortingGame extends StatefulWidget {
  const FoodSortingGame({super.key});

  @override
  State<FoodSortingGame> createState() => _FoodSortingGameState();
}

class _FoodSortingGameState extends State<FoodSortingGame> {
  int _score = 0;
  int _totalItems = 0;
  bool _gameCompleted = false;
  String _currentFeedback = '';
  Color _feedbackColor = Colors.green;

  final List<Map<String, dynamic>> _allFoods = [
    {'name': 'Apel', 'emoji': '🍎', 'isHealthy': true, 'reason': 'Kaya vitamin C dan serat yang baik untuk pencernaan'},
    {'name': 'Pisang', 'emoji': '🍌', 'isHealthy': true, 'reason': 'Mengandung kalium untuk kesehatan jantung'},
    {'name': 'Wortel', 'emoji': '🥕', 'isHealthy': true, 'reason': 'Mengandung beta karoten untuk kesehatan mata'},
    {'name': 'Bayam', 'emoji': '🥬', 'isHealthy': true, 'reason': 'Tinggi zat besi dan vitamin K'},
    {'name': 'Ikan', 'emoji': '🐟', 'isHealthy': true, 'reason': 'Sumber protein dan omega-3 yang baik'},
    {'name': 'Susu', 'emoji': '🥛', 'isHealthy': true, 'reason': 'Mengandung kalsium untuk tulang kuat'},
    
    {'name': 'Permen', 'emoji': '🍭', 'isHealthy': false, 'reason': 'Tinggi gula yang dapat merusak gigi'},
    {'name': 'Hamburger', 'emoji': '🍔', 'isHealthy': false, 'reason': 'Tinggi lemak jenuh dan kalori'},
    {'name': 'Donat', 'emoji': '🍩', 'isHealthy': false, 'reason': 'Mengandung gula dan lemak trans yang berlebihan'},
    {'name': 'Pizza', 'emoji': '🍕', 'isHealthy': false, 'reason': 'Tinggi sodium dan lemak jenuh'},
    {'name': 'Es Krim', 'emoji': '🍦', 'isHealthy': false, 'reason': 'Tinggi gula dan lemak jenuh'},
    {'name': 'Keripik', 'emoji': '🍟', 'isHealthy': false, 'reason': 'Digoreng dengan minyak berlebihan dan tinggi garam'},
  ];

  List<Map<String, dynamic>> _availableFoods = [];
  List<Map<String, dynamic>> _healthyFoods = [];
  List<Map<String, dynamic>> _unhealthyFoods = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _availableFoods = List.from(_allFoods)..shuffle();
    _healthyFoods.clear();
    _unhealthyFoods.clear();
    _score = 0;
    _totalItems = 0;
    _gameCompleted = false;
    _currentFeedback = '';
    setState(() {});
  }

  void _dropFood(bool targetIsHealthy, Map<String, dynamic> food) {
    bool isCorrect = food['isHealthy'] == targetIsHealthy;
    
    setState(() {
      _totalItems++;
      
      if (isCorrect) {
        _score++;
        _currentFeedback = 'Benar! ${food['reason']}';
        _feedbackColor = Colors.green;
        
        if (targetIsHealthy) {
          _healthyFoods.add(food);
        } else {
          _unhealthyFoods.add(food);
        }
      } else {
        _currentFeedback = 'Salah! ${food['name']} ${food['isHealthy'] ? 'adalah makanan sehat' : 'bukan makanan sehat'}. ${food['reason']}.';
        _feedbackColor = Colors.red;
        
        // Put in correct category anyway for educational purpose
        if (food['isHealthy']) {
          _healthyFoods.add(food);
        } else {
          _unhealthyFoods.add(food);
        }
      }
      
      _availableFoods.remove(food);
      
      if (_availableFoods.isEmpty) {
        _gameCompleted = true;
      }
    });

    // Clear feedback after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentFeedback = '';
        });
      }
    });
  }

  String _getCompletionMessage() {
    double percentage = (_score / _totalItems) * 100;
    if (percentage == 100) {
      return 'Sempurna! Kamu benar-benar ahli makanan sehat! 🏆';
    } else if (percentage >= 80) {
      return 'Bagus sekali! Kamu sudah cukup paham tentang makanan sehat! 🌟';
    } else if (percentage >= 60) {
      return 'Lumayan! Terus belajar tentang makanan sehat ya! 🎯';
    } else {
      return 'Jangan menyerah! Mari belajar lebih banyak tentang makanan sehat! 💪';
    }
  }

  Color _getCompletionColor() {
    double percentage = (_score / _totalItems) * 100;
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilah Makanan Sehat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: _gameCompleted ? _buildCompletionScreen() : _buildGameScreen(),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Score and progress
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Skor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$_score / $_totalItems',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Tersisa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${_availableFoods.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feedback area
          if (_currentFeedback.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _feedbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _feedbackColor, width: 1),
              ),
              child: Text(
                _currentFeedback,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _feedbackColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 20),

          // Drop zones
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Healthy foods zone
                Expanded(
                  child: DragTarget<Map<String, dynamic>>(
                    onAccept: (food) => _dropFood(true, food),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty 
                              ? Colors.green.shade100 
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green,
                            width: candidateData.isNotEmpty ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                '🥗 Makanan Sehat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: _healthyFoods.map((food) {
                                    return Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            food['emoji'],
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            food['name'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Unhealthy foods zone
                Expanded(
                  child: DragTarget<Map<String, dynamic>>(
                    onAccept: (food) => _dropFood(false, food),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty 
                              ? Colors.red.shade100 
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red,
                            width: candidateData.isNotEmpty ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                '🍔 Makanan Tidak Sehat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: _unhealthyFoods.map((food) {
                                    return Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            food['emoji'],
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            food['name'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Available foods to drag
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
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
            child: Column(
              children: [
                const Text(
                  'Seret makanan ke kategori yang tepat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableFoods.map((food) {
                        return Draggable<Map<String, dynamic>>(
                          data: food,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    food['emoji'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    food['name'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  food['emoji'],
                                  style: TextStyle(fontSize: 24, color: Colors.grey.shade400),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  food['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  food['emoji'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  food['name'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Result emoji
            Text(
              _score == _totalItems ? '🏆' : _score >= (_totalItems * 0.8) ? '🌟' : '🎯',
              style: const TextStyle(fontSize: 100),
            ),

            const SizedBox(height: 20),

            // Score display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Skor Anda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / $_totalItems',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getCompletionColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((_score / _totalItems) * 100).round()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCompletionColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getCompletionColor(), width: 1),
              ),
              child: Text(
                _getCompletionMessage(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getCompletionColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // Play again button
            ElevatedButton(
              onPressed: _initializeGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Main Lagi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 40),

            // Educational tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Text(
                    'Tips Memilih Makanan Sehat:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🥬 Pilih sayuran dan buah-buahan segar\n'
                    '🍗 Protein tanpa lemak seperti ikan dan ayam\n'
                    '🍞 Karbohidrat kompleks seperti nasi merah\n'
                    '💧 Hindari makanan tinggi gula dan garam\n'
                    '🥛 Konsumsi susu dan produk susu rendah lemak',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}