// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoople_mobile_app/models/event_model.dart';
// import 'package:optimind_ui/model/event_model.dart';
import 'package:hoople_mobile_app/models/post_model.dart';
import 'package:hoople_mobile_app/models/user_model.dart';
// import 'package:hoople_mobile_app/media/media_detail_screen.dart';

class StackedAlbum extends StatefulWidget {
  final EventModel event;
  const StackedAlbum({super.key, required this.event});

  @override
  State<StackedAlbum> createState() => _StackedAlbumState();
}

class _StackedAlbumState extends State<StackedAlbum> {
  bool _isExpanded = false;
  List<PostModel> _posts = [];
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String postsStr = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/posts.json');
    final List<dynamic> postsJson = json.decode(postsStr);

    final String usersStr = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/users.json');
    final List<dynamic> usersJson = json.decode(usersStr);

    if (mounted) {
      setState(() {
        _posts = postsJson.map((e) => PostModel.fromJson(e)).toList();
        if (usersJson.isNotEmpty) {
          _user = UserModel.fromJson(
            usersJson.firstWhere(
              (u) => u['id'] == _posts.first.userId,
              orElse: () => usersJson.first,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Shared Moments",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sf-pro',
                ),
              ),
              if (widget.event.isFollowing)
                TextButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? "Stack View" : "Collapse",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 0 : 24),
          margin: EdgeInsets.symmetric(horizontal: _isExpanded ? 0 : 24),
          height: 230,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation.drive(
                    Tween(begin: 0.9, end: 1.0).chain(
                      CurveTween(curve: Curves.easeOutBack),
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: _isExpanded ? _buildHorizontalList() : _buildStackedView(),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedView() {
    if (_posts.isEmpty) return const Center(child: CircularProgressIndicator());
    return GestureDetector(
      key: const ValueKey('stacked'),
      onTap: widget.event.isFollowing
          ? () => setState(() => _isExpanded = true)
          : null,
      child: Center(
        child: SizedBox(
          height: 240,
          width: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_posts.length > 3)
                _buildPhotoCard(
                  _posts[3].imageUrl,
                  -0.2,
                  const Offset(-40, -10),
                ),
              if (_posts.length > 2)
                _buildPhotoCard(_posts[2].imageUrl, 0.15, const Offset(30, -5)),
              if (_posts.length > 1)
                _buildPhotoCard(
                  _posts[1].imageUrl,
                  -0.1,
                  const Offset(-10, 10),
                ),
              if (_posts.isNotEmpty)
                _buildPhotoCard(_posts[0].imageUrl, 0.05, const Offset(10, 5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    if (_posts.isEmpty) return const Center(child: CircularProgressIndicator());
    return SizedBox(
      key: const ValueKey('list'),
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return _buildSeeMoreCard();
          }
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (_user != null) {
                  context.push(
                    '/media-detail',
                    extra: {
                      'initialIndex': index,
                      'posts': _posts,
                      'user': _user!,
                    },
                  );
                }
              },
              child: _buildPhotoCard(
                _posts[index].imageUrl,
                0,
                Offset.zero,
                width: 140,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeMoreCard() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          const Text(
            "See All",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'sf-pro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(
    String asset,
    double rotation,
    Offset offset, {
    double width = 160,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: width,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: ClipSmoothRect(
            radius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.6,
            ),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
