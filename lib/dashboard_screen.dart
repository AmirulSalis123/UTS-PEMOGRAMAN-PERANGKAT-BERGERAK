import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'product_detail_screen.dart';
import 'payment_screen.dart';
import 'login_screen.dart';
import 'keamanan_akun_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalSales = 0;
  List<Product> products = [
    Product(
      name: 'Es Teh',
      description: 'Es teh segar dengan rasa khusus Warung Ajib',
      price: 5000,
      imageAsset: 'assets/images/es_teh_ajib.png',
    ),
    Product(
      name: 'Lumpia',
      description: 'Lumpia goreng isi sayuran fresh',
      price: 8000,
      imageAsset: 'assets/images/lumpia.png',
    ),
    Product(
      name: 'Jajanan Tradisional',
      description: 'Aneka jajanan tradisional homemade',
      price: 3000,
      imageAsset: 'assets/images/jajanan.png',
    ),
    Product(
      name: 'Minuman Segar',
      description: 'Minuman segar berbagai rasa',
      price: 4000,
      imageAsset: 'assets/images/minuman.png',
    ),
    Product(
      name: 'Martabak Telur',
      description: 'Martabak telur isi daging dan sayuran',
      price: 12000,
      imageAsset: 'assets/images/martabak.png',
    ),
    Product(
      name: 'Sate Ayam',
      description: 'Sate ayam dengan bumbu kacang spesial',
      price: 15000,
      imageAsset: 'assets/images/sate.png',
    ),
    Product(
      name: 'Nasi Goreng',
      description: 'Nasi goreng spesial Warung Ajib',
      price: 10000,
      imageAsset: 'assets/images/nasgor.png',
    ),
    Product(
      name: 'Es Jeruk',
      description: 'Es jeruk segar manis asam',
      price: 4000,
      imageAsset: 'assets/images/es_jeruk.png',
    ),
  ];

  void _showPopupMenu(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(1000, 100, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'security', 
          child: Row(
            children: [
              Icon(Icons.security),
              SizedBox(width: 8),
              Text('Keamanan & Akun'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'call',
          child: Row(
            children: [
              Icon(Icons.phone),
              SizedBox(width: 8),
              Text('Call Center'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sms',
          child: Row(
            children: [
              Icon(Icons.sms),
              SizedBox(width: 8),
              Text('SMS Center'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'maps',
          child: Row(
            children: [
              Icon(Icons.map),
              SizedBox(width: 8),
              Text('Lokasi/Maps'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );

    _handleMenuResult(result);
  }

  void _handleMenuResult(String? result) {
    switch (result) {
      case 'security': // Menangani item Keamanan & Akun
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KeamananAkunScreen()), // Navigasi ke layar baru
        );
        break;
      case 'call':
        _launchCaller(context);
        break;
      case 'sms':
        _launchSMS();
        break;
      case 'maps':
        _launchMaps();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();

                await prefs.setBool('isLoggedIn', false);
                await prefs.remove('username');
                await prefs.remove('fullName');
                await prefs.remove('password');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _launchCaller(BuildContext context) async {
  const phoneNumber = '082133960425'; // Nomor telepon (tanpa +)
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

  try {
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Tidak dapat menemukan aplikasi telepon';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tidak dapat membuka telepon'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void _launchSMS() async {
  // Format internasional tanpa tanda plus
  const phone = '6282133960425'; 
  const message = 'Halo Warung Ajib, saya ingin bertanya tentang menu dan harga';
  // URL resmi wa.me
  final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}'; 
  final Uri launchUri = Uri.parse(url);

  try {
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat menemukan aplikai WhatsApp';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _launchMaps() async {
    const query = 'Universitas Dian Nuswantoro, Semarang';
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    final Uri launchUri = Uri.parse(url);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat menemukan aplikasi Maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka Maps'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addToTotal(double price) {
    setState(() {
      totalSales += price;
    });
  }

  void _navigateToPayment() async {
    if (totalSales > 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(totalAmount: totalSales),
        ),
      );
      if (result == true || result == false) {
        setState(() {
          totalSales = 0;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('belum ada produk yang dipilih'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warung Ajib'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showPopupMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductItem(
                  product: products[index],
                  onImageTap: () => _addToTotal(products[index].price),
                  onNameTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: products[index]),
                      ),
                    );

                    if (result != null && result is double) {
                      _addToTotal(result);
                    }
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BAGIAN TOTAL
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rp ${totalSales.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                
                ElevatedButton(
                  onPressed: totalSales > 0 ? _navigateToPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payment, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onImageTap;
  final VoidCallback onNameTap;

  const ProductItem({
    required this.product,
    required this.onImageTap,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onImageTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(product.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
                child: product.imageAsset.isNotEmpty
                    ? null
                    : Icon(Icons.fastfood, size: 50, color: Colors.blue),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: onNameTap,
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}