import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'kasir_cart.dart';
import 'kasir_cart_page.dart';
import 'kasir_menu_tab.dart';
import 'kasir_orders_tab.dart';
import 'kasir_theme.dart';

// Cangkang halaman kasir: AppBar, bottom navigation (Menu / Pesanan), dan keranjang.
class KasirHomePage extends StatefulWidget {
  const KasirHomePage({super.key});

  @override
  State<KasirHomePage> createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  final KasirCart _cart = KasirCart();
  int _tabIndex = 0;

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  Future<void> _openCart() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Theme(
          data: kasirTheme(),
          child: KasirCartPage(cart: _cart),
        ),
      ),
    );

    // Setelah pesanan dibuat, pindah ke tab Pesanan.
    if (created == true && mounted) {
      setState(() => _tabIndex = 1);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await AuthService().logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kasirTheme(),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Row(
            children: [
              // Ganti dengan logo asli kalau sudah ada di assets.
              Icon(Icons.hexagon_outlined, color: KasirColors.green),
              SizedBox(width: 8),
              Text(
                'Nutrack',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Notifikasi',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Belum ada notifikasi.')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: KasirColors.border),
          ),
        ),
        body: IndexedStack(
          index: _tabIndex,
          children: [
            KasirMenuTab(cart: _cart, onViewCart: _openCart),
            const KasirOrdersTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (index) => setState(() => _tabIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.local_cafe_outlined),
              selectedIcon: Icon(Icons.local_cafe, color: KasirColors.green),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon:
                  Icon(Icons.receipt_long, color: KasirColors.green),
              label: 'Pesanan',
            ),
          ],
        ),
      ),
    );
  }
}
