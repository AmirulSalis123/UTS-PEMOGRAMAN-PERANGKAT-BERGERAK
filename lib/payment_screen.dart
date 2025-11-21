import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _paymentController = TextEditingController();
  double _change = 0;
  String? _errorText;

  String _formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  void _calculateChange() {
    final paymentAmount = double.tryParse(_paymentController.text) ?? 0;
    setState(() {
      _change = paymentAmount - widget.totalAmount;
      
      // Validasi input
      if (_paymentController.text.isEmpty) {
        _errorText = null;
      } else if (paymentAmount == 0) {
        _errorText = 'Masukkan jumlah pembayaran yang valid';
      } else if (paymentAmount < widget.totalAmount) {
        _errorText = 'Jumlah pembayaran kurang dari total transaksi';
      } else {
        _errorText = null;
      }
    });
  }

  void _processPayment() {
    if (_paymentController.text.isEmpty) {
      setState(() {
        _errorText = 'Harap masukkan jumlah pembayaran terlebih dahulu';
      });
      return;
    }

    final paymentAmount = double.tryParse(_paymentController.text) ?? 0;
    if (paymentAmount == 0) {
      setState(() {
        _errorText = 'Masukkan jumlah pembayaran yang valid';
      });
      return;
    }

    if (paymentAmount < widget.totalAmount) {
      setState(() {
        _errorText = 'Jumlah pembayaran kurang dari total transaksi';
      });
      return;
    }

    _showPaymentConfirmation();
  }

  void _showPaymentConfirmation() {
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
                  'Konfirmasi Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // Detail Pembayaran
                Column(
                  children: [
                    _buildPaymentDetail('Total Transaksi:', widget.totalAmount),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Jumlah Bayar:', double.tryParse(_paymentController.text) ?? 0),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Kembalian:', _change),
                  ],
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
                          Navigator.pop(context);
                          _showSuccessSnackBar();
                          Navigator.pop(context, true);
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

  Widget _buildPaymentDetail(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          _formatRupiah(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: amount >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL TRANSAKSI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Transaksi:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatRupiah(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Jumlah Pembayaran :',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _paymentController,
              decoration: InputDecoration(
                labelText: 'Masukkan Jumlah Pembayaran',
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                errorText: _errorText,
                errorStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calculateChange(),
            ),

            const SizedBox(height: 20),

            // INFO KEMBALIAN
            if (_paymentController.text.isNotEmpty && _errorText == null) ...[
              Card(
                color: _change >= 0 ? Colors.green[50] : Colors.red[50],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _change >= 0 ? 'Kembalian' : 'Kekurangan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatRupiah(_change.abs()),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (_change < 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Jumlah pembayaran kurang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Buat Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }
}