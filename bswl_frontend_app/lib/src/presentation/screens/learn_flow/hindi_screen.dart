// lib/src/presentation/screens/learn_flow/hindi_screen.dart
import 'package:flutter/material.dart';
import './subject_screen.dart';

class HindiScreen extends StatelessWidget {
  const HindiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubjectPage(
      subjectName: "Hindi",
      subjectIcon: "hindi_icon",
    );
  }
}