import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:better_player/better_player.dart'; // Import Better Player
import 'package:nexaura/features/app/services/api_service.dart';
import 'package:path/path.dart'; // for handling file paths

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  File? _video;
  BetterPlayerController? _betterPlayerController; // Better Player controller
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadMessage;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<String?> _getUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid; // Returns the UID of the logged-in user
    }
    return null;
  }


  // Function to pick video from gallery or camera
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
        _initializeBetterPlayer();
      });
    }
  }

  // Initialize Better Player
  void _initializeBetterPlayer() {
    if (_video != null) {
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        _video!.path,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    }
  }

  // Dispose Better Player controller
  @override
  void dispose() {
    _betterPlayerController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Function to upload video to the server
  Future<void> _uploadVideo() async {
    if (_video == null) return;

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });
    String userId = await _getUserId() ?? "";
    try {
      String uploadUrl = '${ApiService.apiBaseUrl}api/upload';

      FormData formData = FormData.fromMap({
        "video": await MultipartFile.fromFile(
          _video!.path,
          filename: basename(_video!.path),
        ),
        "title": _titleController.text,
        "description": _descriptionController.text,
        "tags": _tagsController.text.split(','),
        "uploaderId" : userId
      });

      Dio dio = Dio();
      var response = await dio.post(uploadUrl, data: formData);
      setState(() {
        _uploadMessage = 'Upload Successful: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _uploadMessage = 'Upload Failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text('Pick Video'),
              ),
              const SizedBox(height: 20),
              if (_video != null) ...[
                _betterPlayerController != null
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: BetterPlayer(controller: _betterPlayerController!),
                      )
                    : const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text('Video selected: ${basename(_video!.path)}'),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadVideo,
                      child: const Text('Upload Video'),
                    ),
              const SizedBox(height: 20),
              if (_uploadMessage != null) Text(_uploadMessage!),
            ],
          ),
        ),
      ),
    );
  }
}
