import 'package:studyu_core/core.dart';

/// Food Frequency Questionnaire (FFQ) - Dietary Fat and Free Sugar
/// Based on the short questionnaire for dietary assessment
class FFQQuestions {
  /// Standard frequency options for FFQ questions
  static List<Choice> get frequencyChoices => [
        Choice.withText(
          text: 'Less than once per month',
          id: 'less_than_once_per_month',
        ),
        Choice.withText(
          text: '2-3 times per month',
          id: '2_3_times_per_month',
        ),
        Choice.withText(
          text: '1-2 times per week',
          id: '1_2_times_per_week',
        ),
        Choice.withText(
          text: '3-4 times per week',
          id: '3_4_times_per_week',
        ),
        Choice.withText(
          text: 'At least 5 times per week',
          id: 'at_least_5_times_per_week',
        ),
      ];

  /// Standard intro text for the FFQ
  static const String introText =
      'Think about what you ate over the last year. Consider breakfast, lunch, dinner, and when you ate out.';

  /// Prompt text for frequency questions
  static const String promptPrefix =
      'Select the answer option that best describes how often you consumed the following food or drink:';

  /// Creates all FFQ questions
  static List<Question> createQuestions() {
    final questions = <Question>[];

    // Question 1: Ground meat
    questions.add(_createFrequencyQuestion(
      id: 'ffq_ground_meat',
      prompt: 'Ground meat, e.g. from beef or lamb, in burgers, Bolognese sauce, etc.',
    ));

    // Question 2: Pork or beef
    questions.add(_createFrequencyQuestion(
      id: 'ffq_pork_beef',
      prompt:
          'Pork or beef in the form of steaks, ribs, roasts or as sandwich meat/on sandwiches',
    ));

    // Question 3: Fried chicken
    questions.add(_createFrequencyQuestion(
      id: 'ffq_fried_chicken',
      prompt: 'Fried chicken (such as in chicken burgers, nuggets, etc.)',
    ));

    // Question 4: Sausages
    questions.add(_createFrequencyQuestion(
      id: 'ffq_sausages',
      prompt: 'Sausages, cured meats, e.g. wiener or salami',
    ));

    // Question 5: Bacon
    questions.add(_createFrequencyQuestion(
      id: 'ffq_bacon',
      prompt: 'Bacon/breakfast bacon',
    ));

    // Question 6: Salad dressings
    questions.add(_createFrequencyQuestion(
      id: 'ffq_salad_dressings',
      prompt: 'Salad dressings (not low-fat)',
    ));

    // Question 7: Butter/margarine
    questions.add(_createFrequencyQuestion(
      id: 'ffq_butter_margarine',
      prompt: 'Margarine, butter or oil when cooking',
    ));

    // Question 8: Eggs
    questions.add(_createFrequencyQuestion(
      id: 'ffq_eggs',
      prompt: 'Eggs (not when only egg whites were used)',
    ));

    // Question 9: Pizza
    questions.add(_createFrequencyQuestion(
      id: 'ffq_pizza',
      prompt: 'Pizza',
    ));

    // Question 10: Cheese
    questions.add(_createFrequencyQuestion(
      id: 'ffq_cheese',
      prompt: 'Cheese or cheese spread (not low-fat)',
    ));

    // Question 11: French fries
    questions.add(_createFrequencyQuestion(
      id: 'ffq_french_fries',
      prompt: 'French fries, potato pancakes, etc.',
    ));

    // Question 12: Chips
    questions.add(_createFrequencyQuestion(
      id: 'ffq_chips',
      prompt: 'Corn chips (e.g. nachos/tortilla chips), potato chips',
    ));

    // Question 13: Pastries/cookies
    questions.add(_createFrequencyQuestion(
      id: 'ffq_pastries',
      prompt:
          'Pancakes/donuts, croissants, sweet baked goods (e.g. plum cake, streusel cake, etc.)',
    ));

    // Question 14: Cakes/cookies
    questions.add(_createFrequencyQuestion(
      id: 'ffq_cakes_cookies',
      prompt: 'Cakes, cookies',
    ));

    // Question 15: Ice cream
    questions.add(_createFrequencyQuestion(
      id: 'ffq_ice_cream',
      prompt: 'Ice cream (not low-fat or sorbet)',
    ));

    // Question 16: Chocolate
    questions.add(_createFrequencyQuestion(
      id: 'ffq_chocolate',
      prompt: 'Chocolate',
    ));

    // Question 17: Candy
    questions.add(_createFrequencyQuestion(
      id: 'ffq_candy',
      prompt: 'Lollipops/hard candy/bonbons (with sugar)',
    ));

    // Question 18: Spreads
    questions.add(_createFrequencyQuestion(
      id: 'ffq_spreads',
      prompt: 'Spreads, such as peanut butter, marmalade, honey, Nutella',
    ));

    // Question 19: Pancakes
    questions.add(_createFrequencyQuestion(
      id: 'ffq_american_pancakes',
      prompt: 'American pancakes or French toast',
    ));

    // Question 20: Sports drinks
    questions.add(_createFrequencyQuestion(
      id: 'ffq_sports_drinks',
      prompt: 'Sports drinks or energy drinks (e.g. Red Bull)',
    ));

    // Question 21: Soft drinks
    questions.add(_createFrequencyQuestion(
      id: 'ffq_soft_drinks',
      prompt: 'Soft drinks, lemonade (not "light" versions)',
    ));

    // Question 22: Whole milk
    questions.add(_createFrequencyQuestion(
      id: 'ffq_whole_milk',
      prompt:
          'Whole milk, also in cappuccinos, hot chocolates, shakes, etc.',
    ));

    // Question 23: Sweetened beverages
    questions.add(_createFrequencyQuestion(
      id: 'ffq_sweetened_beverages',
      prompt:
          'Other sweetened beverages (such as juice with added sugar, syrup, iced tea, etc.)',
    ));

    // Question 24: White bread
    questions.add(_createFrequencyQuestion(
      id: 'ffq_white_bread',
      prompt: 'White bread',
    ));

    // Question 25: Fast food frequency
    questions.add(_createFrequencyQuestion(
      id: 'ffq_fast_food',
      prompt:
          'How often have you eaten at a fast food restaurant or had food delivered in the last year? (e.g. McDonalds, Pizza, Asian, etc.)',
      choices: [
        Choice.withText(text: 'None', id: 'none'),
        Choice.withText(text: '1-2', id: '1_2'),
        Choice.withText(text: '3-4', id: '3_4'),
        Choice.withText(text: '5-6', id: '5_6'),
        Choice.withText(text: '7 or more', id: '7_or_more'),
      ],
    ));

    // Question 26: Added sugar
    questions.add(_createFrequencyQuestion(
      id: 'ffq_added_sugar',
      prompt:
          'How many teaspoons of sugar have you added to drinks, muesli, or other foods in the last week?',
      choices: [
        Choice.withText(text: 'None', id: 'none'),
        Choice.withText(text: '1-2', id: '1_2'),
        Choice.withText(text: '3-4', id: '3_4'),
        Choice.withText(text: '5-6', id: '5_6'),
        Choice.withText(text: '7 or more', id: '7_or_more'),
      ],
    ));

    return questions;
  }

