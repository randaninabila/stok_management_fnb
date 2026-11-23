import 'package:flutter/material.dart';

import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
import 'kasir_cart.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

class KasirMenuTab extends StatefulWidget {
  final KasirCart cart;
  final VoidCallback onViewCart;

  const KasirMenuTab({
    super.key,
    required this.cart,
    required this.onViewCart,
  });

  @override
  State<KasirMenuTab> createState() => _KasirMenuTabState();
}

class _KasirMenuTabState extends State<KasirMenuTab> {
  late final Stream<List<MenuModel>> _stream =
      MenuService().getAvailableMenus();

  String _category = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: KasirColors.textDark,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<MenuModel>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Error menu: ${snapshot.error}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Gagal mengambil data menu.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final menus = snapshot.data ?? [];

              if (menus.isEmpty) {
                return const Center(
                  child: Text('Belum ada menu yang tersedia.'),
                );
              }

              final categories = ['Semua', ...menus.map((m) => m.category).toSet()];
              final selected = categories.contains(_category) ? _category : 'Semua';
              final visible = selected == 'Semua'
                  ? menus
                  : menus.where((m) => m.category == selected).toList();

              return Column(
                children: [
                  _buildCategoryTabs(categories, selected),
                  const Divider(height: 1, color: KasirColors.border),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: widget.cart,
                      builder: (context, _) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          itemCount: visible.length,
                          itemBuilder: (context, index) =>
                              _buildMenuCard(visible[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _buildCartBar(),
      ],
    );
  }

  Widget _buildCategoryTabs(List<String> categories, String selected) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: categories.map((category) {
          final isSelected = category == selected;
          return GestureDetector(
            onTap: () => setState(() => _category = category),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border(
                        bottom: BorderSide(
                          color: KasirColors.green,
                          width: 2,
                        ),
                      )
                    : null,
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? KasirColors.green : KasirColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final qty = widget.cart.qtyOf(menu.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KasirColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KasirColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                // MenuModel belum punya field deskripsi, jadi tampilkan kategori.
                Text(
                  menu.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: KasirColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(menu.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KasirColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          qty == 0
              ? KasirAddButton(onPressed: () => widget.cart.add(menu))
              : KasirQtyStepper(
                  quantity: qty,
                  onAdd: () => widget.cart.add(menu),
                  onRemove: () => widget.cart.remove(menu),
                ),
        ],
      ),
    );
  }

  Widget _buildCartBar() {
    return ListenableBuilder(
      listenable: widget.cart,
      builder: (context, _) {
        if (widget.cart.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: KasirColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.cart.totalItems} Porsi',
                      style: const TextStyle(
                        color: KasirColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      formatRupiah(widget.cart.totalPrice),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: KasirColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: widget.onViewCart,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 48),
                ),
                child: const Text('Lihat Pesanan'),
              ),
            ],
          ),
        );
      },
    );
  }
}
