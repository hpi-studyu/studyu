import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:encrypted_media_capturing/take_picture_screen.dart';
import 'question_widget.dart';

class ImageCapturingQuestionWidget extends QuestionWidget {
  final ImageCapturingQuestion question;
  final Function(Answer)? onDone;

  const ImageCapturingQuestionWidget({Key? key, required this.question, this.onDone})
      : super(key: key);

  @override
  State<ImageCapturingQuestionWidget> createState() => _ImageCapturingQuestionWidgetState();
}

class _ImageCapturingQuestionWidgetState extends State<ImageCapturingQuestionWidget> {
  String text = "empty";


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var txt = TextEditingController();

    void setFilePath(){
      print(text);
      print(text.runtimeType);
      txt.text = text;
    }

    void getFilePath() async {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakePictureScreen(),
          ));

      setState(() {
        text = result;
        widget.onDone!(widget.question.constructAnswer(text!));
      });

      setFilePath();
    }

    return Column(
      children: [
        TextButton(onPressed: getFilePath, child: Text("Capture!")),
        TextField(controller: txt,),
      ],
    );
  }
}