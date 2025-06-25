// lib/src/presentation/screens/learn_flow/english_screen.dart
import 'package:flutter/material.dart';
import './subject_screen.dart';

class EnglishScreen extends StatelessWidget {
  const EnglishScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubjectPage(
      subjectName: "English",
      subjectIcon: "english_icon",
    );
  }
}