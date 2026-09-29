import 'package:flutter/material.dart';
import '../models.dart';
import '../state.dart';
import '../texts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Informazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(appName, style: Theme.of(context).textTheme.titleLarge),
          Text('Versione $appVersion · ${bank.questions.length} domande · '
              'simulazione: $examSize domande, $examMinutes minuti, '
              'superata con almeno $passMark corrette'),
          const SizedBox(height: 20),
          Text('Avviso importante', style: h),
          const SizedBox(height: 8),
          const Text(kDisclaimer),
          const SizedBox(height: 20),
          Text('Licenza', style: h),
          const SizedBox(height: 8),
          const Text(kLicenseNote),
        ],
      ),
    );
  }
}
