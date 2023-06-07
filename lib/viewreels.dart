import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({Key? key}) : super(key: key);

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late List<Reel> _reels;
  late bool _isLoading;
  late bool _isFetching;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _reels = [];
    _isLoading = true;
    _isFetching = false;
    _pageController = PageController();
    _fetchReels();
  }

  void _fetchReels() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
    });
    // fetching the video(reel)
    await Future.delayed(const Duration(seconds: 2));
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy('time')
        .limit(10)
        .get();

    List<Reel> fetchedReels = snapshot.docs.map((doc) {
      return Reel(
        uid: doc.id, // Storing the document ID
        videoUrl: doc['videoUrl'],
        title: doc['title'],
        description: doc['description'],
        time: (doc['time'] as Timestamp).toDate(),
        likes: doc['likes'],
      );
    }).toList();
    setState(() {
      _isLoading = false;
      _isFetching = false;
      _reels.addAll(fetchedReels);
    });
  }

  void _handleLike(Reel reel) async {
    final docRef =
        FirebaseFirestore.instance.collection('videos').doc(reel.uid);

    if (reel.isLiked) {
      setState(() {
        reel.isLiked = false;
        reel.likes--;
      });
      await docRef.update({'likes': reel.likes});
    } else {
      setState(() {
        reel.isLiked = true;
        reel.likes++;
      });
      await docRef.update({'likes': reel.likes});
    }
  }

  Widget _buildReelItem(Reel reel) {
    VideoPlayerController _videoController =
        VideoPlayerController.network(reel.videoUrl!);
    ChewieController _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: true,

    );

    bool _isPlaying = false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
        });
        if (_isPlaying) {
          _videoController.play();
        } else {
          _videoController.pause();
        }
      },
      onLongPress: () {
        // TODO: Handle video pause and toggle title/description visibility
      },
      child: Stack(
        children: [
          Center(
            child: Chewie(
              controller: _chewieController,
            ),
          ),
          if (!_isPlaying)
            Center(
              child: Icon(
                Icons.play_circle_filled,
                size: 64,
                color: Colors.white,
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reel.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  reel.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _handleLike(reel),
                      icon: Icon(
                        reel.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: reel.isLiked ? Colors.red : null,
                      ),
                    ),
                    Text(reel.likes.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _reels.length,
              itemBuilder: (context, index) {
                return _buildReelItem(_reels[index]);
              },
            ),
    );
  }
}

class Reel {
  final String uid; // Add document ID property
  final String? videoUrl;
  final String? title;
  final String? description;
  final DateTime? time;
  int likes;
  bool isLiked;

  Reel({
    required this.uid, // Include document ID in the constructor
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.time,
    this.likes = 0,
    this.isLiked = false,
  });
}
