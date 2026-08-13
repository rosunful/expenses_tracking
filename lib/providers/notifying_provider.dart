
import 'package:flutter/material.dart';


class NotifyingProvider extends ChangeNotifier {
  String? _message;
  bool _isError = false;

  String? get message => _message;
  bool get isError => _isError;

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    _message = message;
    _isError = isError;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _message = null;
      notifyListeners();
    });
  }
}