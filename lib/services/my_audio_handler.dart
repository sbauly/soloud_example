// ignore_for_file: avoid_print

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:just_audio/just_audio.dart' as ja;

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler() {
    _updatePlaybackState();
  }

  /// Initialize the AudioService
  Future<void> initAudioService() async {
    await AudioService.init(
      builder: () => this,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.soloudbug.myapp.audio',
        androidStopForegroundOnPause: false,
      ),
    );

    /// Set up the audio session
    _audioSession = await AudioSession.instance;
    await _setupAudioSession(_audioSession);
  }

  /// Stream controller for playback state
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  /// If audio is playing
  bool isPlaying = false;

  /// The audio plugin being used, either SoLoud or JustAudio
  var audioPlugin = AudioPlugin.soLoud;

  /// JustAudio player
  final _justAudio = ja.AudioPlayer(handleInterruptions: false);

  /// The music handle
  SoundHandle? _musicHandle;

  /// The music sources
  AudioSource? _musicSource;

  /// The [AudioSession]
  late final AudioSession _audioSession;

  /// Initialize both [AudioPlugin]s
  Future<void> initAudio() async {
    await SoLoud.instance.init();

    /// Load an asset
    _musicSource =
        await SoLoud.instance.loadAsset('assets/8_bit_mentality.mp3');

    /// Set up the player
    if (_musicSource != null) {
      _musicHandle = await SoLoud.instance
          .play(_musicSource!, paused: true, looping: true, volume: 1);
    }

    /// Just audio
    await _justAudio.setAsset('assets/8_bit_mentality.mp3');

    initMedia();
  }

  /// Set up the [AudioSession]
  Future<void> _setupAudioSession(AudioSession session) async {
    /// Configure the audio session for music
    await session.configure(const AudioSessionConfiguration.music());

    /// Activate the audio session
    final bool success = await session.setActive(true);
    if (success) {
      _handleInterruptions(session);

      print("Audio session is active");
    } else {
      print("Failed to activate audio session");
    }
  }

  /// Handle audio interruptions
  void _handleInterruptions(AudioSession audioSession) {
    audioSession.interruptionEventStream.listen((event) async {
      print(
          'Interruption event: ${event.begin ? 'began' : 'ended'}, type: ${event.type}');

      if (event.begin) {
        /// Interruption began
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:

            /// Pause the audio when an interruption begins
            ///
            if (isPlaying) {
              await pause();
            }
        }
      } else {
        /// Interruption ended
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:

          /// play() will be called when a user places the app in the foreground again, so no need to resume immediately here
          ///
        }
      }
    });
  }

  /// Request audio focus.
  Future<bool> requestFocus(
      [Duration timeout = const Duration(seconds: 1)]) async {
    try {
      final success = await _audioSession.setActive(true).timeout(
            timeout,
            onTimeout: () => false,
          );
      print('AUDIO SESSION: Audio focus requested: $success');
      return success;
    } catch (e) {
      print('Error requesting audio focus: $e');
      return false;
    }
  }

  /// Add the [MediaItem]
  Future<void> initMedia() async {
    /// Add the media item
    mediaItem.add(MediaItem(
      id: 'test',
      title: 'Song',
      artist: 'Artist',
      artUri: Uri.parse('https://picsum.photos/250?image=9'),
    ));
  }

  /// Toggle the audio plugin (SoLoud or JustAudio)
  void toggleAudioPlugin() {
    audioPlugin = audioPlugin == AudioPlugin.soLoud
        ? AudioPlugin.justAudio
        : AudioPlugin.soLoud;
  }

  /// Master pause
  @override
  Future<void> pause() async {
    if (audioPlugin == AudioPlugin.soLoud) {
      SoLoud.instance.setPause(_musicHandle!, true);
    } else {
      await _justAudio.pause();
    }
    isPlaying = false;
    _updatePlaybackState();
    return super.pause();
  }

  /// Master play
  @override
  Future<void> play() async {
    /// Request audio focus
    await requestFocus();
    if (audioPlugin == AudioPlugin.soLoud) {
      SoLoud.instance.setPause(_musicHandle!, false);
    } else {
      _justAudio.play();
    }

    isPlaying = true;
    _updatePlaybackState();
    print('AUDIO HANDLER: Audio playback resumed');
    return super.play();
  }

  /// Master stop
  @override
  Future<void> stop() async {
    pause();
    isPlaying = false;
    _updatePlaybackState();
    return super.stop();
  }

  /// Dispose the playback state controller
  void dispose() {
    stop();
    _playbackStateController.done;
  }

  /// Update the playback state for background controls in the OS
  void _updatePlaybackState() {
    final PlaybackState state = PlaybackState(
      controls: [
        if (isPlaying) MediaControl.pause else MediaControl.play,
      ],
      systemActions: const {},
      playing: isPlaying,
      processingState: AudioProcessingState.ready,
    );

    playbackState.add(playbackState.value.copyWith(
      controls: [
        if (isPlaying) MediaControl.pause else MediaControl.play,
      ],
      systemActions: const {},
      playing: isPlaying,
      processingState: AudioProcessingState.ready,
    ));
    _playbackStateController.add(state);
    print('AUDIO HANDLER ISPLAYING = $isPlaying');
  }
}

enum AudioPlugin {
  soLoud('SoLoud'),
  justAudio('Just Audio');

  const AudioPlugin(this.label);

  final String label;
}
