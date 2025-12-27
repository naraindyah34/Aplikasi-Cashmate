import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import Halaman
import 'transaksi_page.dart';
import 'produk_page.dart';
import 'pelanggan_page.dart';
import 'laporan_page.dart';
import 'kulakan_page.dart';
import 'user_page.dart';
import 'kategori_page.dart';
import 'main.dart';

class DashboardPage extends StatefulWidget {
  final Map user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  String totalProduk = "0";
  // ⚠️ IP 1.2
  final String ipAddress = "192.168.1.2";

  @override
  void initState() {
    super.initState();
    getRingkasan();
  }

  Future<void> getRingkasan() async {
    try {
      var res = await http.get(
        Uri.parse("http://$ipAddress/aplikasi_kasir/api_produk.php"),
      );
      if (mounted) {
        var data = json.decode(res.body);
        setState(() {
          totalProduk = data is List ? data.length.toString() : "0";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: const Text("Yakin ingin keluar aplikasi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil Nama User (Cek berbagai kemungkinan nama kolom database)
    String namaUser =
        widget.user['nama'] ??
        widget.user['user_nama'] ??
        widget.user['nama_lengkap'] ??
        "Admin";

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Header Gradasi
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profile
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang,",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          // TAMPILKAN NAMA ASLI DI SINI
                          Text(
                            namaUser,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: logout,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Kartu Statistik
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoStat(
                        Icons.inventory_2_rounded,
                        totalProduk,
                        "Total Produk",
                        Colors.orange,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      _infoStat(
                        Icons.storefront_rounded,
                        "Buka",
                        "Status Toko",
                        Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Menu Utama",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Menu Grid
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _menuItem(
                        "Kasir",
                        Icons.point_of_sale_rounded,
                        primaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const TransaksiPage(),
                          ),
                        ),
                      ),
                      _menuItem(
                        "Produk",
                        Icons.inventory_2_rounded,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const ProdukPage()),
                        ),
                      ),
                      _menuItem(
                        "Pelanggan",
                        Icons.people_alt_rounded,
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const PelangganPage(),
                          ),
                        ),
                      ),
                      _menuItem(
                        "Laporan",
                        Icons.bar_chart_rounded,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const LaporanPage(),
                          ),
                        ),
                      ),
                      _menuItem(
                        "Stok Masuk",
                        Icons.local_shipping_rounded,
                        Colors.blueGrey,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const KulakanPage(),
                          ),
                        ),
                      ),
                      _menuItem(
                        "Kategori",
                        Icons.category_rounded,
                        Colors.teal,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const KategoriPage(),
                          ),
                        ),
                      ),
                      _menuItem(
                        "User",
                        Icons.manage_accounts_rounded,
                        Colors.redAccent,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const UserPage()),
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

  Widget _menuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
