import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Answers.dart';
import 'Chart.dart';
import 'Storage.dart';

class Questions extends StatefulWidget {
  final String playerName;
  const Questions({Key? key, required this.playerName}) : super(key: key);

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  List<Icon> _scoreTracker = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool correctAnswerSelected = false;

  void _questionAnswered(bool answerScore) {
    setState(() {
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      if (answerScore) {
        _totalScore++;
        correctAnswerSelected = true;
      }
      // adding to the score tracker on top
      _scoreTracker.add(
        answerScore
            ? Icon(
          Icons.check_circle,
          color: Colors.green,
        )
            : Icon(
          Icons.clear,
          color: Colors.red,
        ),
      );
      //when the quiz ends
      if (_questionIndex + 1 == _questions.length) {
        endOfQuiz = true;
      }
    });
  }

  Future<bool> _handleBackButton() async {
    if (endOfQuiz) {
      // If the quiz is over, navigate to the appropriate page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BarGraphPage(
            numCorrectAnswers: _totalScore,
            numWrongAnswers: 3 - _totalScore,
          ),
        ),
      );
      _submitDataToFirestore();
      return false;
    } else {
      // Allow navigating back
      return true;
    }
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      answerWasSelected = false;
      correctAnswerSelected = false;
    });
    // what happens at the end of the quiz
    if (_questionIndex >= _questions.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarGraphPage(
            numCorrectAnswers: _totalScore,
            numWrongAnswers: 3-_totalScore,
          ),
        ),
      );
      _submitDataToFirestore();

    }
  }

  void _resetQuiz() async {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      _scoreTracker = [];
      endOfQuiz = false;
    });

    // Store player's name and score
    final playerScore = PlayerScore(widget.playerName, _totalScore);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('playerScore', jsonEncode(playerScore.toJson()));
  }

  void _submitDataToFirestore() async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('Submissions');

    // Assuming your data is stored in a Map or a class instance
    Map<String, dynamic> data = {
      'name': widget.playerName,
      'score': _totalScore,
    };

    await collectionReference.add(data);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child:Scaffold(
        appBar: AppBar(
          title: Text(
            'Quiz Page',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        body: Center(
          child: Column(
            children: [
              Text('Name: ${widget.playerName}'),
              Row(
                children: [
                  if (_scoreTracker.length == 0)
                    SizedBox(
                      height: 25.0,
                    ),
                  if (_scoreTracker.length > 0) ..._scoreTracker
                ],
              ),
              Container(
                width: double.infinity,
                height: 130.0,
                margin: EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    _questions[_questionIndex]['question'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...(_questions[_questionIndex]['answers']
              as List<Map<String, Object>>)
                  .map(
                    (answer) => Answer(
                  answerText: answer['answerText'] as String,
                  answerColor: answerWasSelected
                      ? answer['score'] != null
                      ? Colors.green
                      : Colors.red
                      : null,
                  answerTap: () {
                    // if answer was already selected then nothing happens onTap
                    if (answerWasSelected) {
                      return;
                    }
                    //answer is being selected
                    _questionAnswered(answer['score'] as bool);
                  },
                  isSelected: answerWasSelected &&
                      answer['score'] != null && // Check if the answer has a score
                      answer['score'] == false, // Check if the answer is selected and wrong
                  isCorrect: answer['score'] == true,
                ),
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(20.0, 40.0),
                ),
                onPressed: () {
                  if (!answerWasSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Please select an answer before going to the next question'),
                    ));
                    return;
                  }
                  _nextQuestion();
                },
                child: Text(endOfQuiz ? 'Submit' : 'Next Question'),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  '${_totalScore.toString()}/${_questions.length}',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                ),
              ),
              if (answerWasSelected && !endOfQuiz)
                Container(
                  height: 100,
                  width: double.infinity,
                  color: correctAnswerSelected ? Colors.green : Colors.red,
                  child: Center(
                    child: Text(
                      correctAnswerSelected
                          ? 'Well done, you got it right!'
                          : 'Wrong :/',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (endOfQuiz)
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      _totalScore > 4
                          ? 'Congratulations! Your final score is: $_totalScore'
                          : 'Your final score is: $_totalScore.',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: _totalScore > 4 ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<Map<String,dynamic>> _questions = [
  {
    'question': 'which is the fastest language?',
    'answers': [
      {'answerText': 'C++', 'score': true},
      {'answerText': 'Java', 'score': false},
      {'answerText': 'Python', 'score': false},
    ],
  },
  {
    'question':
    'Which is the oldest Language?',
    'answers': [
      {'answerText': 'Java', 'score': false},
      {'answerText': 'Python', 'score': false},
      {'answerText': 'C++', 'score': true},
    ],
  },
  {
    'question': 'Which language does not contain Pointers?',
    'answers': [
      {'answerText': 'C++', 'score': false},
      {'answerText': 'C', 'score': false},
      {'answerText': 'Java', 'score': true},
    ],
  },
];

class QuestionArguments {
  final String playerName;

  QuestionArguments({
    required this.playerName,
  });
}
