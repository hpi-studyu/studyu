import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/models/designer_state.dart';

class QuestionCard extends StatefulWidget {
  final int index;
  final bool isEditing;
  final void Function(int index) remove;
  final void Function(int index) onTap;
  final void Function(bool validated) setValidated;

  const QuestionCard(
      {@required this.index,
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
  LocalQuestion item;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    item = context.watch<DesignerModel>().draftStudy.studyDetails.eligibilityQuestionnaire[widget.index];

    return GestureDetector(
      onTap: () {
        widget.onTap(widget.index);
      },
      child: Card(margin: EdgeInsets.all(10.0), child: widget.isEditing ? _buildEditView() : _buildShowView()),
    );
  }

  Widget _buildEditView() {
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
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                  validator: FormBuilderValidators.minLength(context, 3),
                  onChanged: (value) {
                    saveFormChanges();
                  },
                  attribute: 'question',
                  decoration: InputDecoration(labelText: 'Question'),
                  initialValue: item.question),
            ],
          ))
    ]);
  }

  Widget _buildShowView() {
    return ListTile(title: Text(item.question.isEmpty ? '*Click to edit*' : item.question));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        item.question = _editFormKey.currentState.value['question'];
      });
      widget.setValidated(true);
    } else {
      widget.setValidated(false);
    }
  }
}
