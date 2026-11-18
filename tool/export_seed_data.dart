
import 'dart:convert';
import 'dart:io';

import '../lib/data/initial_menus.dart';
import '../lib/data/initial_ingredients.dart';
import '../lib/data/initial_recipes.dart';
import '../lib/data/initial_inventory.dart';

void main() {
  final data = {
    'menus': initialMenus,
    'ingredients': initialIngredients,
    'recipes': initialRecipes,
    'inventory': initialInventory,
  };

  final file = File('tool/seed_data.json');
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(data),
  );

  print('Data berhasil diekspor ke ${file.path}');
  print('Menus: ${initialMenus.length}');
  print('Ingredients: ${initialIngredients.length}');
  print('Recipes: ${initialRecipes.length}');
  print('Inventory: ${initialInventory.length}');
}
