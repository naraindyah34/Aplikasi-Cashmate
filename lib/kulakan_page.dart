import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class KulakanPage extends StatefulWidget {
  const KulakanPage({super.key});

  @override
  State<KulakanPage> createState() => _KulakanPageState();
}

class _KulakanPageState extends State<KulakanPage> {
  // --- WARNA ELECTRIC ---
  final Color primaryColor = const Color(0xFF005BEA);
  final Color bgColor = const Color(0xFFF4F7FE);

  // Controller
  TextEditingController jumlahController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();

  List listProduk = [];
  String? produkTerpilih;

  Future<void> getProduk() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_produk.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listProduk = json.decode(response.body);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> simpanKulakan() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_kulakan.php";

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          "produk_id": produkTerpilih,
          "jumlah": jumlahController.text,
          "harga_beli": hargaBeliController.text,
        },
      );

      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        setState(() {
          produkTerpilih = null;
          jumlahController.clear();
          hargaBeliController.clear();
        });

        // Dialog Sukses Keren
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Stok Berhasil Ditambah!",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: ${data['pesan']}")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getProduk();
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
          "Barang Masuk",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ILUSTRASI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    size: 80,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Restock Gudang",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Tambah stok barang dari supplier",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- FORM INPUT (CARD STYLE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Pembelian",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DROPDOWN PRODUK
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: produkTerpilih,
                          isExpanded: true,
                          hint: Text(
                            "Pilih Produk",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: primaryColor,
                          ),
                          items:
                              listProduk.map((item) {
                                return DropdownMenuItem(
                                  value: item['produk_id'].toString(),
                                  child: Text(
                                    "${item['produk_nama']} (Sisa: ${item['produk_stok']})",
                                    style: GoogleFonts.poppins(),
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              produkTerpilih = val as String;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // INPUT JUMLAH
                    _inputModern(
                      jumlahController,
                      "Jumlah Masuk (Pcs)",
                      Icons.onetwothree,
                    ),
                    const SizedBox(height: 15),

                    // INPUT HARGA BELI
                    _inputModern(
                      hargaBeliController,
                      "Harga Beli Satuan (Modal Baru)",
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "*Harga modal di data produk akan otomatis terupdate",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN BESAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (produkTerpilih == null ||
                              jumlahController.text.isEmpty ||
                              hargaBeliController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Data belum lengkap!"),
                              ),
                            );
                          } else {
                            simpanKulakan();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange, // Orange identik dengan logistik
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "SIMPAN STOK MASUK",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputModern(TextEditingController ctrl, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.orange), // Ikon Orange
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
