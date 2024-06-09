import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/theme.dart';

class HtmlStylingBanner extends StatelessWidget {
  const HtmlStylingBanner(
      {this.isDismissed = false, this.onDismissed, super.key,});

  final bool isDismissed;
  final Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: BannerBox(
        style: BannerStyle.info,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        noPrefix: true,
        isDismissed: isDismissed,
        onDismissed: onDismissed,
        dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
        body: Column(
          children: [
            // todo tr and create Map for table examples)
            TextParagraph(
              text:
                  "You can use basic HTML tags to style the content of the fields marked with styleable. Some examples are:",
              style: ThemeConfig.bodyTextMuted(theme),
            ),
            const SizedBox(height: 8.0),
            SelectionArea(
              child: Table(
                border: TableBorder.all(color: Colors.transparent),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(4),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      const Text('Make your text bold'),
                      Text('<b>Bold text</b>',
                          style: ThemeConfig.bodyTextMuted(theme),),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Add a hyperlink'),
                      Text(
                        '<a href="http://example.org">A hyperlink</a>',
                        style: ThemeConfig.bodyTextMuted(theme),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Make your text colorful'),
                      Text(
                        '<span style="color: red">Red text</span>',
                        style: ThemeConfig.bodyTextMuted(theme),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Add an image'),
                      Text(
                        '<img width="100" src="<link>" />',
                        style: ThemeConfig.bodyTextMuted(theme),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Add a video'),
                      Text(
                        '<video controls width="100" src="<link>" />',
                        style: ThemeConfig.bodyTextMuted(theme),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Add an audio message'),
                      Text(
                        '<audio controls src="<link>" />',
                        style: ThemeConfig.bodyTextMuted(theme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            const Hyperlink(
              icon: Icons.north_east_rounded,
              text: 'A full list of all supported tags can be found here',
              url: 'https://demo.fwfh.dev/supported/tags.html',
            ),
          ],
        ),
      ),
    );
  }
}
