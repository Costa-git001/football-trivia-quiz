import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/questions.dart';
import '../models/question.dart';

class QuestionService {
  QuestionService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  Future<List<Question>> loadQuestions() async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('questions')
          .where('isActive', isEqualTo: true)
          .get();

      final questions = snapshot.docs
          .map((document) => Question.fromFirestore(document.data()))
          .where(_isValidQuestion)
          .toList();

      if (questions.isNotEmpty) {
        return questions;
      }
    } catch (_) {
      // If Firebase is not configured yet, keep the app usable for learners.
    }

    return footballQuestions;
  }

  bool _isValidQuestion(Question question) {
    return question.text.trim().isNotEmpty &&
        question.options.length == 4 &&
        question.correctAnswerIndex >= 0 &&
        question.correctAnswerIndex < question.options.length;
  }
}
