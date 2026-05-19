import 'package:flutter/material.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class CategoryUtils {
  static const List<String> categories = [
    "accessories",
    "clothes",
    "devices",
    "wallets",
    "keys",
    "bags",
    "study",
    "others"
  ];

  static IconData getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'accessories':
        return Icons.watch_rounded;
      case 'clothes':
        return Icons.checkroom_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'wallets':
        return Icons.account_balance_wallet_rounded;
      case 'keys':
        return Icons.vpn_key_rounded;
      case 'bags':
        return Icons.shopping_bag_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      case 'others':
      default:
        return Icons.inventory_2_rounded;
    }
  }

  static String getCategoryLabel(String category, AppStrings t) {
    switch (category.toLowerCase()) {
      case 'accessories':
        return t.accessories;
      case 'clothes':
        return t.clothes;
      case 'devices':
        return t.devices;
      case 'wallets':
        return t.wallets;
      case 'keys':
        return t.keys;
      case 'bags':
        return t.bags;
      case 'study':
        return t.study;
      case 'others':
      default:
        return t.others;
    }
  }

  static String getStatusLabel(String? status, AppStrings t) {
    switch (status?.toLowerCase().trim()) {
      case 'matched':
        return t.statusMatched;
      case 'returned':
        return t.statusReturned;
      case 'active':
      default:
        return t.statusSearching;
    }
  }

  static Color getStatusColor(String? status, ThemeData theme) {
    switch (status?.toLowerCase().trim()) {
      case 'matched':
        return Colors.orange;
      case 'returned':
        return Colors.green;
      case 'active':
      default:
        return theme.colorScheme.primary;
    }
  }
}
