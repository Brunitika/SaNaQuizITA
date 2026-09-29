import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../texts.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, this.timedOut = false});

  final ExamResult result;
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final color = r.passed ? Colors.green.shade100 : Colors.red.shade100;
    final secKeys = r.sections.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Risultato')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(r.passed ? 'SUPERATA' : 'NON SUPERATA',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('${r.score} / ${r.total}',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text('Per superare servono almeno $passMark risposte corrette.'),
                  Text('Tempo impiegato: ${fmtDuration(r.secs * 1000)}'),
                  Text('Giro ${r.round} · simulazione ${r.examNumber} di 3'),
                  if (timedOut)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Tempo scaduto: le domande senza risposta contano come errate.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Risultato per sezione',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final k in secKeys)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('$k. ${bank.sections[k]}'),
              trailing: Text('${r.sections[k]![0]} / ${r.sections[k]![1]}'),
            ),
          const SizedBox(height: 16),
          Text(
              r.wrong.isEmpty
                  ? 'Nessun errore: ottimo lavoro!'
                  : 'Domande sbagliate o senza risposta (${r.wrong.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final w in r.wrong) _WrongTile(w),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Torna alla schermata iniziale'),
          ),
        ],
      ),
    );
  }
}

class _WrongTile extends StatelessWidget {
  const _WrongTile(this.w);
  final WrongAnswer w;

  @override
  Widget build(BuildContext context) {
    final q = bank.byId[w.id]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Domanda n. ${q.id}',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(q.text, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (q.image != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(4),
                color: Colors.white,
                constraints: const BoxConstraints(maxHeight: 120),
                width: double.infinity,
                child: Image.asset(q.image!, fit: BoxFit.contain),
              ),
            const SizedBox(height: 6),
            Text(
              w.chosen == -1
                  ? 'Nessuna risposta'
                  : 'La tua risposta: ${q.options[w.chosen]}',
              style: TextStyle(color: Colors.red.shade800),
            ),
            const SizedBox(height: 4),
            Text('Risposta corretta: ${q.options[q.correct]}',
                style: TextStyle(color: Colors.green.shade800)),
          ],
        ),
      ),
    );
  }
}
