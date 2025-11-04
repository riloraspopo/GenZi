import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _controller = TransformationController();
  late bool _isFullScreen;

  @override
  void initState() {
    super.initState();
    _isFullScreen = false;
    // Reset system UI to normal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _controller.dispose();
    // Reset system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
      body: GestureDetector(
        onDoubleTap: _toggleFullScreen,
        child: Stack(
          children: [
            // Image with InteractiveViewer
            InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionStart: (details) {
                // Optional: Enter fullscreen when starting to zoom
                if (!_isFullScreen) {
                  _toggleFullScreen();
                }
              },
              child: Center(
                child: Hero(
                  tag: widget.imageUrl,
                  child: Image.network(
                    widget.imageUrl,
                    headers: const {'X-Requested-With': 'XMLHttpRequest'},
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),

            // Fullscreen toggle button overlay
            if (_isFullScreen)
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleFullScreen,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),

            // Reset zoom button overlay
            Positioned(
              bottom: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _controller.value.getMaxScaleOnAxis() > 1.0
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.black.withAlpha((0.5 * 255).round()),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {
                      _controller.value = Matrix4.identity();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.zoom_out_map, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
