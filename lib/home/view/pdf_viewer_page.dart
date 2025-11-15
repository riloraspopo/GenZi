import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PdfViewer.uri(Uri.parse(widget.pdfUrl)),
    );
  }
}
