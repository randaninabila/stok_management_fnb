import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'kasir_theme.dart';

class KasirOrdersTab extends StatefulWidget {
  const KasirOrdersTab({super.key});

  @override
  State<KasirOrdersTab> createState() => _KasirOrdersTabState();
}

class _KasirOrdersTabState extends State<KasirOrdersTab> {
  late final Stream<List<OrderModel>> _stream = OrderService().getAllOrders();

  static const _filters = ['Semua', 'Berjalan', 'Selesai', 'Dibatalkan'];
  String _filter = 'Semua';

  bool _matches(OrderModel order) {
    switch (_filter) {
      case 'Berjalan':
        return order.isUnfinished;
      case 'Selesai':
        return order.isCompleted;
      case 'Dibatalkan':
        return order.isCancelled;
      default:
        return true;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'selesai':
        return (const Color(0xFFDCFCE7), const Color(0xFF166534));
      case 'diproses':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
      case 'dibatalkan':
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B));
      default: // menunggu
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
    }
  }

  Widget _statusChip(String status) {
    final (bg, fg) = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _statusChip(order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(color: KasirColors.textMuted),
                ),
                const Divider(height: 24),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('${item.quantity}x ${item.menuName}'),
                            ),
                            Text(formatRupiah(item.subtotal)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      formatRupiah(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Pesanan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: KasirColors.textDark,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _filters.map((f) {
              final isSelected = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
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
                    f,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? KasirColors.green
                          : KasirColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: KasirColors.border),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Error pesanan: ${snapshot.error}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Gagal mengambil data pesanan.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = (snapshot.data ?? []).where(_matches).toList();

              if (orders.isEmpty) {
                return const Center(child: Text('Belum ada pesanan.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final summary = order.items
                      .map((i) => '${i.quantity}x ${i.menuName}')
                      .join(', ');

                  return InkWell(
                    onTap: () => _showDetail(order),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KasirColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _statusChip(order.status),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(order.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: KasirColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: KasirColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(order.totalAmount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
