import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/extensions.dart';
import 'task_overview.dart';

class CalendarRow extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double height;
  final Function getProgress;

  const CalendarRow({Key key, @required this.startDate, @required this.endDate, @required this.height, this.getProgress}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<CalendarRow> {
  List<List<DateTime>> _cycles;
  int _selectedCycle;

  @override
  void initState() {
    _cycles = getCycles(widget.startDate, widget.endDate);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var selected = Provider.of<TaskOverviewModel>(context, listen: false).selectedDate;
    _selectedCycle = selected != null ? _cycles.indexWhere((element) => element.first.difference(selected).inDays <= 0 && element.last.difference(selected).inDays >= 0) : 0;
    super.didChangeDependencies();
  }

  static List<List<DateTime>> getCycles(DateTime start, DateTime end) {
    if (start == null && end == null) {
      return null;
    }

    var cycles = <List<DateTime>>[
      []
    ];
    var timeLeft = end.difference(start).inDays;

    while (timeLeft > -1) {
      var currentDate = end.subtract(Duration(days: timeLeft));
      cycles.last.add(currentDate);
      if (currentDate.weekday == 7 && timeLeft > 0) {
        cycles.add([]);
      }
      timeLeft--;
    }

    return cycles;
  }

  Widget getCycleWidget(List<DateTime> days, double spacing) {
    return Container(
      color: Colors.red.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.only(top: widget.height / 10, bottom: widget.height / 10),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: spacing,
            ),
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: days.length,
              itemBuilder: (_context, i) {
                var date = days[i];
                return GestureDetector(
                  onTap: () {
                    Provider.of<TaskOverviewModel>(context, listen: false).setDate(date);
                  },
                  child: DayTile(
                    date: date,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: spacing,
                );
              },
            ),
            SizedBox(
              width: spacing,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final spacing = constraints.maxWidth / 50;
      final height = widget.height;
      return Container(
        height: height,
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cycles.length,
            itemBuilder: (_context, i) {
              if (i != _selectedCycle) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCycle = i;
                  }),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Container(
                      color: Colors.green,
                    ),
                  ),
                );
              } else {
                return getCycleWidget(_cycles[_selectedCycle], spacing);
              }
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                width: spacing,
              );
            },
          ),
        ),
      );
    });
  }
}

class DayTile extends StatefulWidget {
  final DateTime date;
  final Function getData;

  const DayTile({Key key, @required this.date, this.getData}) : super(key: key);

  @override
  State<DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<DayTile> {
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, innerConstraints) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Consumer<TaskOverviewModel>(
                builder: (context, taskOverviewModel, child) => ClipOval(
                  child: Container(
                    color: taskOverviewModel.selectedDate.isSameDate(widget.date) ? Colors.green[300] : Colors.grey[300],
                    child: Padding(
                      padding: EdgeInsets.all(innerConstraints.maxWidth / 5),
                      child: FittedBox(
                        child: Center(
                          child: Text((widget.date.day < 10 ? '0' : '') + widget.date.day.toString()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(innerConstraints.maxWidth / 20),
                child: FittedBox(
                  child: Center(
                    child: CircularProgressIndicator(
                      value: random.nextDouble(), //widget.getData != null ? widget.getData(widget.date) : null ?? 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
