import 'package:flutter/material.dart';
import 'app_colors.dart';

// Icona e colore rappresentativi di ogni categoria: usati come segnaposto
// quando manca l'immagine di un prodotto (non ancora generata per le
// categorie appena importate), cosi' non mostriamo piu' un'icona di
// telefono ovunque anche per un televisore o una console.
IconData categoryIcon(String category) {
  switch (category) {
    case 'Telefonia':
      return Icons.phone_iphone_rounded;
    case 'Tablet':
      return Icons.tablet_mac_rounded;
    case 'PC':
      return Icons.laptop_rounded;
    case 'PC Fissi':
      return Icons.desktop_windows_rounded;
    case 'TV':
      return Icons.connected_tv_rounded;
    case 'Console':
      return Icons.sports_esports_rounded;
    default:
      return Icons.devices_other_rounded;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'Telefonia':
      return kBrandRed;
    case 'Tablet':
      return const Color(0xFF1E88E5);
    case 'PC':
      return const Color(0xFF37474F);
    case 'PC Fissi':
      return const Color(0xFF546E7A);
    case 'TV':
      return const Color(0xFF7B1FA2);
    case 'Console':
      return const Color(0xFF2E7D32);
    default:
      return Colors.black;
  }
}
