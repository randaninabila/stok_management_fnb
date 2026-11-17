
const List<Map<String, dynamic>> initialRecipes = [
  // =========================
  // COFFEE BASED
  // =========================
  {
    'id': 'iced_americano',
    'menuId': 'iced_americano',
    'menuName': 'Iced Americano',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'mineral_water',
        'ingredientName': 'Mineral Water',
        'quantity': 150,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 150,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'iced_cafe_latte',
    'menuId': 'iced_cafe_latte',
    'menuName': 'Iced Cafe Latte',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 150,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 120,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'cappuccino',
    'menuId': 'cappuccino',
    'menuName': 'Cappuccino',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 120,
        'unit': 'ml',
      },
    ],
  },
  {
    'id': 'caramel_macchiato',
    'menuId': 'caramel_macchiato',
    'menuName': 'Caramel Macchiato',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 130,
        'unit': 'ml',
      },
      {
        'ingredientId': 'caramel_syrup',
        'ingredientName': 'Caramel Syrup',
        'quantity': 20,
        'unit': 'ml',
      },
      {
        'ingredientId': 'vanilla_syrup',
        'ingredientName': 'Vanilla Syrup',
        'quantity': 10,
        'unit': 'ml',
      },
    ],
  },
  {
    'id': 'iced_cafe_mocha',
    'menuId': 'iced_cafe_mocha',
    'menuName': 'Iced Cafe Mocha',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 130,
        'unit': 'ml',
      },
      {
        'ingredientId': 'chocolate_powder',
        'ingredientName': 'Chocolate Powder',
        'quantity': 20,
        'unit': 'gram',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'vanilla_latte',
    'menuId': 'vanilla_latte',
    'menuName': 'Vanilla Latte',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 150,
        'unit': 'ml',
      },
      {
        'ingredientId': 'vanilla_syrup',
        'ingredientName': 'Vanilla Syrup',
        'quantity': 20,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'flat_white',
    'menuId': 'flat_white',
    'menuName': 'Flat White',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 36,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 120,
        'unit': 'ml',
      },
    ],
  },
  {
    'id': 'brown_sugar_latte',
    'menuId': 'brown_sugar_latte',
    'menuName': 'Brown Sugar Latte',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 140,
        'unit': 'ml',
      },
      {
        'ingredientId': 'brown_sugar_syrup',
        'ingredientName': 'Brown Sugar Syrup',
        'quantity': 25,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },

  // =========================
  // NON-COFFEE
  // =========================
  {
    'id': 'iced_matcha_latte',
    'menuId': 'iced_matcha_latte',
    'menuName': 'Iced Matcha Latte',
    'ingredients': [
      {
        'ingredientId': 'matcha_powder',
        'ingredientName': 'Matcha Powder',
        'quantity': 8,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 150,
        'unit': 'ml',
      },
      {
        'ingredientId': 'mineral_water',
        'ingredientName': 'Mineral Water',
        'quantity': 30,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'chocolate',
    'menuId': 'chocolate',
    'menuName': 'Chocolate',
    'ingredients': [
      {
        'ingredientId': 'chocolate_powder',
        'ingredientName': 'Chocolate Powder',
        'quantity': 25,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 180,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'strawberry_milk',
    'menuId': 'strawberry_milk',
    'menuName': 'Strawberry Milk',
    'ingredients': [
      {
        'ingredientId': 'strawberry_puree',
        'ingredientName': 'Strawberry Puree',
        'quantity': 30,
        'unit': 'ml',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 170,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'red_velvet',
    'menuId': 'red_velvet',
    'menuName': 'Red Velvet',
    'ingredients': [
      {
        'ingredientId': 'red_velvet_powder',
        'ingredientName': 'Red Velvet Powder',
        'quantity': 25,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 170,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'thai_tea',
    'menuId': 'thai_tea',
    'menuName': 'Thai Tea',
    'ingredients': [
      {
        'ingredientId': 'thai_tea',
        'ingredientName': 'Thai Tea',
        'quantity': 10,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 100,
        'unit': 'ml',
      },
      {
        'ingredientId': 'granulated_sugar',
        'ingredientName': 'Granulated Sugar',
        'quantity': 15,
        'unit': 'gram',
      },
      {
        'ingredientId': 'mineral_water',
        'ingredientName': 'Mineral Water',
        'quantity': 100,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'lemon_tea',
    'menuId': 'lemon_tea',
    'menuName': 'Lemon Tea',
    'ingredients': [
      {
        'ingredientId': 'black_tea',
        'ingredientName': 'Black Tea',
        'quantity': 5,
        'unit': 'gram',
      },
      {
        'ingredientId': 'lemon',
        'ingredientName': 'Lemon',
        'quantity': 20,
        'unit': 'gram',
      },
      {
        'ingredientId': 'granulated_sugar',
        'ingredientName': 'Granulated Sugar',
        'quantity': 15,
        'unit': 'gram',
      },
      {
        'ingredientId': 'mineral_water',
        'ingredientName': 'Mineral Water',
        'quantity': 150,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },

  // =========================
  // SIGNATURE
  // =========================
  {
    'id': 'kopi_susu_aren',
    'menuId': 'kopi_susu_aren',
    'menuName': 'Kopi Susu Aren',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 140,
        'unit': 'ml',
      },
      {
        'ingredientId': 'palm_sugar_syrup',
        'ingredientName': 'Palm Sugar Syrup',
        'quantity': 25,
        'unit': 'ml',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
  {
    'id': 'sea_salt_coffee',
    'menuId': 'sea_salt_coffee',
    'menuName': 'Sea Salt Coffee',
    'ingredients': [
      {
        'ingredientId': 'espresso_blend_beans',
        'ingredientName': 'Espresso Blend Beans',
        'quantity': 18,
        'unit': 'gram',
      },
      {
        'ingredientId': 'fresh_milk',
        'ingredientName': 'Fresh Milk',
        'quantity': 130,
        'unit': 'ml',
      },
      {
        'ingredientId': 'whipping_cream',
        'ingredientName': 'Whipping Cream',
        'quantity': 30,
        'unit': 'ml',
      },
      {
        'ingredientId': 'sea_salt',
        'ingredientName': 'Sea Salt',
        'quantity': 1,
        'unit': 'gram',
      },
      {
        'ingredientId': 'ice_cubes',
        'ingredientName': 'Ice Cubes',
        'quantity': 100,
        'unit': 'gram',
      },
    ],
  },
];
