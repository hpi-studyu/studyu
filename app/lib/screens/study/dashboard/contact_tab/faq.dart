import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(Manisha): Transfer strings to translation files
    if (AppLocalizations.of(context)!.faq_full == 'Frequently Asked Questions') {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.faq_full),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) => EntryItem(data_en[index]),
          itemCount: data_en.length,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.faq_full),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) => EntryItem(data_de[index]),
          itemCount: data_de.length,
        ),
      );
    }
  }
}

class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);
  final String title;
  final List<Entry> children;
}

// ignore: non_constant_identifier_names
final List<Entry> data_en = <Entry>[
  Entry(
    'Data Storage and Privacy',
    <Entry>[
      Entry(
        'Where and how is my data stored?',
        <Entry>[
          Entry(
            'The data collected from you is stored locally on your device and is uploaded to a secure server when it is connected to the internet.',
          ),
        ],
      ),
      Entry(
        'Which personal data does the app collect?',
        <Entry>[
          Entry(
            'The app does not collect any personal data of the user, it however, needs to access the time and location.',
          ),
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
            'Please note: You will lose all your data for the current study after you opt out. ',
          ),
        ],
      ),
      Entry(
        'Can I redo my missed tasks on a later date?',
        <Entry>[
          Entry(
            'No, you cannot redo a missed task on a later date. '
            'However, you can finish it at anytime on the same day.',
          ),
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
            'To find out which intervention works best for you,you need to perform some daily tasks for each intervention. Please make sure to hit the "Complete" button after finishing it',
          ),
        ],
      ),
      Entry(
        'What is "Rate your day"?',
        <Entry>[
          Entry(
            '"Rate your day" is a feature that tracks your health during entire study period. It requires you to rate certain health-related queries on a scale of 1 to 10.',
          ),
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
            'You can download your report once you have completed the minimum required tasks. It will be available in the Report History tab located on the Dashboard.',
          ),
        ],
      ),
      Entry(
        'How can I download my Study report?',
        <Entry>[
          Entry(
            'Your report will be ready to download once you have completed the minimum required tasks for a study. It will be available in the Report History tab located on the Dashboard.',
          ),
        ],
      ),
    ],
  ),
];

// ignore: non_constant_identifier_names
final data_de = <Entry>[
  Entry(
    'Datenspeicherung und Datenschutz',
    <Entry>[
      Entry(
        'Wo und wie werden meine Daten gespeichert?',
        <Entry>[
          Entry(
            'Die von Ihnen gesammelten Daten werden lokal auf Ihrem Gerät gespeichert und bei Verbindung mit dem Internet auf einen sicheren Server hochgeladen.',
          ),
        ],
      ),
      Entry(
        'Welche persönlichen Daten sammelt die App?',
        <Entry>[
          Entry('Die App sammelt keine persönlichen Daten des Benutzers, muss jedoch auf Zeit und Ort zugreifen.'),
        ],
      ),
    ],
  ),
  Entry(
    'das Studium',
    <Entry>[
      Entry(
        'Wie lange dauert es, bis die Studie abgeschlossen ist?',
        <Entry>[
          Entry('Die Dauer jeder Studie wird bei der ersten Studienauswahl angegeben.'),
        ],
      ),
      Entry(
        'Kann ich eine andere Intervention erneut auswählen?',
        <Entry>[
          Entry(
            'Ja, Sie können einfach zum Interventionsauswahlbildschirm zurückkehren und eine andere Intervention erneut auswählen, bevor Sie mit der Studie beginnen. '
            'Wenn Sie dies jedoch zu einem späteren Zeitpunkt planen, müssen Sie die Studie abbestellen und eine neue Intervention erneut auswählen. '
            'Bitte beachten Sie: Sie verlieren alle Ihre Daten für die aktuelle Studie, nachdem Sie sich abgemeldet haben. ',
          ),
        ],
      ),
      Entry(
        'Kann ich meine verpassten Aufgaben zu einem späteren Zeitpunkt wiederholen?',
        <Entry>[
          Entry(
            'Nein, Sie können eine verpasste Aufgabe zu einem späteren Zeitpunkt nicht wiederholen. '
            'Sie können es jedoch jederzeit am selben Tag beenden.',
          ),
        ],
      ),
      Entry(
        'Wie kann ich mich von der aktuellen Studie abmelden?',
        <Entry>[
          Entry(
            'Sie können dies tun, indem Sie im Dashboard auf die Registerkarte "Einstellungen" gehen und auf "Deaktivieren" klicken. ',
          ),
        ],
      ),
    ],
  ),
  Entry(
    'Berichtsdetails',
    <Entry>[
      Entry(
        'Was sind tägliche Aufgaben und wie erledige ich sie?',
        <Entry>[
          Entry(
            'Um herauszufinden, welche Intervention für Sie am besten geeignet ist, müssen Sie für jede Intervention einige tägliche Aufgaben ausführen. Bitte stellen Sie sicher, dass Sie nach Abschluss auf die Schaltfläche "Fertig stellen" klicken.',
          ),
        ],
      ),
      Entry(
        'Was ist "Bewerten Sie Ihren Tag"?',
        <Entry>[
          Entry(
            '"Bewerten Sie Ihren Tag" ist eine Funktion, die Ihre Gesundheit während des gesamten Studienzeitraums erfasst. Sie müssen bestimmte gesundheitsbezogene Abfragen auf einer Skala von 1 bis 10 bewerten.',
          ),
        ],
      ),
      Entry(
        'Wie kann ich meine Aktivitäten verfolgen?',
        <Entry>[
          Entry(
            'Im Abschnitt "Berichtsverlauf" erhalten Sie einen Überblick über Ihre täglichen Aufgaben und Ihren Gesundheitszustand.',
          ),
        ],
      ),
      Entry(
        'Wie kann ich meinen Bericht herunterladen?',
        <Entry>[
          Entry(
            'Sie können Ihren Bericht herunterladen, sobald Sie die erforderlichen Mindestaufgaben erledigt haben. Es ist auf der Registerkarte Berichtsverlauf im Dashboard verfügbar.',
          ),
        ],
      ),
      Entry(
        'Wie kann ich meinen Studienbericht herunterladen?',
        <Entry>[
          Entry(
            'Ihr Bericht kann heruntergeladen werden, sobald Sie die für eine Studie erforderlichen Mindestaufgaben erledigt haben. Es ist auf der Registerkarte Berichtsverlauf im Dashboard verfügbar.',
          ),
        ],
      ),
    ],
  ),
];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry, {super.key});

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
