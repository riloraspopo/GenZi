import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasError = false;
  late final WebViewController _webViewController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  int _viewerMode = 0; // 0: Syncfusion, 1: WebView
  bool _webViewEnabled = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Error loading PDF: ${error.description}';
            });
          },
        ),
      );

    _webViewController = controller;
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasError = false;
    });

    try {
      if (_viewerMode == 1) {
        // Load PDF in WebView
        await _webViewController.loadRequest(Uri.parse(widget.pdfUrl));
        setState(() {
          _webViewEnabled = true;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading PDF: $e');
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  void _toggleViewer() {
    setState(() {
      _viewerMode = (_viewerMode + 1) % 2;
      _loadPdf();
    });
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(widget.pdfUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_viewerMode == 0 ? Icons.picture_as_pdf : Icons.web),
            onPressed: _toggleViewer,
            tooltip: 'Switch viewer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdf,
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _launchURL,
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'An error occurred',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Browser'),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewerMode == 0) {
      // Use Syncfusion PDF viewer
      return Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            key: _pdfViewerKey,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Failed to load PDF: ${details.description}';
              });
            },
            canShowPaginationDialog: false,
            enableDoubleTapZooming: true,
            interactionMode: PdfInteractionMode.pan,
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
    } else {
      // Use WebView
      if (!_webViewEnabled) {
        _loadPdf();
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
    }
  }
}