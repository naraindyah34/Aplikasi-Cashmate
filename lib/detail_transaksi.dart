import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class DetailTransaksiPage extends StatefulWidget {
  final Map invoice;
  const DetailTransaksiPage({super.key, required this.invoice});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  // Warna Electric Ocean
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  List listBarang = [];
  bool loading = true;

  Future<void> getDetail() async {
    String id = widget.invoice['invoice_id'];
    // ⚠️ IP 1.2
    String url =
        "http://192.168.1.2/aplikasi_kasir/api_transaksi_rinci.php?id=$id";

    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listBarang = json.decode(response.body);
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
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    int subTotal = int.parse(widget.invoice['invoice_sub_total'] ?? '0');
    int ongkir = int.parse(widget.invoice['invoice_ongkir'] ?? '0');
    int diskon = int.parse(widget.invoice['invoice_diskon'] ?? '0');
    int total = int.parse(widget.invoice['invoice_total'] ?? '0');
    String tipe = widget.invoice['invoice_tipe'] ?? 'Offline';

    return Scaffold(
      backgroundColor: primaryColor, // Background Biru Pekat
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.transparent, // Transparan biar nyatu sama background
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Rincian Transaksi",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // --- TIKET STRUK ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // BAGIAN ATAS (Header)
                          Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Pembayaran Sukses",
                                  style: GoogleFonts.poppins(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp $total",
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Info Grid
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoCell(
                                      "Tanggal",
                                      widget.invoice['invoice_tanggal']
                                          .toString()
                                          .substring(0, 10),
                                    ),
                                    _infoCell(
                                      "Jam",
                                      widget.invoice['invoice_tanggal']
                                          .toString()
                                          .substring(11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoCell(
                                      "Pelanggan",
                                      widget.invoice['invoice_pelanggan'],
                                    ),
                                    _infoCell("Metode", tipe),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // --- BAGIAN POTONGAN KERTAS (Notch) ---
                          Stack(
                            children: [
                              // Garis Putus-putus Manual (Anti Error)
                              SizedBox(
                                height: 20,
                                child: Row(
                                  children: List.generate(
                                    30,
                                    (index) => Expanded(
                                      child: Container(
                                        color:
                                            index % 2 == 0
                                                ? Colors.transparent
                                                : Colors.grey[300],
                                        height: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Bolongan Kiri
                              Positioned(
                                left: -10,
                                top: 0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ), // Warna sama kayak background Scaffold
                                ),
                              ),
                              // Bolongan Kanan
                              Positioned(
                                right: -10,
                                top: 0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // BAGIAN BAWAH (List Barang)
                          Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pesanan",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ...listBarang.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${item['transaksi_jumlah']}x ${item['produk_nama']}",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Rp ${item['transaksi_total']}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Divider(height: 30),

                                // Totalan
                                _rowTotal("Subtotal", "Rp $subTotal"),
                                if (ongkir > 0)
                                  _rowTotal(
                                    "Ongkir",
                                    "Rp $ongkir",
                                    color: primaryColor,
                                  ),
                                if (diskon > 0)
                                  _rowTotal(
                                    "Diskon",
                                    "-Rp $diskon",
                                    color: Colors.red,
                                  ),

                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Bayar",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Text(
                                        "Rp $total",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: primaryColor,
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
                    ),

                    const SizedBox(height: 25),

                    // Tombol Print / Share (Hiasan)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Simpan PDF",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Tutup",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
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
  }

  Widget _infoCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _rowTotal(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[600])),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
