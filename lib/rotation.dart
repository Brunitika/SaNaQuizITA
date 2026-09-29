import 'dart:math';
import 'models.dart';

/// Un "giro" divide tutte le 150 domande in 3 simulazioni da 50 domande.
/// Ogni giro usa una nuova suddivisione casuale (stratificata per sezione):
/// completate le 3 simulazioni, tutte le domande sono state proposte
/// esattamente una volta; poi si riparte con una suddivisione diversa.
class Rotation {
  Rotation({required this.round, required this.exams, required this.used});

  final int round;
  final List<List<int>> exams;
  final List<bool> used;

  int get usedCount => used.where((u) => u).length;
  bool get complete => usedCount == used.length;

  factory Rotation.generate(QuestionBank bank, int round, Random rnd) {
    final sections = bank.sections.keys.toList()..shuffle(rnd);
    final exams = List.generate(3, (_) => <int>[]);
    var p = rnd.nextInt(3);
    for (final s in sections) {
      final ids = bank.questions
          .where((q) => q.section == s)
          .map((q) => q.id)
          .toList()
        ..shuffle(rnd);
      for (final id in ids) {
        exams[p % 3].add(id);
        p++;
      }
    }
    return Rotation(round: round, exams: exams, used: [false, false, false]);
  }

  Map<String, dynamic> toJson() =>
      {'round': round, 'exams': exams, 'used': used};

  factory Rotation.fromJson(Map<String, dynamic> j) => Rotation(
        round: j['round'] as int,
        exams: (j['exams'] as List)
            .map((e) => (e as List).cast<int>().toList())
            .toList(),
        used: (j['used'] as List).cast<bool>().toList(),
      );
}
