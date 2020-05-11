import 'package:flutter/material.dart';

import '../../tasks/dashboard_task.dart';

class TaskBox extends StatefulWidget {
  final DashboardTask task;

  TaskBox(this.task);

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 150.0,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).secondaryHeaderColor,
              blurRadius: 20.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                5.0, // vertical, move down 10
              ),
            )
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.headline5,
                    )),
                Container(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    widget.task.description,
                  ),
                ),
                Spacer(),
                Center(
                  child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).secondaryHeaderColor,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => widget.task)),
                    child: Text('Complete!'),
                  ),
                )
              ],
            )));
  }
}
