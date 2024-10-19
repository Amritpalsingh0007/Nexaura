import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class BetterPlayerManager {
  static final BetterPlayerManager _instance = BetterPlayerManager._internal();
  BetterPlayerController? _controller;

  factory BetterPlayerManager() {
    return _instance;
  }

  BetterPlayerManager._internal();

  BetterPlayerController getPlayerController(String videoUrl) {
    // If a new video URL is provided, dispose the existing controller.
    if (_controller != null) {
      _disposeCurrentController();
    }

    // Initialize a new controller if none exists or if a different video URL is requested.
    if (_controller == null) {
      _initializeController(videoUrl);
    }
    return _controller!;
  }

  void _initializeController(String videoUrl) {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
    );

    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enableSkips: true,
          skipBackIcon: Icons.replay_10,
          skipForwardIcon: Icons.forward_10,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _disposeCurrentController() {
    _controller?.dispose();
    _controller = null;
  }

  void disposePlayer() {
    _disposeCurrentController();
  }
}
