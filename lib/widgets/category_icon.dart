import 'package:flutter/material.dart';
import 'package:expense_tracking/models/category_model.dart';

/// A curated set of icons the user can actually PICK from when creating
/// a custom category — keyed by a short string, since IconData itself
/// can't be stored in Firestore. The key is what gets saved on the
/// CategoryModel; the IconData is only looked up at display time.
const Map<String, IconData> categoryIconLibrary = {
  'shopping_bag': Icons.shopping_bag_rounded,
  'restaurant': Icons.restaurant_rounded,
  'directions_car': Icons.directions_car_rounded,
  'home': Icons.home_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'movie': Icons.movie_rounded,
  'fitness_center': Icons.fitness_center_rounded,
  'medical_services': Icons.medical_services_rounded,
  'school': Icons.school_rounded,
  'flight': Icons.flight_rounded,
  'pets': Icons.pets_rounded,
  'celebration': Icons.celebration_rounded,
  'sports_esports': Icons.sports_esports_rounded,
  'local_cafe': Icons.local_cafe_rounded,
  'spa': Icons.spa_rounded,
  'build': Icons.build_rounded,
  'work': Icons.work_rounded,
  'savings': Icons.savings_rounded,
  'card_giftcard': Icons.card_giftcard_rounded,
  'checkroom': Icons.checkroom_rounded,
  'local_grocery_store': Icons.local_grocery_store_rounded,
  'phone_iphone': Icons.phone_iphone_rounded,
  'book': Icons.menu_book_rounded,
  'category': Icons.category_rounded, // generic / "other"
};

/// Looks up an icon by its stored key. Falls back to the generic
/// "category" icon if the key is missing or unrecognized (e.g. an
/// older category saved before this feature existed).
IconData iconFromKey(String? key) => categoryIconLibrary[key] ?? Icons.category_rounded;

/// The single function everywhere else should call to decide what icon
/// to show for a category. Custom categories carry their own chosen
/// iconKey; built-in categories (and any custom one saved before icon
/// picking existed) don't have one, so this falls back to the old
/// name-based guess below.
IconData resolveCategoryIcon(CategoryModel category) {
  if (category.iconKey != null && category.iconKey!.isNotEmpty) {
    return iconFromKey(category.iconKey);
  }
  return iconForCategory(category.name);
}

/// Maps a category NAME to a fitting Material icon — the original
/// name-based guess, kept as the fallback for built-in categories
/// (which never carry an iconKey) and any legacy custom category saved
/// before icon picking existed.
IconData iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
    case 'food & dining':
      return Icons.restaurant_rounded;
    case 'transport':
      return Icons.directions_car_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'bills':
      return Icons.receipt_long_rounded;
    case 'entertainment':
      return Icons.movie_rounded;
    case 'salary':
      return Icons.payments_rounded;
    case 'freelance':
      return Icons.laptop_mac_rounded;
    case 'business':
      return Icons.storefront_rounded;
    case 'gift':
      return Icons.card_giftcard_rounded;
    case 'family':
      return Icons.family_restroom_rounded;
    case 'borrowed':
      return Icons.handshake_rounded;
    case 'investment':
      return Icons.trending_up_rounded;
    case 'subscription':
      return Icons.subscriptions_rounded;
    case 'utility':
      return Icons.bolt_rounded;
    case 'rent':
      return Icons.home_rounded;
    case 'loan':
      return Icons.account_balance_rounded;
    case 'insurance':
      return Icons.health_and_safety_rounded;
    default:
      return Icons.category_rounded;
  }
}