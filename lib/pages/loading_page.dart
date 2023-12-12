import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
                child: Center(child: Image.asset("assets/gifs/loading.gif"))),
            Center(
              child: Text("Loading"),
            )
          ],
        ),
      ),
    );
  }
}
