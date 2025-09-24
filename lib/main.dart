// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // Для DiagnosticPropertiesBuilder и StringProperty
import 'core/di/injectors.dart'; // Импорт DI (сервисы, репозитории)
import 'core/config/app_config.dart'; // Импорт config providers (theme, auth, locale)
import 'package:firebase_core/firebase_core.dart';

// Глобальный провайдер для примера локального состояния (счётчик, заменяет setState)
final counterProvider = StateProvider<int>((ref) => 0); // Immutable, микро-оптимизация

void main() {
  runApp(const ProviderScope(  // Обертка для глобального state (theme, auth config)
    child: FinanceApp(),  // FinanceApp теперь определён ниже
  ));
}

// FinanceApp — корневой виджет, использует ConsumerWidget для доступа к глобальным providers
class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key}); // const для оптимизации

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Чтение глобального состояния: theme и locale (из app_config.dart)
    final ThemeData theme = ref.watch(themeProvider);
    final Locale locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Kopim',  // Название приложения
      theme: theme,  // Глобальная тема
      locale: locale,  // Локализация
      // Добавьте supportedLocales и localizationsDelegates для intl в будущем
      home: const HomeScreen(),  // Домашний экран, const
      debugShowCheckedModeBanner: false,  // Отключить баннер debug
    );
  }
}

// HomeScreen — домашний экран, используем ConsumerWidget для Riverpod (локальное состояние)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key}); // const для оптимизации, без title (если нужно, добавьте)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Чтение локального состояния: счётчик (watch для реактивности, без setState)
    final int counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),  // const
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',  // const для оптимизации
            ),
            Text(
              '$counter',  // Реактивно обновляется
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text('Welcome to Kopim'),  // Добавлено из предыдущей версии
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Обновление состояния через notifier (минимизация перерисовок)
          ref.read(counterProvider.notifier).state++;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),  // const
      ),
    );
  }

  // Для diagnostic_describe_all_properties: Описание свойств (lint-friendly)
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('description', 'Home Screen Widget'));
  }
}