import 'package:flutter/material.dart';
import '../app_colors.dart';

// Pillola di selezione per memoria/colore: stile più curato del ChoiceChip
// di default, coerente con l'identità MediaWorld (rosso pieno da selezionato,
// bordo sottile da non selezionato).
class SelectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectorChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? kBrandRed : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? kBrandRed : colors.outlineVariant,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: kBrandRed.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : colors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
