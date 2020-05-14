import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarRow extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double height;
  final Function onDatePressed;
  final Function getProgress;

  const CalendarRow({Key key, @required this.startDate, @required this.endDate, @required this.height, this.onDatePressed, this.getProgress}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<CalendarRow> {
  List<List<DateTime>> _cycles;
  int _selectedCycle;
  DayTile selectedTile;

  @override
  void initState() {
    _cycles = getCycles(widget.startDate, widget.endDate);
    var today = DateTime.now();
    _selectedCycle = _cycles.indexWhere((element) => element.first.difference(today).inDays <= 0 && element.last.difference(today).inDays >= 0);
    print(_selectedCycle);
    super.initState();
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
        padding: EdgeInsets.only(top: widget.height/10, bottom: widget.height/10),
        child: Row(
          children: <Widget> [
          SizedBox(
          width: spacing,
        ),
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: days.length,
              itemBuilder: (_context, i) {
                var date = days[i];
                var tile = DayTile(
                  date: date,
                  selected: selectedTile?.date == date,
                );
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTile = tile;
                    });
                    widget.onDatePressed(date);
                  },
                  child: tile,
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
                  onTap: () => setState((){_selectedCycle = i;}),
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
  final bool selected;
  final Function getData;

  const DayTile({Key key, @required this.date, this.selected, this.getData}) : super(key: key);

  @override
  State<DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<DayTile> {
  final Random random = Random();

  bool selected;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, innerConstraints) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    color: selected == true ? Colors.green[300] : Colors.grey[300],
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
