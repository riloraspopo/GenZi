import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:myapp/home/view/chat_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:myapp/home/data/data_provider.dart';
import 'package:myapp/home/models/educational_content.dart';
import 'package:myapp/home/view/full_screen_image_viewer.dart';
import 'package:myapp/home/view/pdf_viewer_page.dart';
import 'package:myapp/home/view/mini_game_menu_page.dart';
import 'package:myapp/home/view/video_list_page.dart';
import 'package:myapp/home/view/bmi_calculator_page.dart';
import 'package:myapp/home/view/teacher_login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Future<List<EducationalPoster>>? _postersFuture;
  Future<List<PdfResource>>? _pdfResourcesFuture;
  Future<int>? _videoCountFuture;
  final ScrollController _postersScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  double _scrollPercent = 0.0;
  bool _showTitle = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Key _postersListKey = UniqueKey();

  late AnimationController _greetingAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _greetingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _greetingAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _greetingSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _greetingAnimationController,
            curve: Curves.easeOutQuart,
          ),
        );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _greetingAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });

    // Ensure system UI is visible
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    _postersScrollController.addListener(_updateScrollPercent);
    _mainScrollController.addListener(_updateTitleVisibility);

    // Initialize data loading
    _postersFuture = DataProvider.getPosters();
    _pdfResourcesFuture = DataProvider.getPdfResources();
    _videoCountFuture = DataProvider.getVideoCount();

    _refreshData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi! ☀️';
    } else if (hour < 17) {
      return 'Selamat Siang! 🌤️';
    } else {
      return 'Selamat Sore! 🌅';
    }
  }

  Future<void> _refreshData() async {
    try {
      // Reset scroll position
      if (_postersScrollController.hasClients) {
        _postersScrollController.jumpTo(0);
      }
      setState(() {
        _scrollPercent = 0.0;
        setState(() {}); // Trigger rebuild for AppBar title visibility
      });

      // Clear all caches
      imageCache.clear();
      imageCache.clearLiveImages();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Force widget rebuild by setting futures to null and updating list key
      setState(() {
        _postersFuture = null;
        _pdfResourcesFuture = null;
        _videoCountFuture = null;
        _postersListKey = UniqueKey();
      });

      // Small delay to ensure cache is cleared
      await Future.delayed(const Duration(milliseconds: 300));

      // Clear CachedNetworkImage cache

      // Now fetch new data
      final posters = DataProvider.getPosters();
      final pdfs = DataProvider.getPdfResources();
      final videoCount = DataProvider.getVideoCount();

      if (!mounted) return;

      setState(() {
        _postersFuture = posters;
        _pdfResourcesFuture = pdfs;
        _videoCountFuture = videoCount;
      });

      await Future.wait([posters, pdfs, videoCount]);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kesalahan memuat ulang data: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ),
      );
    }
  }

  void _updateScrollPercent() {
    if (_postersScrollController.hasClients &&
        _postersScrollController.position.maxScrollExtent > 0) {
      setState(() {
        _scrollPercent =
            _postersScrollController.offset /
            _postersScrollController.position.maxScrollExtent;
      });
    }
  }

  void _updateTitleVisibility() {
    if (_mainScrollController.hasClients) {
      setState(() {
        _showTitle = _mainScrollController.offset > 100;
      });
    }
  }

  @override
  void dispose() {
    _postersScrollController.dispose();
    _mainScrollController.removeListener(_updateTitleVisibility);
    _mainScrollController.dispose();
    _greetingAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [startColor, endColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: startColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(icon, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _cardScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterItem({
    required BuildContext context,
    required EducationalPoster poster,
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(left: isFirst ? 0 : 16, right: isLast ? 0 : 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImageViewer(
                imageUrl: poster.imageUrl,
                title: poster.title,
              ),
            ),
          );
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: poster.imageUrl,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      width: double.infinity,
                      poster.imageUrl,
                      fit: BoxFit.cover,
                      headers: const {'X-Requested-With': 'XMLHttpRequest'},
                      loadingBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            );
                          },
                      errorBuilder: (context, error, stackTrace) {
                        if (kDebugMode) {
                          print('Error loading image: ${poster.imageUrl}');
                          print('Error details: $error');
                        }
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kesalahan Gambar',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  poster.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        floatingActionButton: AnimatedBuilder(
          animation: _cardScaleAnimation,
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Transform.scale(
              scale: _cardScaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha((0.4 * 255).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                  label: Text(
                    'Chat dengan AI',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          color: Colors.deepPurple,
          child: CustomScrollView(
            controller: _mainScrollController,
            slivers: [
              // Custom App Bar with greeting
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.school_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeacherLoginPage(),
                        ),
                      );
                    },
                    tooltip: 'Login Guru',
                  ),
                ],
                title: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _showTitle ? 1.0 : 0.0,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icongenzi.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Gen Zi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple,
                          Colors.deepPurple.shade700,
                          Colors.purple.shade600,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          right: -100,
                          top: -50,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -50,
                          bottom: -100,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                          ),
                        ),
                        // Content
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 40,
                          top: 60,
                          child: FadeTransition(
                            opacity: _greetingFadeAnimation,
                            child: SlideTransition(
                              position: _greetingSlideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/icongenzi.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getGreeting(),
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Mari belajar bersama hari ini!',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            FutureBuilder<
                                              List<EducationalPoster>
                                            >(
                                              future: _postersFuture,
                                              builder: (context, snapshot) {
                                                return _buildStatsCard(
                                                  title: 'Poster\nTersedia',
                                                  value:
                                                      '${snapshot.data?.length ?? 0}',
                                                  icon: Icons.image_rounded,
                                                  color: Colors.orange,
                                                  onTap: () {
                                                    // Scroll to posters section
                                                    _mainScrollController
                                                        .animateTo(
                                                          650,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    800,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                  },
                                                );
                                              },
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FutureBuilder<List<PdfResource>>(
                                          future: _pdfResourcesFuture,
                                          builder: (context, snapshot) {
                                            return _buildStatsCard(
                                              title: 'Dokumen\nPDF',
                                              value:
                                                  '${snapshot.data?.length ?? 0}',
                                              icon: Icons.description_rounded,
                                              color: Colors.red,
                                              onTap: () {
                                                // Scroll to PDF section
                                                _mainScrollController.animateTo(
                                                  1050,
                                                  duration: const Duration(
                                                    milliseconds: 800,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FutureBuilder<int>(
                                          future: _videoCountFuture,
                                          builder: (context, snapshot) {
                                            if (kDebugMode) {
                                              print(
                                                'Video count snapshot: ${snapshot.connectionState}, data: ${snapshot.data}, error: ${snapshot.error}',
                                              );
                                            }
                                            return _buildStatsCard(
                                              title: 'Video\nBelajar',
                                              value: '${snapshot.data ?? 0}',
                                              icon: Icons.play_circle_rounded,
                                              color: Colors.blue,
                                              onTap: () {
                                                // Navigate to video list page
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const VideoListPage(
                                                          bucketId: DataProvider
                                                              .mediaBucketId,
                                                        ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatsCard(
                                          title: 'Mini\nGames',
                                          value: '3',
                                          icon: Icons.games_rounded,
                                          color: Colors.green,
                                          onTap: () {
                                            // Navigate to mini game menu page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const MiniGameMenuPage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        title: 'Mini Games',
                        subtitle: 'Belajar sambil bermain',
                        icon: Icons.sports_esports_rounded,
                        startColor: Colors.green.shade400,
                        endColor: Colors.green.shade600,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MiniGameMenuPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        title: 'Video Pembelajaran',
                        subtitle: 'Tonton video edukasi menarik',
                        icon: Icons.play_circle_fill_rounded,
                        startColor: Colors.purple.shade400,
                        endColor: Colors.purple.shade600,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoListPage(
                                bucketId: DataProvider.mediaBucketId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        title: 'Kalkulator BMI',
                        subtitle: 'Cek status berat badan idealmu',
                        icon: Icons.health_and_safety_rounded,
                        startColor: Colors.green.shade400,
                        endColor: Colors.green.shade600,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BMICalculatorPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Posters Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Poster Edukasi',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //   },
                          //   child: Text(
                          //     'Lihat Semua',
                          //     style: TextStyle(
                          //       color: Colors.deepPurple.shade600,
                          //       fontWeight: FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<EducationalPoster>>(
                        future: _postersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 320,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 240,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Container(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Kesalahan memuat poster',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final posters = snapshot.data ?? [];

                          if (posters.isEmpty) {
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada poster tersedia',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Progress indicator
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _scrollPercent.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Poster list
                              SizedBox(
                                height: 320,
                                child: ListView.builder(
                                  key: _postersListKey,
                                  controller: _postersScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: posters.length,
                                  itemBuilder: (context, index) {
                                    final poster = posters[index];
                                    if (index < posters.length - 1) {
                                      precacheImage(
                                        NetworkImage(
                                          posters[index + 1].imageUrl,
                                          headers: const {
                                            'X-Requested-With':
                                                'XMLHttpRequest',
                                          },
                                        ),
                                        context,
                                      );
                                    }
                                    return _buildPosterItem(
                                      context: context,
                                      poster: poster,
                                      isFirst: index == 0,
                                      isLast: index == posters.length - 1,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // PDF Resources Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dokumen PDF',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<PdfResource>>(
                        future: _pdfResourcesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Container(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              height: 160,
                              alignment: Alignment.center,
                              child: Text('Kesalahan: ${snapshot.error}'),
                            );
                          }

                          final pdfResources = snapshot.data ?? [];

                          return SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: pdfResources.length,
                              itemBuilder: (context, index) {
                                final pdf = pdfResources[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: 120,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PdfViewerPage(
                                              pdfUrl: pdf.pdfUrl,
                                              title: pdf.title,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          16,
                                                        ),
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons
                                                        .picture_as_pdf_rounded,
                                                    size: 40,
                                                    color: Colors.red.shade400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Text(
                                                pdf.title,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Study Tips Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips Belajar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: DataProvider.getInformationItems().length,
                        itemBuilder: (context, index) {
                          final info =
                              DataProvider.getInformationItems()[index];
                          return AnimatedBuilder(
                            animation: _cardScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _cardScaleAnimation.value,
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.lightbulb_rounded,
                                                color:
                                                    Colors.deepPurple.shade600,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                info.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          info.content,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
