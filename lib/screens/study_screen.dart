import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../widgets.dart';

/// Scelta di ordine e sezione prima di iniziare lo studio.
class StudySetupScreen extends StatefulWidget {
  const StudySetupScreen({super.key});

  @override
  State<StudySetupScreen> createState() => _StudySetupScreenState();
}

class _StudySetupScreenState extends State<StudySetupScreen> {
  bool _shuffle = false;
  String _section = '*';

  List<Question> get _list => bank.questions
      .where((q) => _section == '*' || q.section == _section)
      .toList();

  @override
  Widget build(BuildContext context) {
    final n = _list.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Ordine delle domande',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('In ordine')),
              ButtonSegment(value: true, label: Text('Casuale')),
            ],
            selected: {_shuffle},
            onSelectionChanged: (s) => setState(() => _shuffle = s.first),
          ),
          const SizedBox(height: 24),
          Text('Sezione', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _section,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                  value: '*',
                  child: Text('Tutte le sezioni (${bank.questions.length})')),
              for (final e in bank.sections.entries)
                DropdownMenuItem(
                  value: e.key,
                  child: Text('${e.key}. ${e.value}',
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _section = v ?? '*'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final list = _list;
              if (_shuffle) list.shuffle();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => StudyScreen(title: 'Studio', questions: list),
              ));
            },
            child: Text('Inizia ($n domande)'),
          ),
        ],
      ),
    );
  }
}

/// Sessione di studio: correzione immediata dopo ogni risposta.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.title, required this.questions});

  final String title;
  final List<Question> questions;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _rnd = Random();
  late final List<List<int>> _orders =
      widget.questions.map((_) => [0, 1, 2]..shuffle(_rnd)).toList();
  int _i = 0;
  int? _sel;
  int _correct = 0;

  Question get _q => widget.questions[_i];

  void _select(int orig) {
    if (_sel != null) return;
    final ok = orig == _q.correct;
    setState(() {
      _sel = orig;
      if (ok) _correct++;
    });
    store.recordAnswer(_q.id, ok);
  }

  Future<void> _next() async {
    if (_i + 1 < widget.questions.length) {
      setState(() {
        _i++;
        _sel = null;
      });
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Sessione terminata'),
        content: Text(
            'Risposte corrette: $_correct su ${widget.questions.length}.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Chiudi')),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    final n = widget.questions.length;
    final answered = _sel != null;
    final ok = answered && _sel == q.correct;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} · ${_i + 1} / $n')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_i + 1) / n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionCard(
                    key: ValueKey(q.id),
                    q: q,
                    order: _orders[_i],
                    selected: _sel,
                    reveal: answered,
                    onSelect: _select,
                    caption: 'Domanda n. ${q.id} · ${q.subsection}',
                  ),
                  if (answered)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        ok ? 'Risposta corretta!' : 'Risposta sbagliata.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ok ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: answered ? _next : null,
                  child: Text(_i + 1 < n ? 'Avanti' : 'Fine'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