  /// Helper method to create a frequency question
  static ChoiceQuestion _createFrequencyQuestion({
    required String id,
    required String prompt,
    List<Choice>? choices,
  }) {
    final question = ChoiceQuestion.withId()
      ..id = id
      ..prompt = prompt
      ..multiple = false
      ..choices = choices ?? frequencyChoices;
    return question;
  }

  /// Create a complete FFQ questionnaire task
  /// This creates a standard questionnaire task, but the one-time logic
  /// is handled in the app's dashboard/schedule logic
  static QuestionnaireTask createFFQTask() {
    final task = QuestionnaireTask.withId()
      ..title = 'Food Frequency Questionnaire (FFQ)'
      ..header = introText
      ..footer =
          'Thank you for completing the Food Frequency Questionnaire!'
      ..questions.questions = createQuestions();

    // Set schedule for one-time completion at study start
    // Available all day on the first day only
    task.schedule = Schedule()
      ..completionPeriods = [
        CompletionPeriod.noId(
          unlockTime: StudyUTimeOfDay(hour: 0, minute: 0),
          lockTime: StudyUTimeOfDay(hour: 23, minute: 59),
        ),
      ]
      ..reminders = [
        StudyUTimeOfDay(hour: 9, minute: 0),
      ];

    return task;
  }

  /// Check if a task is an FFQ task based on its title
  static bool isFFQTask(String taskTitle) {
    return taskTitle.contains('Food Frequency Questionnaire') ||
           taskTitle.contains('FFQ');
  }
}

