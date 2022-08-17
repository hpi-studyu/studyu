import 'package:flutter/material.dart';

class WebScaffold extends StatelessWidget {
  final String previewSrc;
  final String studyId;
  const WebScaffold(this.previewSrc, this.studyId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // todo make dynamic width should be half the size of height or height double the width
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 600,
      width: 300,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: HtmlElementView(key: key, viewType: '$studyId$key'),
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
