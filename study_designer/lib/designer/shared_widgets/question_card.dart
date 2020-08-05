import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class QuestionCard extends StatefulWidget {
  final int index;
  final Question item;
  final bool isEditing;
  final void Function(int index) remove;
  final void Function(int index) onTap;
  final void Function(bool validated) setValidated;

  const QuestionCard(
      {@required this.index,
      @required this.item,
      @required this.isEditing,
      @required this.onTap,
      @required this.remove,
      @required this.setValidated,
      Key key})
      : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.index);
      },
      child: Card(margin: EdgeInsets.all(10.0), child: widget.isEditing ? _buildEditView() : _buildShowView()),
    );
  }

  Widget _buildEditView() {
    var questionBody = null();

    return Column(children: [
      ButtonBar(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              widget.remove(widget.index);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
      FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          // readonly: true,
          child: Column(children: <Widget>[
            FormBuilderTextField(
                validator: FormBuilderValidators.minLength(context, 3),
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'prompt',
                decoration: InputDecoration(labelText: 'Prompt'),
                initialValue: widget.item.prompt),
            FormBuilderTextField(
                validator: FormBuilderValidators.minLength(context, 3),
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'rationale',
                decoration: InputDecoration(labelText: 'Rationale'),
                initialValue: widget.item.rationale),
          ])),
    ]);
  }

  List<Widget> testtest() {
    return [
      FormBuilderTextField(
          validator: FormBuilderValidators.minLength(context, 3),
          onChanged: (value) {
            saveFormChanges();
          },
          attribute: 'rationale',
          decoration: InputDecoration(labelText: 'Rationale'),
          initialValue: widget.item.rationale),
      FormBuilderTextField(
          validator: FormBuilderValidators.minLength(context, 3),
          onChanged: (value) {
            saveFormChanges();
          },
          attribute: 'rationale',
          decoration: InputDecoration(labelText: 'Rationale'),
          initialValue: widget.item.rationale)
    ];
  }

  Widget _buildShowView() {
    return ListTile(title: Text(widget.item.prompt.isEmpty ? '*Click to edit*' : widget.item.prompt));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.item.prompt = _editFormKey.currentState.value['prompt'];
        widget.item.rationale = _editFormKey.currentState.value['rationale'];
      });
      widget.setValidated(true);
    } else {
      widget.setValidated(false);
    }
  }
}
