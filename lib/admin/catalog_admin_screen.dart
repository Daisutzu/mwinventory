import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../catalog_repository.dart';
import '../product.dart';
import '../widgets/mw_app_bar.dart';
import 'bulk_import_screen.dart';
import 'missing_ean_screen.dart';
import 'most_viewed_screen.dart';
import 'product_form_screen.dart';

class CatalogAdminScreen extends StatefulWidget {
  const CatalogAdminScreen({super.key});

  @override
  State<CatalogAdminScreen> createState() => _CatalogAdminScreenState();
}

class _CatalogAdminScreenState extends State<CatalogAdminScreen> {
  String _query = '';

  Future<void> _openForm({Product? product}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
    if (changed == true) setState(() {});
  }

  Future<void> _openBulkImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BulkImportScreen()),
    );
    setState(() {});
  }

  Future<void> _confirmDelete(Product product) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare questo prodotto?'),
        content: Text(
          '"${product.name}" (${product.brand}) verrà rimosso dal catalogo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Niente await: vedi nota in product_form_screen.dart su put()/delete().
      catalogRepository.delete(product.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _query.trim().toLowerCase();
    final products = sampleProducts
        .where(
          (p) =>
              q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList()
      ..sort((a, b) {
        final c = a.category.compareTo(b.category);
        if (c != 0) return c;
        final b1 = a.brand.compareTo(b.brand);
        if (b1 != 0) return b1;
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      appBar: MwAppBar(
        title: 'GESTIONE CATALOGO',
        showSearchAction: false,
        actions: [
          IconButton(
            tooltip: 'Importa elenco',
            icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
            onPressed: _openBulkImport,
          ),
          IconButton(
            tooltip: 'Prodotti senza EAN',
            icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MissingEanScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Prodotti più cercati',
            icon: const Icon(Icons.trending_up_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MostViewedScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBrandRed,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant, width: 1.5),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Filtra per nome, marca o categoria...',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.filter_list_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} prodotti',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: catalogRepository.cloudSynced,
                  builder: (context, synced, _) {
                    final color = synced ? Colors.green : scheme.onSurfaceVariant;
                    return Tooltip(
                      message: synced
                          ? 'Le modifiche si stanno sincronizzando su tutti i dispositivi'
                          : 'Le modifiche restano solo su questo dispositivo finche\' '
                              'non torna la connessione con il database',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            synced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            size: 15,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            synced ? 'Sincronizzato' : 'Solo locale',
                            style: TextStyle(fontSize: 12, color: color),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                final variantCount = product.category == 'Telefonia' ||
                        product.category == 'Tablet' ||
                        product.category == 'Accessori'
                    ? product.variants.length
                    : product.pcVariants.length;
                return Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.brand} · ${product.category} · $variantCount ${variantCount == 1 ? 'variante' : 'varianti'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Modifica',
                          icon: Icon(
                            Icons.edit_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () => _openForm(product: product),
                        ),
                        IconButton(
                          tooltip: 'Elimina',
                          icon: Icon(Icons.delete_rounded, color: scheme.error),
                          onPressed: () => _confirmDelete(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
