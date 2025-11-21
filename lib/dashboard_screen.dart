import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'product_detail_screen.dart';
import 'notifikasi_screen.dart';
import 'transaksi_screen.dart';
import 'profil_screen.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import 'cart_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  bool _mounted = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentIndex = 0;
  Cart _cart = Cart(items: []);

  static const List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Beranda',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Notifikasi',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long),
      label: 'Transaksi',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  List<Product> products = [
    Product(
      name: 'Es Teh',
      description: 'Es teh segar dengan rasa khusus Warung Ajib',
      price: 5000,
      imageAsset: 'assets/images/es_teh_ajib.png',
      type: 'minuman',
    ),
    Product(
      name: 'Lumpia',
      description: 'Lumpia goreng isi sayuran fresh',
      price: 8000,
      imageAsset: 'assets/images/lumpia.png',
      type: 'makanan',
    ),
    Product(
      name: 'Jajanan Tradisional',
      description: 'Aneka jajanan tradisional dengan rasa autentik dan lezat.',
      price: 3000,
      imageAsset: 'assets/images/jajanan.png',
      type: 'makanan',
    ),
    Product(
      name: 'Es Buah',
      description: 'Campuran aneka buah segar',
      price: 4000,
      imageAsset: 'assets/images/minuman.png',
      type: 'minuman',
    ),
    Product(
      name: 'Martabak Telur',
      description: 'Martabak telur isi daging dan sayuran',
      price: 12000,
      imageAsset: 'assets/images/martabak.png',
      type: 'makanan',
    ),
    Product(
      name: 'Sate Ayam',
      description: 'Sate ayam dengan bumbu kacang spesial',
      price: 15000,
      imageAsset: 'assets/images/sate.png',
      type: 'makanan',
    ),
    Product(
      name: 'Nasi Goreng',
      description: 'Nasi goreng spesial Warung Ajib',
      price: 10000,
      imageAsset: 'assets/images/nasgor.png',
      type: 'makanan',
    ),
    Product(
      name: 'Es Jeruk',
      description: 'Es jeruk segar manis asam',
      price: 4000,
      imageAsset: 'assets/images/es_jeruk.png',
      type: 'minuman',
    ),
  ];

  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _checkLoginStatus();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadCart();
  }

  void _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!isLoggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _loadCart() async {
    // Load cart from shared preferences or other storage
    // For now, we'll start with empty cart
  }

  void _updateCart(Cart newCart) {
    setState(() {
      _cart = newCart;
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  void _toggleSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cart: _cart,
          onCartUpdated: _updateCart,
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
  return Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    child: Stack(
      alignment: Alignment.center, // ← INI YANG DITAMBAH
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: _navigateToCart,
          padding: EdgeInsets.zero,
          iconSize: 24,
        ),
        if (_cart.items.isNotEmpty)
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
                _cart.items.length > 99 ? '99+' : _cart.items.length.toString(),
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
  );
}

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('Warung Ajib'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        _buildCartIcon(),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _cancelSearch,
        iconSize: 28,
      ),
      leadingWidth: 25,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Icon(Icons.search, size: 20, color: Colors.grey),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.0,
                ),
                decoration: const InputDecoration(
                  hintText: 'Cari di Warung Ajib',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    height: 1.0,
                  ),
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Text('✕',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                onPressed: _clearSearch,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductItem(
              product: filteredProducts[index],
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: filteredProducts[index],
                      cart: _cart,
                      onCartUpdated: _updateCart,
                    ),
                  ),
                );
                if (result != null && result is Cart) {
                  setState(() {
                    _cart = result;
                  });
                }
              },
            );
          },
        );
      case 1:
        return const NotifikasiScreen();
      case 2:
        return const TransaksiScreen();
      case 3:
        return const ProfilScreen();
      default:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductItem(
              product: filteredProducts[index],
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: filteredProducts[index],
                      cart: _cart,
                      onCartUpdated: _updateCart,
                    ),
                  ),
                );
                if (result != null && result is Cart) {
                  setState(() {
                    _cart = result;
                  });
                }
              },
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 
        ? (_isSearching ? _buildSearchAppBar() : _buildNormalAppBar())
        : null,
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: AssetImage(product.imageAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: product.imageAsset.isEmpty
                      ? const Icon(Icons.fastfood, size: 50, color: Colors.blue)
                      : null,
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(product.price.toDouble()),
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}