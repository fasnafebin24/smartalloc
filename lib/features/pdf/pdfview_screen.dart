import 'package:flutter/material.dart';
import 'package:smartalloc/utils/contants/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel = 
                  (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel = 
                  (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
                _isLoading = false;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load PDF: ${details.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            ),
          if (!_isLoading && _totalPages > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page $_currentPage of $_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'previous',
            mini: true,
            onPressed: _currentPage > 1
                ? () {
                    _pdfViewerController.previousPage();
                  }
                : null,
            backgroundColor: _currentPage > 1 ? AppColors.primaryColor : Colors.grey,
            child: const Icon(Icons.arrow_upward,color: AppColors.whiteColor,),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'next',
            mini: true,
            onPressed: _currentPage < _totalPages
                ? () {
                    _pdfViewerController.nextPage();
                  }
                : null,
            backgroundColor: 
                _currentPage < _totalPages ? AppColors.primaryColor : Colors.grey,
            child: const Icon(Icons.arrow_downward,color: AppColors.whiteColor,),
          ),
        ],
      ),
    );
  }
}