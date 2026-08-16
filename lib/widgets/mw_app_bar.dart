import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../search_products_screen.dart';
import '../theme_controller.dart';

// AppBar brandizzata MediaWorld: banner rosso ammorbidito da un gradiente,
// angoli inferiori arrotondati e un'ombra soffusa invece del classico
// rettangolo piatto. Include ricerca prodotti e pulsante modalita' scura,
// sempre a portata di mano su ogni schermata.
class MwAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSearchAction;

  const MwAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showSearchAction = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 8,
      shadowColor: kBrandRed.withValues(alpha: isDark ? 0.45 : 0.28),
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC2436), kBrandRed],
          ),
        ),
      ),
      actions: [
        if (showSearchAction)
          IconButton(
            tooltip: 'Cerca prodotto',
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchProductsScreen(),
                ),
              );
            },
          ),
        IconButton(
          tooltip: isDark ? 'Attiva tema chiaro' : 'Attiva tema scuro',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
          ),
          onPressed: () => toggleThemeMode(context),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}
