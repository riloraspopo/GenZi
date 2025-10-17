import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:myapp/home/data/data_provider.dart';
import 'package:myapp/home/models/educational_content.dart';
import 'package:myapp/home/view/full_screen_image_viewer.dart';
import 'package:myapp/home/view/pdf_viewer_page.dart';
import 'package:myapp/home/view/mini_game_menu_page.dart';
import 'package:myapp/home/view/video_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<EducationalPoster>>? _postersFuture;
  Future<List<PdfResource>>? _pdfResourcesFuture;
  final ScrollController _postersScrollController = ScrollController();
  double _scrollPercent = 0.0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Key _postersListKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Ensure system UI is visible
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    _postersScrollController.addListener(_updateScrollPercent);
    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      // Reset scroll position
      if (_postersScrollController.hasClients) {
        _postersScrollController.jumpTo(0);
      }
      setState(() {
        _scrollPercent = 0.0;
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
        _postersListKey = UniqueKey();
      });

      // Small delay to ensure cache is cleared
      await Future.delayed(const Duration(milliseconds: 300));

      // Clear CachedNetworkImage cache
      await CachedNetworkImage.evictFromCache('');

      // Now fetch new data
      final posters = DataProvider.getPosters();
      final pdfs = DataProvider.getPdfResources();

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _postersFuture = posters;
        _pdfResourcesFuture = pdfs;
      });

      // Wait for futures to complete to handle any errors
      await Future.wait([posters, pdfs]);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
      if (!mounted) return;

      // Show error snackbar
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

  @override
  void dispose() {
    _postersScrollController.dispose();
    super.dispose();
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
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: poster.imageUrl,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: poster.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      httpHeaders: const {'X-Requested-With': 'XMLHttpRequest'},
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) {
                        if (kDebugMode) {
                          print('Error loading image: $url');
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
                padding: const EdgeInsets.all(12.0),
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
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.blue.shade700, // Match with AppBar
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // Dark status bar (for iOS)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sumber Daya Edukasi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Banner
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha((0.1 * 255).round()),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Selamat datang di',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hub Pembelajaran',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Jelajahi • Belajar • Berkembang',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MiniGameMenuPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.casino,
                                color: Colors.blue,
                              ),
                              label: const Text(
                                'Main Mini Game',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Posters Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Poster Edukasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<EducationalPoster>>(
                        future: _postersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Kesalahan: ${snapshot.error}'),
                            );
                          }

                          final posters = snapshot.data ?? [];

                          return Column(
                            children: [
                              // Scroll indicator
                              Container(
                                height: 4,
                                width: MediaQuery.of(context).size.width - 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _scrollPercent.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Horizontal poster list
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
                                    // Precache next image if available
                                    if (index < posters.length - 1) {
                                      precacheImage(
                                        CachedNetworkImageProvider(
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

                // PDF Resources Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sumber Daya PDF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<PdfResource>>(
                        future: _pdfResourcesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
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
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                  ),
                                  child: SizedBox(
                                    width: 120,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PdfViewerPage(
                                                  pdfUrl: pdf.pdfUrl,
                                                  title: pdf.title,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color:
                                                    Colors.red.shade100,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 40,
                                                    color: Colors
                                                        .red
                                                        .shade400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                              child: Text(
                                                pdf.title,
                                                textAlign:
                                                    TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
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

                // Video Learning Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Video Pembelajaran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VideoListPage(
                                    bucketId: DataProvider.mediaBucketId,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
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
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            height: 120,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.purple.shade600,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Video Pembelajaran',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tonton video edukasi interaktif',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withAlpha(204),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withAlpha(204),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Information Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            DataProvider.getInformationItems().length,
                        itemBuilder: (context, index) {
                          final info =
                              DataProvider.getInformationItems()[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    info.content,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
