import 'package:flutter/foundation.dart';  // Для DiagnosticableTreeMixin
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Добавлено для Riverpod DI

void main() {
  runApp(const ProviderScope(  // Обертка для глобального state (theme, auth config)
    child: FinanceApp(),  // Переименовано на FinanceApp для проекта
  ));
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kopim Finance',  // Название приложения
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Kopim Home'),  // Переименовано на HomeScreen
      // Добавьте localizationsDelegates для intl позже
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // Для diagnostic_describe_all_properties: Описание свойств
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;  // Пример локального состояния (позже заменить на Riverpod)

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',  // Const для оптимизации
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),  // Const
      ),
    );
  }
}