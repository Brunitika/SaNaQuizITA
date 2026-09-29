# Quiz SaNa ITA (inofficiale)

App Android (Flutter/Dart) per prepararsi all'**attestato di competenza SaNa** (pesca, Svizzera), interamente in italiano e senza bisogno di connessione a Internet.

**Avviso:** app indipendente e **non ufficiale**, non affiliata alla Rete di formazione per pescatori (Netzwerk Anglerausbildung) né ad alcuna autorità. Le risposte sono state determinate dall'autore  dell'app (brunitika.ch) e possono contenere errori: in caso di dubbio fanno fede il materiale del corso e le fonti ufficiali. Le norme di pesca variano da Cantone a Cantone. Superare le simulazioni non garantisce di superare l'esame. Vedi la sezione [Disclaimer](#disclaimer).

## Funzioni

**Studio: tutte le domande**
- 150 domande, in ordine o in ordine casuale, con filtro per sezione (A–E).
- Correzione immediata dopo ogni risposta.

**Simulazione d'esame**
- 50 domande su 150, **60 minuti**, superata con **almeno 40 risposte corrette**.
- Si procede sempre in avanti senza la possibilità di ritornare indietro.
- Il timer si basa su un'ora di fine assoluta: resta corretto anche se il telefono si blocca o l'app viene
  chiusa. Una simulazione interrotta si può riprendere finché il tempo non scade; a 0:00 viene consegnata
  automaticamente (le domande senza risposta contano come errate).
- Risultato con punteggio, esito, tempo impiegato, punteggio per sezione ed elenco degli errori con la
  risposta corretta.

**Ripasso errori**
- Le domande sbagliate (in studio o in simulazione) finiscono nell'elenco degli errori.
  Una risposta corretta la toglie dall'elenco.
- Il tracciamento degli errori è indipendente dalla rotazione delle simulazioni.

**Statistiche**: storico delle simulazioni, percentuale di risposte corrette per sezione, stato della rotazione.

Le opzioni di risposta vengono mescolate a ogni presentazione. Tutti i dati restano sul dispositivo.

## Rotazione delle simulazioni

Per evitare una scelta puramente casuale (che potrebbe non mostrare mai alcune domande) le simulazioni funzionano a **giri**:

1. All'inizio di un giro le 150 domande vengono divise a caso in **3 simulazioni da 50**, in modo stratificato per sezione (ogni simulazione ha circa la stessa proporzione di domande per sezione).
2. Ogni volta che avvii una simulazione, ne viene estratta una delle non ancora completate; l'ordine delle domande e delle risposte è casuale.
3. Una simulazione conta come completata solo quando viene consegnata (o scade il tempo). Se esci prima, la stessa simulazione resta in corso e può essere ripresa.
4. Completate le 3 simulazioni, tutte le 150 domande sono state proposte esattamente una volta e parte un **nuovo giro con una nuova suddivisione casuale**: le simulazioni non sono mai "gli stessi 3 set".

## Compilare l'APK

Requisiti: [Flutter](https://docs.flutter.dev/get-started/install) (canale stable), JDK 17, Android SDK.

```bash
./setup.sh                        # crea la cartella android/ e imposta il nome dell'app
flutter pub get
flutter build apk --release       # APK in build/app/outputs/flutter-apk/app-release.apk
```
In alternativa, con GitHub: carica il progetto in un repository e avvia il workflow **Compila APK** (scheda *Actions*, oppure crea un tag `v1.0.0`); l'APK compare tra gli artefatti del workflow.

Note:
- L'APK di release è firmato con la chiave di debug e va bene per l'installazione diretta.
- Se `flutter build` segnala errori dovuti alla versione di Flutter, apri una segnalazione o correggi.

Sotto "releases" (colonna a destra) potrai altrimenti scaricare direttamente l'applicazione compilata (app-release.apk). Aprendo l'immagine cliccandoci sopra e accettando l'installazione di software da parte di terzi potrai installare direttamente l'app (CAVE: ricevererai probabilmente una notifica che non è sicuro in quanto software di terze parti non riconosciuto).

## Struttura

```
lib/
  main.dart             avvio dell'app, lingua italiana
  models.dart           domande, sessione d'esame, risultato
  rotation.dart         suddivisione in 3 simulazioni per giro
  store.dart            salvataggio locale (errori, statistiche, storico, rotazione)
  texts.dart            testi (disclaimer, licenza) e formattazione
  widgets.dart          scheda domanda con immagine e opzioni
  screens/              schermate: home, studio, simulazione, risultato, statistiche, info
assets/data/questions.json   le 150 domande con la chiave delle risposte
assets/images/               le 23 immagini delle domande (pesci, canne, mulinello, esche)
tools/extract_questions.py   ricostruisce il JSON e le immagini dal PDF del questionario
```

Formato di `questions.json`: per ogni domanda `id`, `section` (A–E), `subsection`, `text`, `options` (3 opzioni), `correct` (indice 0–2 dell'opzione corretta) e `image` (percorso o `null`). Per aggiornare le domande a una nuova versione del questionario: esegui `python3 tools/extract_questions.py NuovoQuestionario.pdf assets` (richiede `pip install pdfplumber pillow`) e aggiorna la chiave delle risposte `KEY` nello script.

## Licenza

Il **codice** dell'app è software libero, distribuito con licenza **GNU GPL versione 3**, vedi il file [`LICENSE`](LICENSE). Copyright (C) 2026 Bruno Minotti (brunitika.ch). Nessuna garanzia.

Le **domande e le immagini** del questionario (cartelle `assets/data` e `assets/images`) provengono dal questionario 07.2026 della Rete di formazione per pescatori e **non sono coperte dalla GPL**: restano di proprietà dei rispettivi titolari (https://www.formazione-pescatori.ch/). Le risposte corrette sono state determinate dall'autore dell'app.

## Disclaimer

Quiz SaNa ITA è un'app indipendente e non ufficiale, realizzata a scopo di studio. Non è affiliata, approvata né sostenuta dalla Rete di formazione per pescatori (Netzwerk Anglerausbildung / Réseau de
formation des pêcheurs) né da alcuna autorità federale o cantonale. Le risposte potrebbero contenere errori e le norme sulla pesca variano da Cantone a Cantone: consulta sempre la regolamentazione cantonale in vigore. L'app non raccoglie né trasmette dati personali. Il software è fornito senza alcuna garanzia, come previsto dalla GNU GPL v3. Claude.ai è stato utilizzato per produrre e correggere il codice sorgente.
