import 'package:flutter/material.dart';

class WebScaffold extends StatelessWidget {
  const WebScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      width: 300,
      child: Stack(
        children: <Widget>[
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            child: HtmlElementView(viewType: 'studyu_app_web_preview'),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                border: Border.all(width: 4, color: Colors.blue),
                shape: BoxShape.rectangle),
          ),
        ],
      ),
    );
  }
}

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 600,
        width: 300,
      ),
    );
  }
}

class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 600,
        width: 300,
      ),
    );
  }
}
