// Quiz SaNa ITA (inofficiale) - Copyright (C) 2026 gli autori
// Software libero: GNU GPL v3 o successiva. Nessuna garanzia. Vedi il file LICENSE.
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const int examSize = 50;
const int passMark = 40;
const int examMinutes = 60;

class Question {
  Question({
    required this.id,
    required this.section,
    required this.subsection,
    required this.text,
    required this.options,
    required this.correct,
    this.image,
  });

  final int id;
  final String section;
  final String subsection;
  final String text;
  final List<String> options;
  final int correct;
  final String? image;

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as int,
        section: j['section'] as String,
        subsection: j['subsection'] as String,
        text: j['text'] as String,
        options: (j['options'] as List).cast<String>(),
        correct: j['correct'] as int,
        image: j['image'] as String?,
      );
}

class QuestionBank {
  QuestionBank(this.sections, this.questions)
      : byId = {for (final q in questions) q.id: q};

  final Map<String, String> sections;
  final List<Question> questions;
  final Map<int, Question> byId;

  static Future<QuestionBank> load() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return QuestionBank(
      (j['sections'] as Map).cast<String, String>(),
      (j['questions'] as List)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Simulazione d'esame in corso (salvata a ogni risposta).
class ExamSession {
  ExamSession({
    required this.round,
    required this.examIndex,
    required this.questionIds,
    required this.optionOrders,
    required this.answers,
    required this.current,
    required this.startMs,
    required this.endMs,
  });

  final int round;
  final int examIndex;
  final List<int> questionIds;

  /// Per ogni domanda: ordine di visualizzazione delle opzioni (indici originali).
  final List<List<int>> optionOrders;

  /// Per ogni domanda: indice originale dell'opzione scelta, oppure -1.
  final List<int> answers;
  int current;
  final int startMs;
  final int endMs;

  int get remainingMs => endMs - DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'round': round,
        'examIndex': examIndex,
        'questionIds': questionIds,
        'optionOrders': optionOrders,
        'answers': answers,
        'current': current,
        'startMs': startMs,
        'endMs': endMs,
      };

  factory ExamSession.fromJson(Map<String, dynamic> j) => ExamSession(
        round: j['round'] as int,
        examIndex: j['examIndex'] as int,
        questionIds: (j['questionIds'] as List).cast<int>(),
        optionOrders: (j['optionOrders'] as List)
            .map((e) => (e as List).cast<int>())
            .toList(),
        answers: (j['answers'] as List).cast<int>(),
        current: j['current'] as int,
        startMs: j['startMs'] as int,
        endMs: j['endMs'] as int,
      );
}

class WrongAnswer {
  WrongAnswer(this.id, this.chosen);
  final int id;

  /// Indice originale dell'opzione scelta, -1 se senza risposta.
  final int chosen;
}

class ExamResult {
  ExamResult({
    required this.score,
    required this.total,
    required this.secs,
    required this.round,
    required this.examNumber,
    required this.sections,
    required this.wrong,
  });

  final int score;
  final int total;
  final int secs;
  final int round;
  final int examNumber;

  /// sezione -> [corrette, totali]
  final Map<String, List<int>> sections;
  final List<WrongAnswer> wrong;

  bool get passed => score >= passMark;
}
