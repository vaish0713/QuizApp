import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String answerText;
  final Color? answerColor;
  final bool? isCorrect;
  final bool? isSelected;  // Add this property
  final void Function() answerTap;

  Answer({
    required this.answerText,
    required this.answerColor,
    required this.answerTap,
    this.isCorrect,
    this.isSelected,  // Initialize isSelected property
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: answerTap,
      child: Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected == true
              ? (isCorrect == true ? Colors.green : Colors.red)
              : answerColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected == true
                ? (isCorrect == true ? Colors.green : Colors.red)
                : Colors.black,
          ),
        ),
        child: Center(
          child: Text(
            answerText,
            style: TextStyle(
              color: isSelected == true
                  ? Colors.white
                  : (isCorrect == false ? Colors.black : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
