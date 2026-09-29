import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'rotation.dart';

/// Salvataggio locale: nessun dato lascia il dispositivo.
class Store {
  Store._(this._p);
  final SharedPreferences _p;

  bool disclaimerOk = false;
  final Set<int> mistakes = {};

  /// id domanda -> [tentativi, corrette]
  final Map<int, List<int>> stats = {};
  final List<Map<String, dynamic>> history = [];
  Rotation? rotation;
  int completedRounds = 0;
  ExamSession? exam;

  static Future<Store> open() async {
    final s = Store._(await SharedPreferences.getInstance());
    s._load();
    return s;
  }

  void _load() {
    disclaimerOk = _p.getBool('disclaimer_ok') ?? false;
    mistakes
      ..clear()
      ..addAll((_p.getStringList('mistakes') ?? []).map(int.parse));
    completedRounds = _p.getInt('completed_rounds') ?? 0;
    try {
      final st = _p.getString('stats');
      if (st != null) {
        (jsonDecode(st) as Map<String, dynamic>).forEach((k, v) {
          stats[int.parse(k)] = (v as List).cast<int>().toList();
        });
      }
      final h = _p.getString('history');
      if (h != null) {
        history.addAll(
            (jsonDecode(h) as List).map((e) => (e as Map).cast<String, dynamic>()));
      }
      final r = _p.getString('rotation');
      if (r != null) {
        rotation = Rotation.fromJson(jsonDecode(r) as Map<String, dynamic>);
      }
      final e = _p.getString('exam');
      if (e != null) {
        exam = ExamSession.fromJson(jsonDecode(e) as Map<String, dynamic>);
      }
    } catch (_) {
      // Dati danneggiati: si riparte da zero per la parte non leggibile.
      rotation = null;
      exam = null;
    }
  }

  void setDisclaimerOk() {
    disclaimerOk = true;
    _p.setBool('disclaimer_ok', true);
  }

  // ---- Errori e statistiche (indipendenti dalla rotazione) ----

  void recordAnswer(int id, bool correct, {bool save = true}) {
    final s = stats.putIfAbsent(id, () => [0, 0]);
    s[0]++;
    if (correct) {
      s[1]++;
      mistakes.remove(id);
    } else {
      mistakes.add(id);
    }
    if (save) saveProgress();
  }

  void saveProgress() {
    _p.setStringList('mistakes', mistakes.map((e) => '$e').toList());
    _p.setString(
        'stats', jsonEncode(stats.map((k, v) => MapEntry('$k', v))));
  }

  // ---- Rotazione delle simulazioni ----

  Rotation ensureRotation(QuestionBank bank) {
    var r = rotation;
    if (r == null || r.complete) {
      r = Rotation.generate(bank, (r?.round ?? completedRounds) + 1, Random());
      rotation = r;
      _saveRotation();
    }
    return r;
  }

  void _saveRotation() {
    _p.setString('rotation', jsonEncode(rotation!.toJson()));
    _p.setInt('completed_rounds', completedRounds);
  }

  ExamSession startExam(QuestionBank bank) {
    final rnd = Random();
    final r = ensureRotation(bank);
    final open = [
      for (var i = 0; i < r.used.length; i++)
        if (!r.used[i]) i
    ];
    final idx = open[rnd.nextInt(open.length)];
    final ids = List<int>.from(r.exams[idx])..shuffle(rnd);
    final orders = ids.map((_) => [0, 1, 2]..shuffle(rnd)).toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    final s = ExamSession(
      round: r.round,
      examIndex: idx,
      questionIds: ids,
      optionOrders: orders,
      answers: List.filled(ids.length, -1),
      current: 0,
      startMs: now,
      endMs: now + examMinutes * 60 * 1000,
    );
    exam = s;
    saveExam();
    return s;
  }

  void saveExam() {
    final e = exam;
    if (e == null) {
      _p.remove('exam');
    } else {
      _p.setString('exam', jsonEncode(e.toJson()));
    }
  }

  /// Chiude la simulazione: calcola il risultato, aggiorna errori,
  /// storico e rotazione.
  ExamResult finishExam(ExamSession s, QuestionBank bank) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final secs = ((min(nowMs, s.endMs) - s.startMs) / 1000).round();
    var score = 0;
    final sec = <String, List<int>>{};
    final wrong = <WrongAnswer>[];
    for (var i = 0; i < s.questionIds.length; i++) {
      final q = bank.byId[s.questionIds[i]]!;
      final chosen = s.answers[i];
      final ok = chosen == q.correct;
      final sc = sec.putIfAbsent(q.section, () => [0, 0]);
      sc[1]++;
      if (ok) {
        score++;
        sc[0]++;
      } else {
        wrong.add(WrongAnswer(q.id, chosen));
      }
      if (chosen != -1) recordAnswer(q.id, ok, save: false);
    }
    saveProgress();
    final result = ExamResult(
      score: score,
      total: s.questionIds.length,
      secs: secs,
      round: s.round,
      examNumber: s.examIndex + 1,
      sections: sec,
      wrong: wrong,
    );
    history.insert(0, {
      't': nowMs,
      'score': score,
      'total': s.questionIds.length,
      'passed': result.passed,
      'secs': secs,
      'round': s.round,
    });
    if (history.length > 50) history.removeRange(50, history.length);
    _p.setString('history', jsonEncode(history));

    final r = rotation;
    if (r != null && r.round == s.round && !r.used[s.examIndex]) {
      r.used[s.examIndex] = true;
      if (r.complete) {
        completedRounds++;
        rotation = Rotation.generate(bank, r.round + 1, Random());
      }
      _saveRotation();
    }
    exam = null;
    saveExam();
    return result;
  }

  Future<void> resetAll() async {
    mistakes.clear();
    stats.clear();
    history.clear();
    rotation = null;
    exam = null;
    completedRounds = 0;
    for (final k in [
      'mistakes',
      'stats',
      'history',
      'rotation',
      'exam',
      'completed_rounds'
    ]) {
      await _p.remove(k);
    }
  }
}
