import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/converter_context.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ExpressionConverter {
  ExpressionConverter._();

  static Map<String, dynamic>? expressionToLogic(
    Expression? expression, {
    required List<Question> questions,
    ExportContext? context,
  }) {
    if (expression == null) return null;

    if (expression is CompositeExpression) {
      final children = expression.expressions
          .map((child) => expressionToLogic(child, questions: questions, context: context))
          .whereType<Map<String, dynamic>>()
          .toList();
      if (children.isEmpty) return null;

      // V2 Format: Flatten single-condition composites for cleaner schema
      if (children.length == 1 && context != null) {
        return children[0];
      }

      // V1 Format or multi-condition: Keep wrapped
      return {expression.logicType == LogicType.and ? 'all' : 'any': children};
    }

    if (expression is NotExpression) {
      final child = expressionToLogic(
        expression.expression,
        questions: questions,
        context: context,
      );
      if (child == null) return null;
      return {'not': child};
    }

    if (expression is ValueExpression) {
      return valueExpressionToRule(expression, questions: questions, context: context);
    }

    return null;
  }

  static Map<String, dynamic>? valueExpressionToRule(
    ValueExpression expression, {
    required List<Question> questions,
    ExportContext? context,
  }) {
    final targetId = expression.target;
    if (targetId == null) return null;

    final question = questions.firstWhereOrNull((q) => q.id == targetId);
    if (question?.prompt == null) return null;

    // Get schema-local ID for the question
    final questionSchemaId = context?.getQuestionSchemaId(targetId);

    if (expression is BooleanExpression) {
      return {
        if (questionSchemaId != null) 'questionId': questionSchemaId,
        'questionPrompt': question!.prompt,
        'operator': 'isTrue',
      };
    }

    if (expression is ChoiceExpression) {
      if (question is BooleanQuestion) {
        if (expression.choices.contains(true) &&
            expression.choices.contains(false)) {
          return {
            if (questionSchemaId != null) 'questionId': questionSchemaId,
            'questionPrompt': question.prompt,
            'operator': 'exists',
          };
        }
        if (expression.choices.contains(true)) {
          return {
            if (questionSchemaId != null) 'questionId': questionSchemaId,
            'questionPrompt': question.prompt,
            'operator': 'isTrue',
          };
        }
        if (expression.choices.contains(false)) {
          return {
            if (questionSchemaId != null) 'questionId': questionSchemaId,
            'questionPrompt': question.prompt,
            'operator': 'isFalse',
          };
        }
      }

      if (question is ChoiceQuestion) {
        final choiceTexts = <String>[];
        final choiceIds = <String>[];

        for (final choiceId in expression.choices) {
          final choice = question.choices.firstWhereOrNull((c) => c.id == choiceId);
          if (choice != null) {
            choiceTexts.add(choice.text);
            final choiceSchemaId = context?.getChoiceSchemaId(choiceId as String);
            if (choiceSchemaId != null) {
              choiceIds.add(choiceSchemaId);
            }
          }
        }

        return {
          if (questionSchemaId != null) 'questionId': questionSchemaId,
          'questionPrompt': question.prompt,
          'operator': 'includesAny',
          if (choiceIds.isNotEmpty) 'choiceIds': choiceIds,
          'choiceTexts': choiceTexts,
        };
      }

      return {
        if (questionSchemaId != null) 'questionId': questionSchemaId,
        'questionPrompt': question!.prompt,
        'operator': 'includesAny',
        'value': expression.choices.toList(),
      };
    }

    if (expression is NumericExpression) {
      return {
        if (questionSchemaId != null) 'questionId': questionSchemaId,
        'questionPrompt': question!.prompt,
        'operator': numericComparatorToOperator(expression.comparator),
        'value': expression.value,
      };
    }

    if (expression is TextExpression) {
      return {
        if (questionSchemaId != null) 'questionId': questionSchemaId,
        'questionPrompt': question!.prompt,
        'operator': textComparatorToOperator(expression.comparator),
        'value': expression.value,
      };
    }

    return {
      if (questionSchemaId != null) 'questionId': questionSchemaId,
      'questionPrompt': question!.prompt,
      'operator': 'exists',
    };
  }

  static String numericComparatorToOperator(NumericComparator comparator) {
    return switch (comparator) {
      NumericComparator.equal => 'eq',
      NumericComparator.notEqual => 'neq',
      NumericComparator.greaterThan => 'gt',
      NumericComparator.lessThan => 'lt',
      NumericComparator.greaterThanOrEqual => 'gte',
      NumericComparator.lessThanOrEqual => 'lte',
    };
  }

  static String textComparatorToOperator(TextComparator comparator) {
    return switch (comparator) {
      TextComparator.equal => 'eq',
      TextComparator.notEqual => 'neq',
      TextComparator.contains => 'contains',
      TextComparator.doesNotContain => 'notContains',
    };
  }

  static Expression? logicToExpressionWithNaturalLanguage(
    Map<String, dynamic> logic,
    ImportContext context,
  ) {
    // For backward compatibility, flatten complex logic to simple ValueExpression
    // This ensures compatibility with original dev branch
    if (logic.containsKey('all')) {
      final conditions = logic['all'] as List;
      if (conditions.isNotEmpty) {
        // Use only the first condition to maintain compatibility
        return logicToExpressionWithNaturalLanguage(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    if (logic.containsKey('any')) {
      final conditions = logic['any'] as List;
      if (conditions.isNotEmpty) {
        // Use only the first condition to maintain compatibility
        return logicToExpressionWithNaturalLanguage(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    if (logic.containsKey('not')) {
      // For 'not' conditions, we need to flip the operator to maintain compatibility
      final innerLogic = logic['not'] as Map<String, dynamic>;
      final flippedLogic = Map<String, dynamic>.from(innerLogic);

      // Flip common operators to avoid NotExpression
      if (flippedLogic.containsKey('operator')) {
        final operator = flippedLogic['operator'] as String;
        switch (operator) {
          case 'eq':
            flippedLogic['operator'] = 'neq';
          case 'neq':
            flippedLogic['operator'] = 'eq';
          case 'isTrue':
            flippedLogic['operator'] = 'isFalse';
          case 'isFalse':
            flippedLogic['operator'] = 'isTrue';
          default:
            return null;
        }
      }

      return logicToExpressionWithNaturalLanguage(flippedLogic, context);
    }

    final questionPrompt = logic['question'] as String?;
    if (questionPrompt == null) return null;

    final question = context.findQuestionByPrompt(questionPrompt);
    if (question == null) return null;

    final operator = (logic['operator'] as String? ?? 'eq').trim();
    final value = logic['value'];

    switch (operator) {
      case 'isTrue':
        final expression = BooleanExpression()..target = question.id;
        return expression;
      case 'isFalse':
        // For backward compatibility, represent 'isFalse' as 'isTrue' with inverted logic
        // Since we can't use NotExpression, return null to skip this condition
        return null;
      case 'includesAny':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map(
                (choiceText) =>
                    context.findChoiceId(questionPrompt, choiceText.toString()),
              )
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
      case 'eq':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map(
                (choiceText) =>
                    context.findChoiceId(questionPrompt, choiceText.toString()),
              )
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
      case 'neq':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map(
                (choiceText) =>
                    context.findChoiceId(questionPrompt, choiceText.toString()),
              )
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        final notExpression = NotExpression();
        notExpression.expression = exp;
        return notExpression;
      case 'gt':
        return NumericExpression(
          comparator: NumericComparator.greaterThan,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'gte':
        return NumericExpression(
          comparator: NumericComparator.greaterThanOrEqual,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'lt':
        return NumericExpression(
          comparator: NumericComparator.lessThan,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'lte':
        return NumericExpression(
          comparator: NumericComparator.lessThanOrEqual,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'contains':
        return TextExpression(
          comparator: TextComparator.contains,
          value: value?.toString() ?? '',
        )..target = question.id;
      case 'notContains':
        return TextExpression(
          comparator: TextComparator.doesNotContain,
          value: value?.toString() ?? '',
        )..target = question.id;
      default:
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map(
                (choiceText) =>
                    context.findChoiceId(questionPrompt, choiceText.toString()),
              )
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
    }
  }

  static List<Expression> extractIndividualExpressions(
    Map<String, dynamic> logic,
    ImportContext context,
  ) {
    final expression = logicToExpressionWithNaturalLanguage(logic, context);
    if (expression == null) return [];

    if (expression is CompositeExpression &&
        expression.logicType == LogicType.and) {
      return expression.expressions
          .expand(
            (expr) =>
                expr is CompositeExpression && expr.logicType == LogicType.and
                ? expr.expressions
                : [expr],
          )
          .toList();
    }

    return [expression];
  }
}
