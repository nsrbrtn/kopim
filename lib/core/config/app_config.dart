// lib/core/config/app_config.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Импорт из firebase_auth
import 'package:intl/intl.dart'; // Для локализации, но используйте flutter_localizations
import 'dart:ui'; // Для Locale

// Placeholder для AuthState (immutable с freezed)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.error(String message) = _Error;
}

// Placeholder для AuthNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  AuthNotifier(ref)
      : _auth = FirebaseAuth.instance,
        super(const AuthState.unauthenticated()) {
    // Прослушка изменений auth
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      // Реализуйте Google sign-in с firebase_auth
      // ...
      // После успеха: state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

// Другие методы: signInWithEmail, logout и т.д.
}

// Глобальный provider для theme (light/dark, иммутабельный)
final themeProvider = StateProvider<ThemeData>((ref) {
  return ThemeData.light(); // Default, переключайте ref.read(themeProvider.notifier).state = ThemeData.dark();
});

// Глобальный provider для auth (StateNotifier для глобального состояния аутентификации)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref); // ref для инъекции других deps, если нужно
});

// Глобальный provider для locale (локализация с intl)
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('en', 'US'); // Default, поддержка multi-language
});