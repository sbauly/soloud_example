import 'package:flutter/material.dart';
import 'package:soloud_bug/app/app.locator.dart';
import 'package:soloud_bug/services/my_audio_handler.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends ReactiveViewModel {
  HomeViewModel() {
    initAudio();
    _listenToPlaybackState();
  }

  /// Audio handler
  final _audioHandler = locator<MyAudioHandler>();

  String? audioPluginLabel;
  AudioPlugin get audioPlugin => _audioHandler.audioPlugin;

  /// Initialize the audio
  void initAudio() {
    _audioHandler.initAudio();
    audioPluginLabel = _audioHandler.audioPlugin.label;
    rebuildUi();
  }

  /// Play or pause the audio
  Future<void> playPause() async {
    if (isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }

    rebuildUi();
  }

  /// Change audio plugin (SoLoud or JustAudio)
  void toggleAudioPlugin() {
    _audioHandler.toggleAudioPlugin();
    audioPluginLabel = _audioHandler.audioPlugin.label;
    rebuildUi();
  }

  /// Whether audio is playing
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  bool get isPlaying => isPlayingNotifier.value;

  /// Listen to the playbackState stream and update [isPlayingNotifier]
  void _listenToPlaybackState() {
    _audioHandler.playbackStateStream.listen((playbackState) {
      isPlayingNotifier.value = playbackState.playing;
    });
  }
}
