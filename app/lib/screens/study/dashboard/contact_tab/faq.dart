import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => EntryItem(data[index]),
        itemCount: data.length,
      ),
    );
  }
}

class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);
  final String title;
  final List<Entry> children;
}

final List<Entry> data = <Entry>[
  Entry(
    'Data Storage and Privacy',
    <Entry>[
      Entry(
        'Where and how is my data stored?',
        <Entry>[
          Entry(
              'The data collected from you is stored locally on your device and is uploaded to a secure server when it is connected to the internet.'),
        ],
      ),
      Entry(
        'Which personal data does the app collect?',
        <Entry>[
          Entry(
              'The app does not collect any personal data of the user, it however, needs to access the time and location.'),
        ],
      ),
    ],
  ),
  Entry(
    'Studies',
    <Entry>[
      Entry(
        'How long will the study take to finish?',
        <Entry>[
          Entry('The duration of each study is mentioned during initial study selection.'),
        ],
      ),
      Entry(
        'Can I reselect another intervention?',
        <Entry>[
          Entry(
              'Yes you can simply go back to the intervention selection screen and reselect a different intervention before you start the study. '
              'However, if you plan to do it at a later stage, you have to opt out of the study and reselect a new intervention. '
              'Please note: You will lose all your data for the current study after you opt out. '),
        ],
      ),
      Entry(
        'Can I redo my missed tasks on a later date?',
        <Entry>[
          Entry('No, you cannot redo a missed task on a later date. '
              'However, you can finish it at anytime on the same day.'),
        ],
      ),
      Entry(
        'How can I Opt out from the current study?',
        <Entry>[
          Entry('You can do so by going to the Settings tab located on the Dashboard and clicking on "Opt-out" '),
        ],
      ),
    ],
  ),
  Entry(
    'Report Details',
    <Entry>[
      Entry(
        'What are daily tasks and how do I complete them?',
        <Entry>[
          Entry(
              'To find out which intervention works best for you,you need to perform some daily tasks for each intervention. Please make sure to hit the "Complete" button after finishing it'),
        ],
      ),
      Entry(
        'What is "Rate your day"?',
        <Entry>[
          Entry(
              '"Rate your day" is a feature that tracks your health during entire study period. It requires you to rate certain health-related queries on a scale of 1 to 10.'),
        ],
      ),
      Entry(
        'How can I keep track of my activities?',
        <Entry>[
          Entry('You can get an overview of your daily tasks and health status in the "Reports History section"'),
        ],
      ),
      Entry(
        'How can I download my report?',
        <Entry>[
          Entry(
              'You can download your report once you have completed the minimum required tasks. It will be available in the Report History tab located on the Dashboard.'),
        ],
      ),
      Entry(
        'How can I download my Study report?',
        <Entry>[
          Entry(
              'Your report will be ready to download once you have completed the minimum required tasks for a study. It will be available in the Report History tab located on the Dashboard.'),
        ],
      ),
    ],
  ),
];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(
        root.title,
      ),
      children: root.children.map<Widget>(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
