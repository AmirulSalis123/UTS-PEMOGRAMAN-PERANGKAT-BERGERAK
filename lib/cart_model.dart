import 'package:flutter/foundation.dart';

class CartItem {
  final String productName;
  final String productType;
  final double price;
  int quantity;
  final String imageAsset;

  CartItem({
    required this.productName,
    required this.productType,
    required this.price,
    required this.quantity,
    required this.imageAsset,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      productName: productName,
      productType: productType,
      price: price,
      quantity: quantity ?? this.quantity,
      imageAsset: imageAsset,
    );
  }
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  Cart({List<CartItem> items = const []}) {
    _items = List.from(items);
  }

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(CartItem newItem) {
    final existingIndex = _items.indexWhere((item) => item.productName == newItem.productName);
    
    if (existingIndex >= 0) {
      // Update quantity if item exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newItem.quantity
      );
    } else {
      // Add new item
      _items.add(newItem);
    }
    notifyListeners();
  }

  void updateQuantity(String productName, int quantity) {
    final index = _items.indexWhere((item) => item.productName == productName);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void removeItem(String productName) {
    _items.removeWhere((item) => item.productName == productName);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}