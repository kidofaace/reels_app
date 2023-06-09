import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reel_app/splash.dart';
import 'package:video_player/video_player.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  File? _selectedVideo;
  late String? _videoTitle;
  late String? _videoDescription;
  late int? _videoLikes = 0;
  late VideoPlayerController? _videoController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) {
      return;
    }

    // video going to Firebase Storage
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
    UploadTask uploadTask = storageRef.putFile(_selectedVideo!);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});


    String downloadUrl = await snapshot.ref.getDownloadURL();//this gives the url

    await FirebaseFirestore.instance.collection('videos').add({  //this shows to uploading iof the reels
      'videoUrl': downloadUrl,   //video's link
      'title': _videoTitle, //title of the video
      'description': _videoDescription,  //description
      'time': DateTime.now(),  //time when uploaded
      'likes': _videoLikes,   //number of likes
    });

    // Reset state
    setState(() {
      _selectedVideo = null;
      _videoTitle = null;
      _videoDescription = null;
      _videoLikes = 0;
    });


    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video uploaded successfully')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _videoController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Upload Video'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text('Pick Video'),
              ),
              const SizedBox(height: 16),
              if (_selectedVideo != null && _videoController != null)
                SizedBox(
                  height: 200,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _videoTitle = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _videoDescription = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadVideo,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
