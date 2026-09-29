import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../texts.dart';
import 'exam_screen.dart';
import 'info_screen.dart';
import 'stats_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!store.disclaimerOk && mounted) _showDisclaimer();
    });
  }

  Future<void> _showDisclaimer() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Avviso importante'),
          content: const SingleChildScrollView(child: Text(kDisclaimer)),
          actions: [
            FilledButton(
              onPressed: () {
                store.setDisclaimerOk();
                Navigator.of(ctx).pop();
              },
              child: const Text('Ho capito'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  Future<void> _startExam() async {
    final s = store.startExam(bank);
    await _open(ExamScreen(session: s));
  }

  @override
  Widget build(BuildContext context) {
    final running = store.exam;
    final expired = running != null && running.remainingMs <= 0;
    final r = store.ensureRotation(bank);
    final nMistakes = store.mistakes.length;

    return Scaffold(
      appBar: AppBar(title: const Text(appName, style: TextStyle(fontSize: 18))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (running != null)
            _ActionCard(
              icon: Icons.timer,
              color: Colors.orange.shade100,
              title: expired ? 'Simulazione scaduta' : 'Simulazione in corso',
              subtitle: expired
                  ? 'Il tempo è terminato: vedi il risultato.'
                  : 'Domanda ${running.current + 1} di ${running.questionIds.length}. '
                      'Il tempo continua a scorrere.',
              button: expired ? 'Vedi risultato' : 'Riprendi',
              onTap: () => _open(ExamScreen(session: running)),
            ),
          _ActionCard(
            icon: Icons.assignment_turned_in,
            title: 'Simulazione d\'esame',
            subtitle: '$examSize domande • $examMinutes minuti • '
                'superata con almeno $passMark risposte corrette.\n'
                'Giro ${r.round}: simulazione ${r.usedCount + 1} di 3.',
            button: 'Inizia simulazione',
            onTap: running != null ? null : _startExam,
          ),
          _ActionCard(
            icon: Icons.menu_book,
            title: 'Studio: tutte le domande',
            subtitle: 'Scorri le ${bank.questions.length} domande con la correzione '
                'immediata, in ordine o casuale.',
            button: 'Studia',
            onTap: () => _open(const StudySetupScreen()),
          ),
          _ActionCard(
            icon: Icons.replay,
            title: 'Ripasso errori',
            subtitle: nMistakes == 0
                ? 'Nessun errore da ripassare, per ora.'
                : '$nMistakes ${nMistakes == 1 ? 'domanda' : 'domande'} da ripassare. '
                    'Una risposta corretta la toglie dall\'elenco.',
            button: 'Ripassa',
            onTap: nMistakes == 0
                ? null
                : () {
                    final list = bank.questions
                        .where((q) => store.mistakes.contains(q.id))
                        .toList()
                      ..shuffle();
                    _open(StudyScreen(title: 'Ripasso errori', questions: list));
                  },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(const StatsScreen()),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Statistiche'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(const InfoScreen()),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Informazioni'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium)),
            ]),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(onPressed: onTap, child: Text(button)),
            ),
          ],
        ),
      ),
    );
  }
}
