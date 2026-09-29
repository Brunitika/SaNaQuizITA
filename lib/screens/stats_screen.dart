import 'package:flutter/material.dart';
import '../state.dart';
import '../texts.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Azzerare tutti i dati?'),
        content: const Text(
            'Verranno cancellati errori, statistiche, storico e stato della '
            'rotazione delle simulazioni. L\'operazione non si può annullare.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annulla')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Azzera')),
        ],
      ),
    );
    if (ok == true) {
      await store.resetAll();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = store.ensureRotation(bank);
    final secKeys = bank.sections.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rotazione delle simulazioni',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Giro corrente: ${r.round} '
                      '(${r.usedCount} di 3 simulazioni completate)'),
                  Text('Giri completati: ${store.completedRounds}'),
                  Text('Domande viste almeno una volta: '
                      '${store.stats.length} su ${bank.questions.length}'),
                  Text('Errori da ripassare: ${store.mistakes.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Risposte corrette per sezione',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final k in secKeys) _sectionBar(context, k),
          const SizedBox(height: 16),
          Text('Storico simulazioni',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (store.history.isEmpty)
            const Text('Nessuna simulazione completata.'),
          for (final h in store.history.take(20))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                h['passed'] == true ? Icons.check_circle : Icons.cancel,
                color: h['passed'] == true
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
              title: Text('${h['score']} / ${h['total']}'
                  ' · ${h['passed'] == true ? 'superata' : 'non superata'}'),
              subtitle: Text('${fmtDate(h['t'] as int)} · '
                  'tempo ${fmtDuration((h['secs'] as int) * 1000)}'),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Azzera tutti i dati'),
          ),
        ],
      ),
    );
  }

  Widget _sectionBar(BuildContext context, String key) {
    var att = 0, cor = 0;
    for (final q in bank.questions.where((q) => q.section == key)) {
      final s = store.stats[q.id];
      if (s != null) {
        att += s[0];
        cor += s[1];
      }
    }
    final pct = att == 0 ? 0.0 : cor / att;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$key. ${bank.sections[key]}'),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: LinearProgressIndicator(value: pct, minHeight: 8)),
            const SizedBox(width: 12),
            Text(att == 0 ? '—' : '${(pct * 100).round()}%  ($cor/$att)'),
          ]),
        ],
      ),
    );
  }
}
