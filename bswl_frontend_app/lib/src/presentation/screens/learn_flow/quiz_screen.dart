import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';
import '../../widgets/answer_card.dart';

class QuizPage extends StatefulWidget {
  final String lessonTitle;

  const QuizPage({Key? key, required this.lessonTitle}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answerSubmitted = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'answers': ['London', 'Paris', 'Berlin', 'Madrid'],
      'correct': 1
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'answers': ['Earth', 'Mars', 'Jupiter', 'Venus'],
      'correct': 1
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: "Practice: ${widget.lessonTitle}",
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: AppColors.primaryLight, // fixed: use primaryLight
                color: AppColors.accent,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                "Question ${_currentQuestion + 1}/${_questions.length}",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary, // fixed: use textSecondary
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ), // fixed: close parenthesis
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _questions[_currentQuestion]['question'],
                          style: Theme.of(context).textTheme.titleLarge, // fixed: headline6 -> titleLarge
                        ),
                        const SizedBox(height: 32),
                        ...List.generate(
                          _questions[_currentQuestion]['answers'].length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: AnswerCard(
                              answer: _questions[_currentQuestion]['answers'][index],
                              isSelected: _selectedAnswer == index,
                              isCorrect: _answerSubmitted &&
                                  index == _questions[_currentQuestion]['correct'],
                              isWrong: _answerSubmitted &&
                                  _selectedAnswer == index &&
                                  index != _questions[_currentQuestion]['correct'],
                              onTap: () {
                                if (!_answerSubmitted) {
                                  setState(() {
                                    _selectedAnswer = index;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_answerSubmitted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAnswer ==
                                        _questions[_currentQuestion]['correct']
                                    ? 'Correct!'
                                    : 'Incorrect',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedAnswer ==
                                          _questions[_currentQuestion]['correct']
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explanation: This is why this answer is correct',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_answerSubmitted && _selectedAnswer != null) {
                                setState(() => _answerSubmitted = true);
                              } else if (_answerSubmitted) {
                                setState(() {
                                  if (_currentQuestion < _questions.length - 1) {
                                    _currentQuestion++;
                                    _selectedAnswer = null;
                                    _answerSubmitted = false;
                                  } else {
                                    // Quiz completed
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent, // fixed: primary -> backgroundColor
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _answerSubmitted
                                  ? _currentQuestion < _questions.length - 1
                                      ? "Next Question"
                                      : "Finish Practice"
                                  : "Submit Answer",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
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