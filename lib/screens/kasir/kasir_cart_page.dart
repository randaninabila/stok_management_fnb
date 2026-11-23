import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../models/menu_model.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'kasir_cart.dart';
import 'kasir_theme.dart';
import 'kasir_widgets.dart';

// Halaman ringkasan keranjang. Pop dengan nilai true kalau pesanan berhasil dibuat.
class KasirCartPage extends StatefulWidget {
  final KasirCart cart;

  const KasirCartPage({super.key, required this.cart});

  @override
  State<KasirCartPage> createState() => _KasirCartPageState();
}

class _KasirCartPageState extends State<KasirCartPage> {
  final OrderService _orderService = OrderService();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.cart.isEmpty || _isLoading) return;

    final items = widget.cart.lines.map((line) {
      final menu = line.key;
      return OrderItem(
        menuId: menu.id,
        menuName: menu.name,
        quantity: line.value,
        unitPrice: menu.price,
        subtotal: menu.price * line.value,
        productType: menu.productType,
        unit: menu.unit,
        recipeSnapshot: const [],
      );
    }).toList();

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      final result = await _orderService.createOrder(
        items: items,
        customerName: _nameController.text.trim(),
      );

      widget.cart.clear();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan ${result.orderNumber} berhasil dibuat '
            '(Rp ${formatRupiah(result.totalAmount)}).',
          ),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: ${e.message ?? e.code}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Ringkasan Pesanan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: KasirColors.border),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.cart,
        builder: (context, _) {
          if (widget.cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Belum ada item di pesanan.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke Menu'),
                  ),
                ],
              ),
            );
          }

          final lines = widget.cart.lines;

          return Column(
            children: [
              // Daftar item + tombol "Tambah Menu Lain"
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    _buildItemsCard(lines),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Tambah Menu Lain'),
                      ),
                    ),
                  ],
                ),
              ),

              // Pesanan atas nama
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pesanan atas nama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KasirColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: KasirColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: KasirColors.green,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Total + Bayar Sekarang
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(top: BorderSide(color: KasirColors.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: KasirColors.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatRupiah(widget.cart.totalPrice),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: KasirColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 44),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Bayar Sekarang'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Satu kartu berisi semua item, dipisah garis tipis.
  Widget _buildItemsCard(List<MapEntry<MenuModel, int>> lines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KasirColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: KasirColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lines[i].key.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: KasirColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRupiah(lines[i].key.price),
                          style: const TextStyle(
                            fontSize: 12,
                            color: KasirColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  KasirQtyStepper(
                    size: 34,
                    quantity: lines[i].value,
                    onAdd: () => widget.cart.add(lines[i].key),
                    onRemove: () => widget.cart.remove(lines[i].key),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
