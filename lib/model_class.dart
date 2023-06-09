
class Reel {
  final String uid;
  final String? videoUrl;
  final String? title;
  final String? description;
  final String? time;
  int likes;
  bool isLiked;

  Reel({
    required this.uid,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.time,
    this.likes = 0,
    this.isLiked = false,
  });
}
