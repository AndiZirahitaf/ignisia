import 'package:elearning/root_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:elearning/course/mycourses.dart';
import 'package:intl/intl.dart'; // buat format angka ribuan
import '../api/api.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> course;
  final int userId;

  const CheckoutPage({super.key, required this.course, required this.userId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedMethod = "DANA";
  String selectedCurrency = "IDR";

  Future<void> _processPayment() async {
    // Simulasi proses pembayaran
    final response = await purchaseCourse(widget.course['id'], widget.userId);
    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pembayaran berhasil! Course ditambahkan ke My Courses.",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RootWithBottomNav(initialIndex: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pembayaran gagal. Silakan coba lagi."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // simulasi nilai tukar
  final Map<String, double> _exchangeRates = {
    "IDR": 1.0,
    "USD": 0.000064, // 1 IDR = 0.000064 USD
    "TRY": 0.0021, // 1 IDR = 0.0021 Lira
    "JPY": 0.0104, // 1 IDR = 0.0104 Yen
  };

  double get convertedPrice {
    double basePrice = double.tryParse(widget.course['price'].toString()) ?? 0;
    return basePrice * _exchangeRates[selectedCurrency]!;
  }

  String get currencySymbol {
    switch (selectedCurrency) {
      case "USD":
        return "\$";
      case "TRY":
        return "₺";
      case "JPY":
        return "¥";
      default:
        return "Rp";
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###.##');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              "Konfirmasi\nPembayaran",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Trocchi',
              ),
            ),
            const SizedBox(height: 50),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // increased radius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nama: ",
                        style: const TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.course['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Harga: ",
                        style: const TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$currencySymbol${formatter.format(convertedPrice)} $selectedCurrency",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              // isDense: true,
              dropdownColor: Colors.white,
              value: selectedCurrency,
              isExpanded: false,
              decoration: _inputDecoration("Pilih Mata Uang"),
              items: const [
                DropdownMenuItem(value: "IDR", child: Text("Rupiah (IDR)")),
                DropdownMenuItem(value: "USD", child: Text("Dolar (USD)")),
                DropdownMenuItem(value: "TRY", child: Text("Lira (TRY)")),
                DropdownMenuItem(value: "JPY", child: Text("Yen (JPY)")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedMethod,
              decoration: _inputDecoration("Metode Pembayaran"),
              items: const [
                DropdownMenuItem(value: "DANA", child: Text("DANA")),
                DropdownMenuItem(value: "GOPAY", child: Text("GoPay")),
                DropdownMenuItem(value: "BANK", child: Text("Transfer Bank")),
              ],
              onChanged: (v) {
                setState(() => selectedMethod = v!);
              },
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: () {
                _processPayment();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36), // button radius
                ),
              ),
              child: const Text("Bayar Sekarang"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      isDense: true,
    );
  }
}
