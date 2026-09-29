import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models.dart';
import 'screens/home_screen.dart';
import 'state.dart' as app;
import 'store.dart';
import 'texts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app.bank = await QuestionBank.load();
  app.store = await Store.open();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
