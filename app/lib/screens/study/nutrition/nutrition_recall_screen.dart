import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_screen.dart';
import 'package:studyu_core/core.dart';

class NutritionRecallScreen extends StatefulWidget {
  const NutritionRecallScreen({super.key});

  static MaterialPageRoute<void> route() =>
      MaterialPageRoute(builder: (_) => const NutritionRecallScreen());

  @override
  State<NutritionRecallScreen> createState() => _NutritionRecallScreenState();
}

class _NutritionRecallScreenState extends State<NutritionRecallScreen> {
  List<DailyRecall> dailyRecalls = [];

  Future<void> _startNewRecall() async {
    final result = await Navigator.of(context).push(
      DailyRecallEntryScreen.route(),
    );
    if (result != null) {
      setState(() {
        dailyRecalls.add(result);
      });
    }
  }

  Future<void> _viewRecall(DailyRecall recall) async {
    await Navigator.of(context).push(
      DailyRecallEntryScreen.route(existingRecall: recall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Diary'),
      ),
      body: dailyRecalls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dietary recalls recorded yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to start recording',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dailyRecalls.length,
              itemBuilder: (context, index) {
                final recall = dailyRecalls[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${recall.meals.length}'),
                    ),
                    title: Text(
                      '${recall.date.day}/${recall.date.month}/${recall.date.year}',
                    ),
                    subtitle: Text(
                      '${recall.meals.length} meals recorded',
                    ),
                    trailing: Icon(
                      recall.entryCompletedAt != null
                          ? Icons.check_circle
                          : Icons.edit,
                      color: recall.entryCompletedAt != null
                          ? Colors.green
                          : Colors.orange,
                    ),
                    onTap: () => _viewRecall(recall),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewRecall,
        child: const Icon(Icons.add),
      ),
    );
  }
}

