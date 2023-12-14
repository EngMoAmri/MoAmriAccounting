import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(500, 500),
      maximumSize: Size(500, 500),
      minimumSize: Size(500, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Column(
          children: [
            Expanded(child: Center(child: CircularProgressIndicator())),
            Center(
              child: Text("Loading"),
            )
          ],
        ),
      ),
    );
  }
}
