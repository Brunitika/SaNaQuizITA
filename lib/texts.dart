const String appName = 'Quiz SaNa ITA (inofficiale)';
const String appVersion = '1.0.0';

const String kDisclaimer =
    'Quiz SaNa ITA è un\'app indipendente e non ufficiale, realizzata a scopo di studio. '
    'Non è affiliata, approvata né sostenuta dalla Rete di formazione per pescatori '
    '(Netzwerk Anglerausbildung / Réseau de formation des pêcheurs), né da alcuna '
    'autorità federale o cantonale.\n\n'
    'Le 150 domande e le relative immagini provengono dal questionario pubblicato dalla '
    'Rete di formazione per pescatori (versione 07.2026) e restano di proprietà dei '
    'rispettivi titolari. Le risposte indicate nell\'app sono state determinate dagli '
    'autori dell\'app e potrebbero contenere errori: in caso di dubbio fanno fede il '
    'materiale del corso e le fonti ufficiali.\n\n'
    'Le norme sulla pesca variano da Cantone a Cantone: prima di pescare consulta sempre '
    'la regolamentazione cantonale in vigore. Superare le simulazioni di quest\'app non '
    'garantisce il superamento dell\'esame ufficiale per l\'attestato di competenza SaNa.\n\n'
    'L\'app non raccoglie né trasmette dati personali: progressi e statistiche restano '
    'solo sul tuo dispositivo e funzionano senza connessione a Internet.\n\n'
    'L\'app è software libero, distribuito con licenza GNU GPL versione 3 (o successiva), '
    'senza alcuna garanzia.';

const String kLicenseNote =
    'Quiz SaNa ITA (inofficiale)\n'
    'Copyright (C) 2026 gli autori dell\'app\n\n'
    'Questo programma è software libero: puoi ridistribuirlo e/o modificarlo secondo i '
    'termini della GNU General Public License pubblicata dalla Free Software Foundation, '
    'versione 3 della Licenza o (a tua scelta) qualsiasi versione successiva.\n\n'
    'Questo programma è distribuito nella speranza che sia utile, ma SENZA ALCUNA '
    'GARANZIA, nemmeno la garanzia implicita di COMMERCIABILITÀ o IDONEITÀ PER UNO SCOPO '
    'PARTICOLARE. Vedi la GNU General Public License per maggiori dettagli: '
    'https://www.gnu.org/licenses/gpl-3.0.html\n\n'
    'La licenza GPL riguarda il codice dell\'app. Le domande e le immagini del '
    'questionario non sono coperte dalla GPL e restano di proprietà dei rispettivi titolari.';

String fmtDuration(int ms) {
  final t = ms < 0 ? 0 : ms ~/ 1000;
  final m = (t ~/ 60).toString().padLeft(2, '0');
  final s = (t % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String fmtDate(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}
