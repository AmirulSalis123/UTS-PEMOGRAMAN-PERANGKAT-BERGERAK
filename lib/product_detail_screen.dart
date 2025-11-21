import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product_model.dart';
import 'cart_model.dart';
import 'cart_screen.dart';
import 'payment_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Cart cart;
  final Function(Cart) onCartUpdated;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cart,
    required this.onCartUpdated,
  });

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _cartSheetAnimationController;
  late AnimationController _buyNowSheetAnimationController;
  bool _isCartSheetVisible = false;
  bool _isBuyNowSheetVisible = false;
  int _quantity = 1;
  int _buyNowQuantity = 1;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _buyNowQuantityController =
      TextEditingController();
  bool _isAddToCartEnabled = true;
  bool _isBuyNowEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _cartSheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buyNowSheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _quantityController.text = _quantity.toString();
    _buyNowQuantityController.text = _buyNowQuantity.toString();
    _updateAddToCartButton();
    _updateBuyNowButton();
    widget.cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    // Panggil setState ketika cart berubah untuk memperbarui UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.cart.removeListener(_onCartChanged);
    _animationController.dispose();
    _cartSheetAnimationController.dispose();
    _buyNowSheetAnimationController.dispose();
    _quantityController.dispose();
    _buyNowQuantityController.dispose();
    super.dispose();
  }

  void _updateAddToCartButton() {
    setState(() {
      _isAddToCartEnabled = _quantity > 0;
    });
  }

  void _updateBuyNowButton() {
    setState(() {
      _isBuyNowEnabled = _buyNowQuantity > 0;
    });
  }

  String formatPrice(int price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(price);
  }

  void _showCartSheet() {
    setState(() {
      _isCartSheetVisible = true;
      _quantity = 1;
      _quantityController.text = _quantity.toString();
      _updateAddToCartButton();
    });
    _cartSheetAnimationController.forward();
  }

  void _hideCartSheet() {
    _cartSheetAnimationController.reverse().then((_) {
      setState(() {
        _isCartSheetVisible = false;
        _quantity = 1;
        _quantityController.text = _quantity.toString();
        _updateAddToCartButton();
      });
    });
  }

  void _showBuyNowSheet() {
    setState(() {
      _isBuyNowSheetVisible = true;
      _buyNowQuantity = 1;
      _buyNowQuantityController.text = _buyNowQuantity.toString();
      _updateBuyNowButton();
    });
    _buyNowSheetAnimationController.forward();
  }

  void _hideBuyNowSheet() {
    _buyNowSheetAnimationController.reverse().then((_) {
      setState(() {
        _isBuyNowSheetVisible = false;
        _buyNowQuantity = 1;
        _buyNowQuantityController.text = _buyNowQuantity.toString();
        _updateBuyNowButton();
      });
    });
  }

  void _addToCart() {
    if (_quantity < 1) return;

    final newItem = CartItem(
      productName: widget.product.name,
      productType: widget.product.type,
      price: widget.product.price.toDouble(),
      quantity: _quantity,
      imageAsset: widget.product.imageAsset,
    );

    widget.cart.addItem(newItem);
    widget.onCartUpdated(widget.cart);

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    _hideCartSheet();
  }

  void _processBuyNow() {
    if (_buyNowQuantity < 1) return;

    // Hitung total amount untuk pembayaran
    final totalAmount = widget.product.price * _buyNowQuantity;

    // Navigate ke PaymentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentScreen(totalAmount: totalAmount.toDouble()),
      ),
    ).then((paymentSuccess) {
      // Jika pembayaran berhasil, kembali ke halaman sebelumnya
      if (paymentSuccess == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Kembali ke halaman sebelumnya (bisa DashboardScreen atau halaman sebelumnya)
        Navigator.pop(context);
      }
    });

    _hideBuyNowSheet();
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cart: widget.cart,
          onCartUpdated: widget.onCartUpdated,
        ),
      ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _quantityController.text = _quantity.toString();
      _updateAddToCartButton();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _quantityController.text = _quantity.toString();
        _updateAddToCartButton();
      });
    }
  }

  void _incrementBuyNowQuantity() {
    setState(() {
      _buyNowQuantity++;
      _buyNowQuantityController.text = _buyNowQuantity.toString();
      _updateBuyNowButton();
    });
  }

  void _decrementBuyNowQuantity() {
    if (_buyNowQuantity > 1) {
      setState(() {
        _buyNowQuantity--;
        _buyNowQuantityController.text = _buyNowQuantity.toString();
        _updateBuyNowButton();
      });
    }
  }

  void _handleQuantityInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _quantity = 0;
        _quantityController.clear();
      });
    } else {
      final newQuantity = int.tryParse(value) ?? 0;
      if (newQuantity >= 0) {
        setState(() {
          _quantity = newQuantity;
          if (newQuantity == 0) {
            _quantityController.clear();
          } else {
            _quantityController.text = newQuantity.toString();
            _quantityController.selection = TextSelection.collapsed(
                offset: _quantityController.text.length);
          }
        });
      }
    }
    _updateAddToCartButton();
  }

  void _handleBuyNowQuantityInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _buyNowQuantity = 0;
        _buyNowQuantityController.clear();
      });
    } else {
      final newQuantity = int.tryParse(value) ?? 0;
      if (newQuantity >= 0) {
        setState(() {
          _buyNowQuantity = newQuantity;
          if (newQuantity == 0) {
            _buyNowQuantityController.clear();
          } else {
            _buyNowQuantityController.text = newQuantity.toString();
            _buyNowQuantityController.selection = TextSelection.collapsed(
                offset: _buyNowQuantityController.text.length);
          }
        });
      }
    }
    _updateBuyNowButton();
  }

  Widget _buildCartIcon() {
    final itemCount = widget.cart.items.length;
    final displayCount = itemCount > 99 ? '99+' : itemCount.toString();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _navigateToCart,
              padding: EdgeInsets.zero,
              iconSize: 24,
            ),
            if (itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    displayCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSheet() {
    if (!_isCartSheetVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _cartSheetAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _cartSheetAnimationController.value) * 280,
          ),
          child: child,
        );
      },
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Produk info dengan tombol close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar produk
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(widget.product.imageAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Detail produk dengan tombol close
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _hideCartSheet,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatPrice(widget.product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Jumlah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _quantity > 1 ? Colors.blue : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: Colors.white,
                          onPressed: _decrementQuantity,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 80,
                        height: 40,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: _handleQuantityInput,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: Colors.white,
                          onPressed: _incrementQuantity,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Tombol Masukkan Keranjang
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAddToCartEnabled ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isAddToCartEnabled ? Colors.blue : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Masukkan Keranjang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowSheet() {
    if (!_isBuyNowSheetVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _buyNowSheetAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            (1 - _buyNowSheetAnimationController.value) * 280,
          ),
          child: child,
        );
      },
      child: Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Produk info dengan tombol close - SAMA PERSIS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(widget.product.imageAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _hideBuyNowSheet,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatPrice(widget.product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Jumlah - SAMA PERSIS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _buyNowQuantity > 1
                              ? Colors.blue
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: Colors.white,
                          onPressed: _decrementBuyNowQuantity,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 80,
                        height: 40,
                        child: TextField(
                          controller: _buyNowQuantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: _handleBuyNowQuantityInput,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: Colors.white,
                          onPressed: _incrementBuyNowQuantity,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Tombol Beli Sekarang - DIUBAH untuk navigasi ke PaymentScreen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBuyNowEnabled ? _processBuyNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isBuyNowEnabled ? Colors.blue : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Beli Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Keranjang
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: _showCartSheet,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text(
                'Keranjang',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blue),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Tombol Beli Sekarang
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _showBuyNowSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Beli Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          _buildCartIcon(),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(widget.product.imageAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatPrice(widget.product.price),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Deskripsi Produk:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.product.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),

          // Overlay untuk kedua sheet
          if (_isCartSheetVisible || _isBuyNowSheetVisible)
            GestureDetector(
              onTap: () {
                if (_isCartSheetVisible) _hideCartSheet();
                if (_isBuyNowSheetVisible) _hideBuyNowSheet();
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Cart Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCartSheet(),
          ),

          // Buy Now Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBuyNowSheet(),
          ),
        ],
      ),
    );
  }
}
