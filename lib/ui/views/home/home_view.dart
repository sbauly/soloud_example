import 'package:flutter/material.dart';
import 'package:soloud_bug/services/my_audio_handler.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
              child: Column(children: [
            const Spacer(),

            /// The AudioPlugin currently being used
            ///
            Text(
              'Audio Plugin: ${viewModel.audioPluginLabel}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 80),
            Switch(
              value: viewModel.audioPlugin == AudioPlugin.soLoud ? true : false,
              onChanged: (bool value) {
                viewModel.toggleAudioPlugin();
              },
            ),

            /// The playPause button
            ///
            ValueListenableBuilder<bool>(
              valueListenable: viewModel.isPlayingNotifier,
              builder: (context, isPlaying, child) {
                return IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 200,
                    color: Colors.blue,
                  ),
                  onPressed: viewModel.playPause,
                );
              },
            ),
            const Spacer(),
          ])),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
