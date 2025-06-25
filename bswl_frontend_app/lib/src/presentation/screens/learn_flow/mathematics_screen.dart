// lib/src/presentation/screens/learn_flow/mathematics_screen.dart
import 'package:flutter/material.dart';
import './subject_screen.dart';

class MathematicsScreen extends StatelessWidget {
  const MathematicsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubjectPage(
      subjectName: "Mathematics",
      subjectIcon: "math_icon",
    );
  }
}