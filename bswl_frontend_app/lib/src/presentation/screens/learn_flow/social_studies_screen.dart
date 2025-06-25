// lib/src/presentation/screens/learn_flow/social_studies_screen.dart
import 'package:flutter/material.dart';
import './subject_screen.dart';

class SocialStudiesScreen extends StatelessWidget {
  const SocialStudiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubjectPage(
      subjectName: "Social Studies",
      subjectIcon: "social_icon",
    );
  }
}