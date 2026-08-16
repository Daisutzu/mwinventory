import 'package:flutter/material.dart';

// Stato globale del tema, condiviso da tutte le schermate senza dover
// passare callback in giro: parte dalla preferenza di sistema e puo'
// essere forzato dall'utente tramite il pulsante nella barra in alto.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

void toggleThemeMode(BuildContext context) {
  final isCurrentlyDark = themeModeNotifier.value == ThemeMode.dark ||
      (themeModeNotifier.value == ThemeMode.system &&
          MediaQuery.platformBrightnessOf(context) == Brightness.dark);
  themeModeNotifier.value = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
}
