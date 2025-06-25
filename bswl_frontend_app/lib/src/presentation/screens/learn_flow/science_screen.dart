// lib/src/presentation/screens/learn_flow/science_screen.dart
import 'package:flutter/material.dart';
import './subject_screen.dart';

class ScienceScreen extends StatelessWidget {
  const ScienceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubjectPage(
      subjectName: "Science",
      subjectIcon: "science_icon",
    );
  }
}