import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../texts.dart';
import '../widgets.dart';
import 'result_screen.dart';

/// Simulazione d'esame: si procede sempre in avanti, senza tornare indietro,
/// senza saltare domande e senza segnalibri. Il tempo scorre anche se si esce.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.session});

  final ExamSession session;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  late final ExamSession s = widget.session;
  Timer? _timer;
  bool _finishing = false;
  late int _remaining = s.remainingMs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (_remaining <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish(timeout: true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    if (_finishing || !mounted) return;
    final r = s.remainingMs;
    if (r <= 0) {
      _finish(timeout: true);
    } else {
      setState(() => _remaining = r);
    }
  }

  void _finish({bool timeout = false}) {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final nav = Navigator.of(context);
    final result = store.finishExam(s, bank);
    // Chiude anche eventuali finestre di dialogo aperte, poi mostra il risultato.
    nav.popUntil((r) => r.isFirst);
    nav.push(MaterialPageRoute(
      builder: (_) => ResultScreen(result: result, timedOut: timeout),
    ));
  }

  Future<void> _confirmFinish() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Consegnare la simulazione?'),
        content: const Text('Dopo la consegna non potrai più modificare le risposte.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annulla')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Consegna')),
        ],
      ),
    );
    if (go == true && mounted) _finish();
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uscire dalla simulazione?'),
        content: const Text(
            'Il tempo continua a scorrere. Potrai riprendere la simulazione '
            'dalla schermata iniziale finché non scade.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Continua')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Esci')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  void _select(int orig) {
    setState(() => s.answers[s.current] = orig);
    store.saveExam();
  }

  void _next() {
    if (s.current + 1 >= s.questionIds.length) {
      _confirmFinish();
      return;
    }
    setState(() => s.current++);
    store.saveExam();
  }

  @override
  Widget build(BuildContext context) {
    final i = s.current;
    final n = s.questionIds.length;
    final q = bank.byId[s.questionIds[i]]!;
    final sel = s.answers[i] == -1 ? null : s.answers[i];
    final low = _remaining < 5 * 60 * 1000;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.close), onPressed: _confirmExit),
          title: Text('Domanda ${i + 1} / $n'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: low ? Colors.red.shade100 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined,
                    size: 18, color: low ? Colors.red.shade800 : null),
                const SizedBox(width: 4),
                Text(fmtDuration(_remaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: low ? Colors.red.shade800 : null,
                    )),
              ]),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: (i + 1) / n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionCard(
                  key: ValueKey(q.id),
                  q: q,
                  order: s.optionOrders[i],
                  selected: sel,
                  reveal: false,
                  onSelect: _select,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: sel == null ? null : _next,
                    child: Text(i + 1 < n ? 'Avanti' : 'Termina simulazione'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
