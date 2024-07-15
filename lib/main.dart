import 'package:flutter/material.dart';
import 'package:soloud_bug/app/app.bottomsheets.dart';
import 'package:soloud_bug/app/app.dialogs.dart';
import 'package:soloud_bug/app/app.locator.dart';
import 'package:soloud_bug/app/app.router.dart';
import 'package:soloud_bug/services/my_audio_handler.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  /// Init audio service on app start
  late final MyAudioHandler audioHandler = locator<MyAudioHandler>();
  await audioHandler.initAudioService();

  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
