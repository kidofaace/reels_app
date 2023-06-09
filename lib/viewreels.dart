import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'model_class.dart';
import 'package:pagination_view/pagination_view.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({Key? key}) : super(key: key);

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late List<Reel> _reels;
  late bool _isLoading;
  late bool _isFetching;


  @override
  void initState() {
    super.initState();
    _reels = [];
    _isLoading = true;
    _isFetching = false;
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    if (_isFetching) return;

    setState(() {
      _isFetching = true;
    });

    // Simulating API call delay
    await Future.delayed(const Duration(seconds: 2));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy('time')
        .limit(2)
        .get();

    List<Reel> fetchedReels = snapshot.docs.map((doc) {
      return Reel(
          uid: doc.id,
          videoUrl: doc['videoUrl'],
          title: doc['title'],
          description: doc['description'],
          likes: doc['likes'],
          time: doc['time']

      );
    }).toList();

    setState(() {
      _isLoading = false;
      _isFetching = false;
      _reels.addAll(fetchedReels);
    });
  }

  void _handleLike(Reel reel) async {
    final docRef = FirebaseFirestore.instance.collection('videos').doc(
        reel.uid);

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
    VideoPlayerController _videoController = VideoPlayerController.network(
        reel.videoUrl!);
    ChewieController _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
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
          ? Center(
        child: CircularProgressIndicator(),
      )
          : PaginationView<Reel>(
        pageFetch: _fetchReels,

        itemBuilder: (BuildContext context, Reel reel, int index) {
          return _buildReelItem(reel);
        },
        onEmpty
        :Center(
          child: SnackBar(content: Text('Error'),),
        ),
        onError: (dynamic error) {
          return Center(
            child: Text('Error: $error'),
          );
        },
        paginationViewType: PaginationViewType.listView,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        pullToRefresh: true,
      ),
    );
  }
}
