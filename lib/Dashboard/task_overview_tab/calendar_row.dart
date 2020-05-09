import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarRow extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int itemsAtOnce;
  final Function onDatePressed;

  const CalendarRow({Key key, this.startDate, this.endDate, this.itemsAtOnce = 5, this.onDatePressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<CalendarRow> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final spacing = constraints.maxWidth / 50;
      final itemSize = (constraints.maxWidth - (widget.itemsAtOnce - 1) * spacing) / widget.itemsAtOnce;
      return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          height: itemSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.endDate.difference(widget.startDate).inDays + 1,
            itemBuilder: (_context, i) {
              return DayTile(
                date: widget.startDate.add(Duration(days: i)),
                selected: false,
                itemSize: itemSize,
                onPressed: widget.onDatePressed,
              );
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
  final double itemSize;
  final Function onPressed;

  const DayTile({Key key, this.date, this.selected, this.itemSize, this.onPressed}) : super(key: key);

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

  void toggleSelect() {
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggleSelect();
        widget.onPressed(widget.date);
      },
      child: Container(
        color: selected == true ? Colors.green : null,
        width: widget.itemSize,
        child: LayoutBuilder(builder: (context, innerConstraints) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(innerConstraints.maxWidth / 20),
                child: FittedBox(
                  child: Center(
                    child: CircularProgressIndicator(
                      value: random.nextDouble(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(innerConstraints.maxWidth / 5),
                child: FittedBox(
                  child: Center(
                    child: Text((widget.date.day < 10 ? '0' : '') + widget.date.day.toString()),
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
