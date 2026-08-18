import 'package:expense_tracking/models/currency_model.dart';
import 'package:expense_tracking/providers/currency_provider.dart';
import 'package:flutter/material.dart';


class CurrencyProvider extends ChangeNotifier {
  final CurrencyRepository _repository = CurrencyRepository();

  CurrencyModel _selected = defaultCurrency;
  CurrencyModel get selected => _selected;

  CurrencyProvider() {
    _loadSavedCurrency();
  }

  Future<void> _loadSavedCurrency() async {
    try {
      final code = await _repository.getCurrencyCode();
      if (code == null) return; // no saved preference — stay on default

      final match = supportedCurrencies.where((c) => c.code == code);
      if (match.isNotEmpty) {
        _selected = match.first;
        notifyListeners();
      }
    } catch (_) {
      // If this fails (e.g. not logged in yet when the provider is
      // constructed), just keep the default — not worth surfacing an
      // error for a display preference.
    }
  }

  /// Updates the UI immediately (notifyListeners before the write), then
  /// persists in the background — the person shouldn't have to wait on
  /// a network round-trip just to see the symbol change.
  Future<void> setCurrency(CurrencyModel currency) async {
    _selected = currency;
    notifyListeners();
    await _repository.setCurrencyCode(currency.code);
  }
}