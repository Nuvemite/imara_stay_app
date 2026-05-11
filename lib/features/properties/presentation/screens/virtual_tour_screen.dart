import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:imara_stay/core/theme/app_theme.dart';

/// Virtual Tour Screen
/// Displays 360° images or virtual tour content
class VirtualTourScreen extends StatefulWidget {
  final List<String>? tourUrls;

  const VirtualTourScreen({
    super.key,
    this.tourUrls,
  });

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.tourUrls ?? [];

    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Virtual Tour'),
          backgroundColor: Colors.black,
          foregroundColor: AppTheme.white,
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Virtual tour not available',
            style: TextStyle(color: AppTheme.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Virtual Tour (${_currentIndex + 1}/${images.length})',
          style: const TextStyle(color: AppTheme.white),
        ),
      ),
      body: Stack(
        children: [
          // 360° Image Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded /
                        event.expectedTotalBytes!,
                color: AppTheme.primaryRed,
              ),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),

          // Instructions overlay
          if (images.length == 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: AppTheme.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pan and zoom to explore',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
