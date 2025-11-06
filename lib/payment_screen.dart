import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _paymentController = TextEditingController();
  double change = 0;
  bool _isPaymentValid = false;

  void _calculateChange() {
    double paymentAmount = double.tryParse(_paymentController.text) ?? 0;
    setState(() {
      change = paymentAmount - widget.totalAmount;
      _isPaymentValid = paymentAmount > 0 && change >= 0;
    });
  }

  void _processPayment() {
    if (!_isPaymentValid) {
      if (_paymentController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap masukkan jumlah pembayaran terlebih dahulu'),
            backgroundColor: Colors.red,
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah pembayaran kurang dari total transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('Pembayaran berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  // TAMBAHAN: Method untuk batalkan pembayaran
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Batal'),
          content: const Text('Apakah Anda yakin ingin membatalkan pembayaran?'),
          actions: [
            TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text(
              'Tidak',
              style: TextStyle(color: Colors.blue), // TAMBAH WARNA BIRU
            ),
          ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.pop(context, false); // Kembali ke dashboard
              },
              child: const Text(
                'Ya',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL TRANSAKSI
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Total Transaksi:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rp ${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // INPUT JUMLAH PEMBAYARAN
            const Text(
              'Jumlah Pembayaran:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(
                labelText: 'Masukkan jumlah pembayaran',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
                hintText: 'Contoh: 50000',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calculateChange(),
            ),
            
            const SizedBox(height: 20),
            
            // INFO KEMBALIAN
            if (_paymentController.text.isNotEmpty) ...[
              Card(
                color: change >= 0 ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        change >= 0 ? 'Kembalian:' : 'Kekurangan:',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Rp ${change.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (change < 0) 
                        const Text(
                          'Jumlah pembayaran kurang',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            
            const Spacer(),
            
            // TOMBOL PROSES PEMBAYARAN
            ElevatedButton(
              onPressed: _isPaymentValid ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _isPaymentValid ? Colors.green : Colors.grey,
              ),
              child: Text(
                _isPaymentValid ? 'Proses Pembayaran' : 'Masukkan Jumlah Pembayaran',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            // TAMBAHAN: Tombol Batalkan Pembayaran
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showCancelConfirmation,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.white, // Warna teks merah
                  backgroundColor: Colors.red, // Background merah muda
                ),
                child: const Text(
                  'Batalkan Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}