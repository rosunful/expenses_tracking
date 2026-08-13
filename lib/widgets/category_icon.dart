import 'package:flutter/material.dart';

/// Maps a category NAME to a fitting Material icon — used anywhere a
/// category needs a small visual marker (Budget Planner cards, the
/// category dropdown, etc.) instead of plain text alone. Falls back to
/// a generic icon for any custom category the user typed in themselves,
/// since there's no way to guess an icon for an arbitrary name like
/// "Pets" or "Hobbies".
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