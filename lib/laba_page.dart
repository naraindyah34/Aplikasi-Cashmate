import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class LabaPage extends StatefulWidget {
  const LabaPage({super.key});

  @override
  State<LabaPage> createState() => _LabaPageState();
}

class _LabaPageState extends State<LabaPage> {
  // --- KONSTANTA WARNA ELECTRIC ---
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color successColor = const Color(0xFF00B894); // Hijau Profit
  final Color warningColor = const Color(0xFFFDCB6E); // Kuning Modal

  List listLaba = [];
  bool loading = true;

  // Variabel Penampung Total
  int totalOmset = 0;
  int totalModal = 0;
  int totalProfit = 0;

  Future<void> getLaba() async {
    // ⚠️ IP KEMBALI KE 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_laba.php";

    try {
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);

      // Hitung Total Keseluruhan
      int tOmset = 0;
      int tModal = 0;
      int tProfit = 0;

      for (var item in data) {
        int qty = int.parse(item['transaksi_jumlah']);
        int jual = int.parse(item['harga_jual']);
        int modal = int.parse(item['harga_modal']);
        int laba = int.parse(item['laba_bersih']);

        tOmset += (jual * qty);
        tModal += (modal * qty);
        tProfit += laba;
      }

      setState(() {
        listLaba = data;
        totalOmset = tOmset;
        totalModal = tModal;
        totalProfit = tProfit;
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLaba();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Laporan Keuntungan",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 1. HEADER DASHBOARD (KARTU GRADASI) ---
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Total Keuntungan Bersih",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Rp $totalProfit",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Row Info Kecil (Omset & Modal)
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _miniStat(
                                  "Omset",
                                  "Rp $totalOmset",
                                  Colors.white,
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.white30,
                                ),
                                _miniStat(
                                  "Modal",
                                  "Rp $totalModal",
                                  Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 2. JUDUL SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Rincian Per Produk",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- 3. LIST DATA PRODUK ---
                    ListView.builder(
                      shrinkWrap: true, // Agar bisa di dalam SingleScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: listLaba.length,
                      itemBuilder: (context, index) {
                        final data = listLaba[index];
                        int profitItem = int.parse(data['laba_bersih']);

                        return Container(
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
                            children: [
                              // Icon Kotak
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      profitItem >= 0
                                          ? successColor.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color:
                                      profitItem >= 0
                                          ? successColor
                                          : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Info Produk
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['produk_nama'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data['transaksi_jumlah']} pcs x (Jual ${data['harga_jual']} - Beli ${data['harga_modal']})",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Nilai Profit
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Untung",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    "Rp $profitItem",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          profitItem >= 0
                                              ? successColor
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }

  // Widget Kecil untuk Statistik Header
  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
