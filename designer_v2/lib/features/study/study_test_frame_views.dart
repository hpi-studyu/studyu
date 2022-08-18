import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';

class WebFrame extends StatelessWidget {
  final String previewSrc;
  final String studyId;
  const WebFrame(this.previewSrc, this.studyId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // todo make dynamic width should be half the size of height or height double the width
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: HtmlElementView(key: key, viewType: '$studyId$key'),
      borderColor: theme.colorScheme.secondary.withOpacity(0.4),
      innerContentBackgroundColor: theme.colorScheme.secondary.withOpacity(0.025),
    );
  }
}

class DisabledFrame extends StatelessWidget {
  const DisabledFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: const Center(
        child: Opacity(
          opacity: 0.3,
          child: EmptyBody(
            icon: Icons.visibility_off_rounded,
            title: "",
            description: "",
          ),
        ),
      ),
      borderColor: theme.colorScheme.secondary.withOpacity(0.25),
      innerContentBackgroundColor: theme.colorScheme.secondary.withOpacity(0.03),
    );
  }
}

class PhoneContainer extends StatelessWidget {
  const PhoneContainer({
    required this.innerContent,
    this.width = 300,
    this.height = 600,
    this.borderColor = Colors.black,
    this.borderWidth = 6.0,
    this.borderRadius = 25.0,
    this.innerContentBackgroundColor = Colors.white,
    Key? key
  }) : super(key: key);

  final double width;
  final double height;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  final Widget innerContent;
  final Color? innerContentBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Padding(
                  padding: EdgeInsets.all(borderWidth),
                  child: Stack(
                    children: [
                      Container(color: innerContentBackgroundColor),
                      innerContent,
                    ],
                  ),
                ),
              ),
              ClipRRect( // opaque border so that we can draw on top with other colors
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      border: Border.all(width: borderWidth, color: Colors.white),
                      shape: BoxShape.rectangle
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              border: Border.all(width: borderWidth, color: borderColor),
              shape: BoxShape.rectangle
            ),
          ),
        ],
      ),
    );
  }
}

class MobileFrame extends StatelessWidget {
  const MobileFrame({Key? key}) : super(key: key);

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

class DesktopFrame extends StatelessWidget {
  const DesktopFrame({Key? key}) : super(key: key);

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
