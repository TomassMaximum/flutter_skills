import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ShowcaseHomeTab extends StatefulWidget {
  const ShowcaseHomeTab({super.key});

  @override
  State<ShowcaseHomeTab> createState() => _ShowcaseHomeTabState();
}

class _ShowcaseHomeTabState extends State<ShowcaseHomeTab> {
  int _currentBanner = 0;
  late final List<ImageProvider?> _scaledBannerImages;

  final List<String> _bannerPaths = [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
    'assets/banner4.jpg',
  ];

  final List<Map<String, dynamic>> _blogList = [
    {
      'title': 'Understanding Flutter Widgets',
      'tags': ['Flutter', 'Widgets', 'UI'],
    },
    {
      'title': 'State Management in Flutter',
      'tags': ['Flutter', 'State', 'Management'],
    },
    {
      'title': 'Animations in Flutter',
      'tags': ['Flutter', 'Animations', 'UI'],
    },
    {
      'title': 'Networking in Flutter',
      'tags': ['Flutter', 'Networking', 'HTTP'],
    },
    {
      'title': 'Building Responsive UIs',
      'tags': ['Flutter', 'Responsive', 'Design'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _scaledBannerImages = List<ImageProvider?>.filled(
      _bannerPaths.length,
      null,
    );
    _prepareImages();
  }

  Future<void> _prepareImages() async {
    for (int i = 0; i < _bannerPaths.length; i++) {
      final path = _bannerPaths[i];
      final asset = AssetImage(path);

      final imageStream = asset.resolve(const ImageConfiguration());
      final completer = Completer<ImageInfo>();
      final listener = ImageStreamListener((info, _) {
        completer.complete(info);
      });
      imageStream.addListener(listener);
      final info = await completer.future;
      imageStream.removeListener(listener);

      final scaled = ResizeImage(
        asset,
        width: (info.image.width / 8).round(),
        height: (info.image.height / 8).round(),
      );

      await precacheImage(scaled, context);

      // 单独更新这一张图片
      if (mounted) {
        setState(() {
          _scaledBannerImages[i] = scaled;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 56),
              _scaledBannerImages.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildBanner(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = _blogList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    item['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: List.generate(item['tags'].length, (tagIndex) {
                        final tag = item['tags'][tagIndex];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            );
          }, childCount: _blogList.length),
        ),
      ],
    );
  }

  Widget _buildBanner(ThemeData theme) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: screenWidth * 11 / 16 + 28,
          width: double.infinity,
          child: CarouselSlider(
            items: List.generate(_scaledBannerImages.length, (i) {
              final image = _scaledBannerImages[i];
              return AspectRatio(
                aspectRatio: 16 / 11,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            left: 12,
                            right: 12,
                          ),
                          child: image == null
                              ? const Center(child: CircularProgressIndicator())
                              : Image(
                                  image: image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: AlignmentGeometry.centerRight,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(right: 12),
                            child: Text(
                              '2025-10-08 12:00',
                              style: TextStyle(
                                fontFamily: 'Witchwoode',
                                fontSize: 16,
                                color: theme.colorScheme.primary,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              aspectRatio: 16 / 11,
              viewportFraction: 0.8,
              autoPlay: true,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) =>
                  setState(() => _currentBanner = index),
            ),
          ),
        ),
        // 指示器（示意）
        AnimatedSmoothIndicator(
          activeIndex: _currentBanner,
          count: _scaledBannerImages.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
