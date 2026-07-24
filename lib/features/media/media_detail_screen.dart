import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/utils/format_number.dart';
import 'package:hoople_mobile_app/models/post_model.dart';
import 'package:hoople_mobile_app/models/user_model.dart';

class MediaDetailScreen extends StatefulWidget {
  final int initialIndex;
  final List<PostModel> posts;
  final UserModel user;

  const MediaDetailScreen({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.user,
  });

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        scrolledUnderElevation: 0.0,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // Media
              Image.asset(
                post.imageUrl,
                fit: BoxFit.cover,
              ),

              // Gradient Overlay for text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),

              // Content overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left side: User info and caption
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: AssetImage(
                                    widget.user.imageUrl,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.user.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // ElevatedButton(
                                //   onPressed: () {},
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors.transparent,
                                //     foregroundColor: Colors.white,
                                //     side: const BorderSide(color: Colors.white),
                                //     minimumSize: const Size(60, 24),
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 12,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(12),
                                //     ),
                                //   ),
                                //   child: const Text(
                                //     'Follow',
                                //     style: TextStyle(fontSize: 12),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(right: 50),
                              child: Text(
                                post.caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Right side: Action buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            CupertinoIcons.heart,
                            formatNumber(post.likes),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            CupertinoIcons.chat_bubble,
                            formatNumber(post.comments),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            CupertinoIcons.share,
                            formatNumber(post.shares),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            CupertinoIcons.info,
                            '',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
