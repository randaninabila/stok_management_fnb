import 'package:flutter/foundation.dart';

import '../../models/menu_model.dart';

// Keranjang milik kasir (hanya di sisi aplikasi).
// Harga final tetap dihitung backend lewat createOrder.
class KasirCart extends ChangeNotifier {
  final Map<String, MenuModel> _menus = {};
  final Map<String, int> _qty = {};

  int qtyOf(String menuId) => _qty[menuId] ?? 0;

  bool get isEmpty => _qty.isEmpty;

  int get totalItems => _qty.values.fold(0, (a, b) => a + b);

  double get totalPrice {
    double total = 0;
    _qty.forEach((id, qty) {
      total += (_menus[id]?.price ?? 0) * qty;
    });
    return total;
  }

  List<MapEntry<MenuModel, int>> get lines {
    return _qty.entries
        .where((e) => _menus.containsKey(e.key))
        .map((e) => MapEntry(_menus[e.key]!, e.value))
        .toList();
  }

  void add(MenuModel menu) {
    _menus[menu.id] = menu;
    _qty[menu.id] = qtyOf(menu.id) + 1;
    notifyListeners();
  }

  void remove(MenuModel menu) {
    final qty = qtyOf(menu.id);
    if (qty <= 1) {
      _qty.remove(menu.id);
      _menus.remove(menu.id);
    } else {
      _qty[menu.id] = qty - 1;
    }
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    _menus.clear();
    notifyListeners();
  }
}
