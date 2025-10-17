import 'package:flutter/material.dart';
import 'package:myapp/home/view/mini_game_page.dart';
import 'package:myapp/home/view/nutrition_quiz_game.dart';
import 'package:myapp/home/view/food_sorting_game.dart';

class MiniGameMenuPage extends StatelessWidget {
  const MiniGameMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Mini Game',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    '🎮 Mini Games 🎮',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Pilih permainan edukatif yang ingin kamu mainkan!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Game 1: Number Guessing
                  _buildGameCard(
                    context: context,
                    title: 'Tebak Angka',
                    description:
                        'Asah kemampuan logika dengan menebak angka yang tepat!',
                    icon: '🎯',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MiniGamePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Game 2: Nutrition Quiz
                  _buildGameCard(
                    context: context,
                    title: 'Kuis Makanan Bergizi',
                    description:
                        'Belajar tentang nutrisi dan makanan sehat dengan kuis interaktif!',
                    icon: '🥗',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionQuizGame(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Game 3: Food Sorting
                  _buildGameCard(
                    context: context,
                    title: 'Pilah Makanan Sehat',
                    description:
                        'Seret dan letakkan makanan ke kategori yang tepat!',
                    icon: '🍎',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodSortingGame(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Footer info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          '🌟 Manfaat Bermain Game Edukatif:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Meningkatkan kemampuan berpikir\n'
                          '• Belajar sambil bermain\n'
                          '• Mengembangkan logika dan kreativitas\n'
                          '• Menambah pengetahuan dengan cara menyenangkan',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 40)),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Play button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Main Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
