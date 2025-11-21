import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cart_model.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;
  final Function(Cart) onCartUpdated;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onCartUpdated,
  });

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final Map<String, bool> _selectedItems = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, FocusNode> _quantityFocusNodes = {};
  bool _isDialogOpen = false;
  final Map<String, int> _previousQuantities = {};

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  bool get _allSelected {
    if (widget.cart.items.isEmpty) return false;
    return _selectedItems.length == widget.cart.items.length &&
        _selectedItems.values.every((isSelected) => isSelected);
  }

  double get _selectedTotal {
    return widget.cart.items.fold(0, (total, item) {
      if (_selectedItems[item.productName] == true) {
        return total + item.subtotal;
      }
      return total;
    });
  }

  int get _selectedCount {
    return _selectedItems.values.where((isSelected) => isSelected).length;
  }

  int get _cartItemCount {
    return widget.cart.items.length;
  }

  @override
  void initState() {
    super.initState();
    for (var item in widget.cart.items) {
      _selectedItems[item.productName] = true;
      _quantityControllers[item.productName] =
          TextEditingController(text: item.quantity.toString());
      _quantityFocusNodes[item.productName] = FocusNode();

      _quantityFocusNodes[item.productName]!.addListener(() {
        if (!_quantityFocusNodes[item.productName]!.hasFocus) {
          _updateQuantityFromTextField(item.productName);
        }
      });
    }

    widget.cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    widget.cart.removeListener(_onCartChanged);
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _quantityFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  void _toggleAllSelection(bool? selected) {
    setState(() {
      if (selected == true) {
        for (var item in widget.cart.items) {
          _selectedItems[item.productName] = true;
        }
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String productId, bool? selected) {
    setState(() {
      _selectedItems[productId] = selected ?? false;
    });
  }

  void _updateQuantity(String productId, int newQuantity) {
    widget.cart.updateQuantity(productId, newQuantity);
    widget.onCartUpdated(widget.cart);
    _quantityControllers[productId]?.text = newQuantity.toString();
  }

  void _updateQuantityFromTextField(String productId) {
    final controller = _quantityControllers[productId];
    if (controller != null) {
      final text = controller.text;
      if (text.isNotEmpty) {
        final newQuantity = int.tryParse(text) ?? 1;
        if (newQuantity <= 0) {
          _previousQuantities[productId] = widget.cart.items
              .firstWhere((item) => item.productName == productId)
              .quantity;
          _showDeleteConfirmationDialog(productId);
        } else {
          _updateQuantity(productId, newQuantity);
        }
      } else {
        _previousQuantities[productId] = widget.cart.items
            .firstWhere((item) => item.productName == productId)
            .quantity;
        _showDeleteConfirmationDialog(productId);
      }
    }
  }

  void _decreaseQuantity(String productId) {
    final currentQuantity = widget.cart.items
        .firstWhere((item) => item.productName == productId)
        .quantity;

    if (currentQuantity == 1) {
      _previousQuantities[productId] = currentQuantity;
      _showDeleteConfirmationDialog(productId);
    } else {
      _updateQuantity(productId, currentQuantity - 1);
    }
  }

  void _showDeleteConfirmationDialog(String productId) {
    if (_isDialogOpen) return;

    final item =
        widget.cart.items.firstWhere((item) => item.productName == productId);

    _isDialogOpen = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Konfirmasi hapus produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Anda yakin ingin ',
                      ),
                      const TextSpan(
                        text: 'MENGHAPUS ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${item.productName} ',
                      ),
                      const TextSpan(
                        text: 'dari keranjang belanja?',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _isDialogOpen = false;
                          final previousQuantity =
                              _previousQuantities[productId] ?? 1;
                          _quantityControllers[productId]?.text =
                              previousQuantity.toString();
                          _updateQuantity(productId, previousQuantity);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _isDialogOpen = false;
                          _removeItem(productId);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YAKIN',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _isDialogOpen = false;
    });
  }

  void _removeItem(String productId) {
    widget.cart.removeItem(productId);
    widget.onCartUpdated(widget.cart);
    setState(() {
      _selectedItems.remove(productId);
      _quantityControllers.remove(productId);
      _quantityFocusNodes.remove(productId);
      _previousQuantities.remove(productId);
    });
  }

  void _clearAllItems() {
    widget.cart.clear();
    widget.onCartUpdated(widget.cart);
    setState(() {
      _selectedItems.clear();
      for (var controller in _quantityControllers.values) {
        controller.dispose();
      }
      for (var focusNode in _quantityFocusNodes.values) {
        focusNode.dispose();
      }
      _quantityControllers.clear();
      _quantityFocusNodes.clear();
      _previousQuantities.clear();
    });
  }

  // Method baru untuk navigasi ke PaymentScreen
  void _navigateToPayment() {
  if (_selectedCount == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda belum memilih produk apapun!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Navigate ke PaymentScreen dengan total yang dipilih
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentScreen(totalAmount: _selectedTotal),
    ),
  ).then((paymentSuccess) {
    // Jika pembayaran berhasil, hapus item yang dipilih dari keranjang
    if (paymentSuccess == true) {
      _removeSelectedItemsAfterPayment();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Kembali ke halaman utama (DashboardScreen)
      // Pop sampai ke root (DashboardScreen)
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  });
}

  // Method baru untuk menghapus item setelah pembayaran berhasil
  void _removeSelectedItemsAfterPayment() {
    final itemsToRemove = <String>[];

    for (var entry in _selectedItems.entries) {
      if (entry.value == true) {
        itemsToRemove.add(entry.key);
      }
    }

    for (var productId in itemsToRemove) {
      widget.cart.removeItem(productId);
      _quantityControllers.remove(productId);
      _quantityFocusNodes.remove(productId);
      _previousQuantities.remove(productId);
    }

    _selectedItems.clear();
    widget.onCartUpdated(widget.cart);

    setState(() {});
  }

  // Method untuk menghapus item yang dipilih
  void _removeSelectedItems() {
    final itemsToRemove = <String>[];

    for (var entry in _selectedItems.entries) {
      if (entry.value == true) {
        itemsToRemove.add(entry.key);
      }
    }

    for (var productId in itemsToRemove) {
      widget.cart.removeItem(productId);
      _quantityControllers.remove(productId);
      _quantityFocusNodes.remove(productId);
      _previousQuantities.remove(productId);
    }

    _selectedItems.clear();
    widget.onCartUpdated(widget.cart);

    setState(() {});
  }

  // Method untuk menampilkan dialog konfirmasi hapus produk terpilih
  void _showDeleteSelectedProductsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Judul
                const Text(
                  'Konfirmasi hapus produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // Pesan konfirmasi
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Anda yakin ingin menghapus produk dari keranjang belanja?',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Tombol BATAL dan YAKIN
                Row(
                  children: [
                    // Tombol BATAL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tombol YAKIN
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _removeSelectedItems();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YAKIN',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Saya ($_cartItemCount)'),
        actions: [
          if (widget.cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              onPressed: () {
                if (_selectedCount == 0) {
                  // Tampilkan notifikasi jika belum memilih produk
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon pilih produk untuk menghapus'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Jika ada item yang dipilih, tampilkan dialog konfirmasi dengan desain baru
                  _showDeleteSelectedProductsDialog();
                }
              },
            ),
        ],
      ),
      body: widget.cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keranjang belanja Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan tambahkan produk ke keranjang',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali Berbelanja'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  margin: const EdgeInsets.only(
                      top: 2), // Padding vertikal dikurangi
                  child: Row(
                    children: [
                      Checkbox(
                        value: _allSelected,
                        onChanged: _toggleAllSelection,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Pilih semua',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_selectedCount item terpilih',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart.items[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: widget.cart.items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Belanja',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(_selectedTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToPayment, // Diubah dari _showCheckoutMessage ke _navigateToPayment
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Selalu biru
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Checkout ($_selectedCount)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: _selectedItems[item.productName] ?? false,
              onChanged: (selected) =>
                  _toggleItemSelection(item.productName, selected),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: AssetImage(item.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(item.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _decreaseQuantity(item.productName),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                          child: const Icon(Icons.remove, size: 14),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 28,
                        color: Colors.white,
                        child: Center(
                          child: TextField(
                            controller: _quantityControllers[item.productName],
                            focusNode: _quantityFocusNodes[item.productName],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              height: 1.0,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 2),
                              isDense: true,
                              counterText: "",
                            ),
                            maxLines: 1,
                            onSubmitted: (value) {
                              _updateQuantityFromTextField(item.productName);
                              _quantityFocusNodes[item.productName]?.unfocus();
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _updateQuantity(item.productName, item.quantity + 1),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _removeItem(item.productName),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}