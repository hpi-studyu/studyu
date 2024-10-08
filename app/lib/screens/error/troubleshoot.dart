import 'package:flutter/material.dart';

class TroubleshootScreen extends StatefulWidget {
  final String? error;
  const TroubleshootScreen({super.key, this.error});

  @override
  State<TroubleshootScreen> createState() => _TroubleshootScreenState();
}

class _TroubleshootScreenState extends State<TroubleshootScreen> {
  final List<ExpansionPanelListItem> _expansionPanelItems = [
    ExpansionPanelListItem(
      title: 'Test 1',
      bodyMessage: 'Test message',
      buttonText: 'Action',
      onPressed: () {
        print('Action 1');
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshoot'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //contact mail card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Still need help?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('If you need help, please contact us at @asd.com'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong. Here are some details to help you troubleshoot the issue.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expansionPanelItems[index].isExpanded = isExpanded;
                  });
                },
                children: List.generate(_expansionPanelItems.length, (index) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(_expansionPanelItems[index].title),
                      );
                    },
                    body: ListTile(
                      title: Text(
                        _expansionPanelItems[index].bodyMessage,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      horizontalTitleGap: 30,
                      trailing: _expansionPanelItems[index].buttonText != null
                          ? ElevatedButton(
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(
                                    foregroundColor: WidgetStateProperty.all(
                                        Theme.of(context).colorScheme.primary),
                                  ),
                              onPressed: _expansionPanelItems[index].onPressed,
                              child:
                                  Text(_expansionPanelItems[index].buttonText!),
                            )
                          : null,
                    ),
                    isExpanded: _expansionPanelItems[index].isExpanded,
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExpansionPanelListItem {
  final String title;
  final String bodyMessage;
  final String? buttonText;
  final Function()? onPressed;
  bool isExpanded;

  ExpansionPanelListItem({
    required this.title,
    required this.bodyMessage,
    this.buttonText,
    this.onPressed,
    this.isExpanded = false,
  });
}
