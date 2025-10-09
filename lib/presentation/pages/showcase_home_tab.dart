import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:skill_showcase/repositories/photo_repository.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/photo_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowcaseHomeTab extends StatefulWidget {
  const ShowcaseHomeTab({super.key});

  @override
  State<ShowcaseHomeTab> createState() => _ShowcaseHomeTabState();
}

class _ShowcaseHomeTabState extends State<ShowcaseHomeTab> {
  int _currentBanner = 0;
  final _repo = PhotoRepository();
  late Future<List<PhotoInfo>> _photos;

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

    _photos = _repo.fetchPhotoManifest();
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
              _bannerWrapper(),
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

  Widget _bannerWrapper() {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: _photos,
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapShot.hasError) {
          return Center(child: Text('Error: ${snapShot.error}'));
        } else if (snapShot.hasData) {
          final photos = snapShot.data!;
          return _buildBanner(theme, photos);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildBanner(ThemeData theme, List<PhotoInfo> photos) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: screenWidth * 11 / 16 + 28,
          width: double.infinity,
          child: CarouselSlider(
            items: photos.map((photo) {
              final smallUrl = PhotoRepository.baseUrl + photo.versions['256']!;
              final mediumUrl =
                  PhotoRepository.baseUrl + photo.versions['1080']!;
              // final image = _scaledBannerImages[i];
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
                          child: CachedNetworkImage(
                            imageUrl: mediumUrl,
                            placeholder: (context, url) => Image.network(
                              smallUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
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
                              photo.timeStamp.toUtc().toString(),
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
          count: photos.length,
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
