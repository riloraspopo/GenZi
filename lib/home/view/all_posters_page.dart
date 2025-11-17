import 'package:flutter/material.dart';
import 'package:myapp/home/data/data_provider.dart';
import 'package:myapp/home/models/educational_content.dart';
import 'package:myapp/home/view/full_screen_image_viewer.dart';
import 'package:shimmer/shimmer.dart';

class AllPostersPage extends StatefulWidget {
  const AllPostersPage({super.key});

  @override
  State<AllPostersPage> createState() => _AllPostersPageState();
}

class _AllPostersPageState extends State<AllPostersPage> {
  String? _selectedTag;
  Future<List<EducationalPoster>>? _postersFuture;
  Future<List<String>>? _tagsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _postersFuture = DataProvider.getPostersFromDatabase(
        tagFilter: _selectedTag,
      );
      _tagsFuture = DataProvider.getPosterTags();
    });
  }

  void _onTagSelected(String? tag) {
    setState(() {
      _selectedTag = tag;
      _postersFuture = DataProvider.getPostersFromDatabase(
        tagFilter: _selectedTag,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Poster GenZi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tag Filter Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple, Colors.deepPurple.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<String>>(
                  future: _tagsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.white.withAlpha(
                            (255 * 0.3).toInt(),
                          ),
                          highlightColor: Colors.white.withAlpha(
                            (255 * 0.5).toInt(),
                          ),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final tags = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          // All filter chip
                          FilterChip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: const Text('Semua'),
                            selected: _selectedTag == null,
                            onSelected: (selected) {
                              if (selected) {
                                _onTagSelected(null);
                              }
                            },
                            selectedColor: Colors.white,
                            backgroundColor: _selectedTag == null
                                ? Colors.white
                                : Colors.deepPurple.shade700,
                            labelStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedTag == null
                                  ? Colors.deepPurple
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            checkmarkColor: Colors.deepPurple,
                          ),
                          // Tag filter chips
                          ...tags.map((tag) {
                            final isSelected = _selectedTag == tag;
                            return FilterChip(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _onTagSelected(tag);
                                }
                              },
                              selectedColor: Colors.white,
                              backgroundColor: isSelected
                                  ? Colors.white
                                  : Colors.deepPurple.shade700,
                              labelStyle: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              checkmarkColor: Colors.deepPurple,
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Posters Grid
          Expanded(
            child: FutureBuilder<List<EducationalPoster>>(
              future: _postersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingGrid();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kesalahan memuat poster',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final posters = snapshot.data ?? [];

                if (posters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTag == null
                              ? 'Belum ada poster tersedia'
                              : 'Tidak ada poster dengan tag "$_selectedTag"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadData();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: posters.length,
                    itemBuilder: (context, index) {
                      final poster = posters[index];
                      return _buildPosterCard(poster);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildPosterCard(EducationalPoster poster) {
    return GestureDetector(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: Stack(
                    children: [
                      Image.network(
                        poster.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
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
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 40,
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
                      // Tag badge
                      if (poster.tags.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              poster.tags.first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                poster.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
