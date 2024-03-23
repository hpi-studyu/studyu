// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_core/core.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarOverview extends StatefulWidget {
  final StudySubject? subject;

  const CalendarOverview({required this.subject, super.key});

  @override
  _CalendarOverviewState createState() => _CalendarOverviewState();
}

class _CalendarOverviewState extends State<CalendarOverview> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // init
  @override
  void initState() {
    super.initState();
    // _calendarFormat = CalendarFormat.month;
  }

  int _dayOfYear(DateTime date) {
    return normalizeDate(date)
            .difference(DateTime.utc(date.year, 1, 1))
            .inDays +
        1;
  }

  @override
  Widget build(BuildContext context) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
    final List<List<Color>> colorScheme = [
      [
        const Color.fromRGBO(15, 174, 40, 1),
        const Color.fromRGBO(176, 255, 189, 1)
      ],
      [
        const Color.fromRGBO(92, 54, 173, 1),
        const Color.fromRGBO(211, 191, 255, 1)
      ],
      [
        const Color.fromRGBO(173, 73, 208, 1),
        const Color.fromRGBO(237, 186, 255, 1)
      ],
      [
        const Color.fromRGBO(222, 183, 45, 1),
        const Color.fromRGBO(255, 239, 181, 1)
      ]
    ];

    final schedule = widget.subject?.study.mp23Schedule;
    if (schedule == null) {
      throw Exception('Something went wrong, we need a schedule here');
    }

    final interventions = widget.subject!.study.mp23Schedule.interventions;
    final segments = widget.subject!.study.mp23Schedule.segments;

    // function for building
// BuildContext, DateTime, DateTime
    Widget buildCalendarDay(
        BuildContext context, DateTime day, DateTime focusedDay,
        [bool today = false]) {
      final text = DateFormat.d().format(day);

      DateTime studyStartDay = widget.subject!.startedAt ?? DateTime.now();

      studyStartDay = studyStartDay.add(const Duration(days: 1));

      final nthDay = _dayOfYear(day) - _dayOfYear(studyStartDay);

      StudyScheduleSegment? segment;

      try {
        segment = schedule.getSegmentForDay(nthDay).$1;
      } catch (e) {
        print(e);
      }

      List<Color> colors = [
        const Color.fromARGB(0, 0, 0, 0),
        today ? Colors.blue[600]! : Colors.grey[400]!
      ];

      // gradient
      Gradient? gradient;

      if (segment is BaselineScheduleSegment) {
        colors = [Color.fromARGB(255, 228, 228, 228), Colors.black];
      } else if (segment is ThompsonSamplingScheduleSegment) {
        colors = [Colors.white, Colors.white];
        List<Color> gradientColors = [];

        for (int i = 0; i < schedule.interventions.length; i++) {
          gradientColors.add(colorScheme[i % colorScheme.length][0]);
        }

        gradient = LinearGradient(
            colors: gradientColors, transform: const GradientRotation(1));
      } else if (segment is AlternatingScheduleSegment) {
        colors = colorScheme[0];
        final interventionOnDay = schedule.getInterventionForDay(nthDay);

        if (interventionOnDay != null) {
          final index = schedule.interventions.indexOf(interventionOnDay);
          colors = colorScheme[index % colorScheme.length];
        }
      }

      final decoration = gradient != null
          ? BoxDecoration(
              gradient: gradient,
              shape: today ? BoxShape.circle : BoxShape.rectangle,
            )
          : BoxDecoration(
              color: colors[0],
              shape: today ? BoxShape.circle : BoxShape.rectangle,
            );

      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                  decoration: decoration,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(color: colors[1]),
                      ),
                    ),
                  ))));
    }

    // init
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(titleCentered: true),
            // calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarBuilders: CalendarBuilders(
              selectedBuilder: buildCalendarDay,
              todayBuilder: (context, day, focusedDay) =>
                  buildCalendarDay(context, day, focusedDay, true),
              defaultBuilder: buildCalendarDay,
              outsideBuilder: (context, day, focusedDay) {
                final text = DateFormat.d().format(day);

                return Center(
                  child: Text(
                    text,
                    style: const TextStyle(color: Color.fromARGB(0, 0, 0, 0)),
                  ),
                );
              },
            ),
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
          ),
          if (segments.any((s) => s is BaselineScheduleSegment))
            const Label(
              color: Color.fromARGB(255, 228, 228, 228),
              text: "Baseline",
              // borderColor: Colors.grey,
            ),
          for (int i = 0; i < interventions.length; i++)
            Label(
                color: colorScheme[i % colorScheme.length][0],
                text: interventions[i].name ?? ''),
        ],
      ),
    );
  }
}

// class for rendering labels

class Label extends StatelessWidget {
  final String text;
  final Color color;
  final Color? borderColor;

  const Label(
      {required this.text, required this.color, this.borderColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: borderColor != null
                      ? Border.all(color: borderColor!, width: 1)
                      : null)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
