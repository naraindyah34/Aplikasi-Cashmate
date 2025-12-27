import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'detail_transaksi.dart'; // Biar bisa diklik ke detail

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // Warna Tema Electric Ocean
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  List listLaporan = [];
  bool loading = true;

  // Variabel Ringkasan
  int totalOmzet = 0;
  int totalTransaksi = 0;

  Future<void> getLaporan() async {
    // ⚠️ PASTIKAN IP 1.2 (Gunakan api_laporan.php yang sudah ada filter tanggal/semua)
    String url = "http://192.168.1.2/aplikasi_kasir/api_laporan.php";
    try {
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);

      setState(() {
        loading = false;
        listLaporan = (data is List) ? data : [];
        hitungRingkasan(); // Hitung total setelah data didapat
      });
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  void hitungRingkasan() {
    totalOmzet = 0;
    totalTransaksi = listLaporan.length;
    for (var item in listLaporan) {
      // Asumsi ada kolom 'invoice_total' yang berisi angka total belanja
      totalOmzet += int.parse(item['invoice_total']?.toString() ?? '0');
    }
  }

  @override
  void initState() {
    super.initState();
    getLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Laporan Transaksi",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              getLaporan();
            },
            icon: Icon(Icons.refresh, color: primaryColor),
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : Column(
                children: [
                  // --- BAGIAN HEADER RINGKASAN (GRADIENT CARDS) ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Kartu 1: Total Omzet
                        Expanded(
                          child: _summaryCard(
                            "Total Omzet",
                            "Rp ${totalOmzet.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                            Icons.monetization_on_rounded,
                            [primaryColor, secondaryColor],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Kartu 2: Total Transaksi
                        Expanded(
                          child: _summaryCard(
                            "Total Transaksi",
                            "$totalTransaksi Nota",
                            Icons.receipt_long_rounded,
                            [Colors.orange, Colors.deepOrangeAccent],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BAGIAN LIST RIWAYAT ---
                  Expanded(
                    child:
                        listLaporan.isEmpty
                            ? Center(
                              child: Text(
                                "Belum ada data transaksi",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: listLaporan.length,
                              itemBuilder: (context, index) {
                                final data = listLaporan[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Ke Halaman Detail (Struk Keren yang sudah kita buat)
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailTransaksiPage(
                                              invoice: data,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.all(15),
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "#${data['invoice_nomor']}",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  data['invoice_tanggal'] ??
                                                      "-",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  data['pelanggan_nama'] ??
                                                      "Umum",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Rp ${data['invoice_total']}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  // Widget Kartu Ringkasan
  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 15),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
