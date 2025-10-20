import 'package:flutter/material.dart';

class NutritionQuizGame extends StatefulWidget {
  const NutritionQuizGame({super.key});

  @override
  State<NutritionQuizGame> createState() => _NutritionQuizGameState();
}

class _NutritionQuizGameState extends State<NutritionQuizGame> {
  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    // Randomly select 8 questions
    List<Map<String, dynamic>> shuffledQuestions = List.from(_allQuestions)..shuffle();
    _questions = shuffledQuestions.take(8).toList();
  }
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  bool _gameCompleted = false;
  String _selectedAnswer = '';

  late List<Map<String, dynamic>> _questions = [];
  
  final List<Map<String, dynamic>> _allQuestions = [
    {
      'question': 'Makanan mana yang kaya akan protein?',
      'options': ['Nasi Putih', 'Telur', 'Gula', 'Keripik'],
      'correct': 'Telur',
      'explanation':
          'Telur mengandung protein lengkap yang baik untuk pertumbuhan dan perbaikan sel tubuh.',
      'emoji': '🥚',
    },
    {
      'question': 'Vitamin apa yang bisa didapat dari sinar matahari?',
      'options': ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'],
      'correct': 'Vitamin D',
      'explanation':
          'Vitamin D diproduksi oleh tubuh ketika kulit terpapar sinar matahari pagi.',
      'emoji': '☀️',
    },
    {
      'question': 'Buah mana yang mengandung vitamin C tinggi?',
      'options': ['Pisang', 'Jeruk', 'Apel', 'Anggur'],
      'correct': 'Jeruk',
      'explanation':
          'Jeruk kaya akan vitamin C yang membantu meningkatkan daya tahan tubuh.',
      'emoji': '🍊',
    },
    {
      'question': 'Sayuran hijau baik untuk tubuh karena mengandung?',
      'options': ['Gula', 'Zat Besi', 'Lemak Trans', 'Pengawet'],
      'correct': 'Zat Besi',
      'explanation':
          'Sayuran hijau seperti bayam mengandung zat besi yang mencegah anemia.',
      'emoji': '🥬',
    },
    {
      'question': 'Berapa gelas air yang disarankan diminum per hari?',
      'options': ['2-3 gelas', '4-5 gelas', '8 gelas', '12 gelas'],
      'correct': '8 gelas',
      'explanation':
          'Tubuh memerlukan sekitar 8 gelas air per hari untuk menjaga hidrasi yang optimal.',
      'emoji': '💧',
    },
    {
      'question': 'Makanan mana yang sebaiknya dihindari?',
      'options': ['Ikan', 'Sayuran', 'Makanan Cepat Saji', 'Buah-buahan'],
      'correct': 'Makanan Cepat Saji',
      'explanation':
          'Makanan cepat saji tinggi lemak jenuh, garam, dan kalori yang tidak baik untuk kesehatan.',
      'emoji': '🍟',
    },
    {
      'question': 'Karbohidrat sehat bisa didapat dari?',
      'options': ['Nasi Merah', 'Permen', 'Soda', 'Kue Manis'],
      'correct': 'Nasi Merah',
      'explanation':
          'Nasi merah mengandung serat dan nutrisi lebih banyak dibanding nasi putih.',
      'emoji': '🍙',
    },
     {
      'question': 'Buah mana yang baik untuk kesehatan mata?',
      'options': ['Wortel', 'Durian', 'Mangga', 'Semua benar'],
      'correct': 'Semua benar',
      'explanation':
          'Wortel, durian, dan mangga mengandung beta karoten yang baik untuk mata.',
      'emoji': '👁️',
    },
    {
      'question': 'Sumber protein nabati dapat ditemukan pada?',
      'options': ['Tempe', 'Ayam', 'Ikan', 'Telur'],
      'correct': 'Tempe',
      'explanation':
          'Tempe adalah sumber protein nabati yang baik dan kaya akan nutrisi.',
      'emoji': '🫘',
    },
    {
      'question': 'Makanan fermentasi yang baik untuk pencernaan adalah?',
      'options': ['Yogurt', 'Es Krim', 'Permen', 'Keripik'],
      'correct': 'Yogurt',
      'explanation':
          'Yogurt mengandung probiotik yang baik untuk kesehatan pencernaan.',
      'emoji': '🥛',
    },
    {
      'question': 'Mineral apa yang penting untuk kesehatan tulang?',
      'options': ['Kalsium', 'Sodium', 'Gula', 'Lemak'],
      'correct': 'Kalsium',
      'explanation':
          'Kalsium sangat penting untuk pertumbuhan dan kesehatan tulang.',
      'emoji': '🦴',
    },
    {
      'question': 'Buah yang tinggi serat adalah?',
      'options': ['Apel', 'Permen', 'Roti Putih', 'Keripik'],
      'correct': 'Apel',
      'explanation':
          'Apel kaya akan serat yang baik untuk pencernaan dan kesehatan jantung.',
      'emoji': '🍎',
    },
    {
      'question': 'Manakah yang termasuk sayuran hijau?',
      'options': ['Bayam', 'Wortel', 'Tomat', 'Kentang'],
      'correct': 'Bayam',
      'explanation':
          'Bayam adalah sayuran hijau yang kaya akan zat besi dan nutrisi penting.',
      'emoji': '🥬',
    },
    {
      'question': 'Apa manfaat makan ikan?',
      'options': ['Omega 3', 'Gula Tinggi', 'Lemak Trans', 'Kolesterol'],
      'correct': 'Omega 3',
      'explanation':
          'Ikan kaya akan Omega 3 yang baik untuk kesehatan otak dan jantung.',
      'emoji': '🐟',
    },
    {
      'question': 'Kapan waktu terbaik untuk sarapan?',
      'options': ['Pagi Hari', 'Siang Hari', 'Malam Hari', 'Tidak Perlu'],
      'correct': 'Pagi Hari',
      'explanation':
          'Sarapan di pagi hari penting untuk energi dan konsentrasi sepanjang hari.',
      'emoji': '🌅',
    },
    {
      'question': 'Minuman apa yang sebaiknya dibatasi?',
      'options': ['Air Putih', 'Teh Tawar', 'Soda', 'Jus Buah'],
      'correct': 'Soda',
      'explanation':
          'Soda mengandung gula tinggi dan tidak memiliki nilai gizi yang baik.',
      'emoji': '🥤',
    },
    {
      'question': 'Berapa kali minimal makan buah dalam sehari?',
      'options': ['1 kali', '2 kali', '3 kali', 'Tidak Perlu'],
      'correct': '2 kali',
      'explanation':
          'Minimal 2 kali sehari makan buah untuk memenuhi kebutuhan vitamin dan mineral.',
      'emoji': '🍎',
    },
    {
      'question': 'Makanan yang baik untuk otak adalah?',
      'options': ['Ikan', 'Permen', 'Soda', 'Keripik'],
      'correct': 'Ikan',
      'explanation':
          'Ikan mengandung omega 3 yang sangat baik untuk perkembangan otak.',
      'emoji': '🧠',
    },
    {
      'question': 'Sumber vitamin C terbaik adalah?',
      'options': ['Jeruk', 'Roti', 'Keju', 'Daging'],
      'correct': 'Jeruk',
      'explanation':
          'Jeruk kaya akan vitamin C yang penting untuk sistem kekebalan tubuh.',
      'emoji': '🍊',
    }
  ];

  void _selectAnswer(String answer) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      _isCorrect = answer == _questions[_currentQuestionIndex]['correct'];
      if (_isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _isCorrect = false;
        _selectedAnswer = '';
      });
    } else {
      setState(() {
        _gameCompleted = true;
      });
    }
  }

  void _restartGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _isCorrect = false;
      _gameCompleted = false;
      _selectedAnswer = '';
      _initializeQuestions(); // Select new random questions
    });
  }

  String _getScoreMessage() {
    double percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) {
      return 'Luar Biasa! 🌟\nKamu ahli nutrisi!';
    } else if (percentage >= 60) {
      return 'Bagus! 👍\nTerus belajar tentang gizi!';
    } else {
      return 'Coba Lagi! 💪\nBelajar lebih banyak tentang makanan bergizi!';
    }
  }

  Color _getScoreColor() {
    double percentage = (_score / _questions.length) * 100;
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
          'Kuis Makanan Bergizi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _gameCompleted ? _buildResultScreen() : _buildQuizScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        // Progress indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Soal ${_currentQuestionIndex + 1} dari ${_questions.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Skor: $_score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Question emoji
        Text(question['emoji'], style: const TextStyle(fontSize: 80)),

        const SizedBox(height: 20),

        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            question['question'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 30),

        // Answer options
        ...List.generate(question['options'].length, (index) {
          final option = question['options'][index];
          final isSelected = _selectedAnswer == option;
          final isCorrect = option == question['correct'];

          Color buttonColor = Colors.white;
          Color textColor = Colors.black87;
          Color borderColor = Colors.grey.shade300;

          if (_hasAnswered) {
            if (isCorrect) {
              buttonColor = Colors.green.shade100;
              textColor = Colors.green.shade800;
              borderColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              buttonColor = Colors.red.shade100;
              textColor = Colors.red.shade800;
              borderColor = Colors.red;
            }
          } else if (isSelected) {
            buttonColor = Colors.blue.shade100;
            textColor = Colors.blue.shade800;
            borderColor = Colors.blue;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _selectAnswer(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 30),

        // Explanation (shown after answer)
        if (_hasAnswered) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.info,
                  color: _isCorrect ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _isCorrect ? 'Benar!' : 'Jawaban: ${question['correct']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question['explanation'],
                  style: TextStyle(
                    fontSize: 14,
                    color: _isCorrect
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Next button
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
            child: Text(
              _currentQuestionIndex < _questions.length - 1
                  ? 'Soal Berikutnya'
                  : 'Lihat Hasil',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Result emoji
        Text(
          _score >= (_questions.length * 0.8)
              ? '🏆'
              : _score >= (_questions.length * 0.6)
              ? '🥈'
              : '🤗',
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
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Skor Akhir',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score / ${_questions.length}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${((_score / _questions.length) * 100).round()}%',
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
            color: _getScoreColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getScoreColor(), width: 1),
          ),
          child: Text(
            _getScoreMessage(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _getScoreColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Play again button
        ElevatedButton(
          onPressed: _restartGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
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
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
              Text(
                'Tips Hidup Sehat:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '🥗 Makan sayur dan buah setiap hari\n'
                '💧 Minum air putih yang cukup\n'
                '🏃 Olahraga teratur\n'
                '😴 Tidur yang cukup\n'
                '🧼 Jaga kebersihan',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
