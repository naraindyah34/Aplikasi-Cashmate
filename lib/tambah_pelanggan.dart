import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TambahPelangganPage extends StatefulWidget {
  const TambahPelangganPage({super.key});

  @override
  State<TambahPelangganPage> createState() => _TambahPelangganPageState();
}

class _TambahPelangganPageState extends State<TambahPelangganPage> {
  final Color primaryColor = const Color(0xFF005BEA);
  final Color bgColor = const Color(0xFFF4F7FE);

  // ⚠️ PASTIKAN IP SAMA DENGAN IPCONFIG (192.168.1.2)
  final String ipAddress = "192.168.1.2";

  TextEditingController namaController = TextEditingController();
  TextEditingController hpController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController ongkirController = TextEditingController();

  bool loading = false;

  Future<void> simpanPelanggan() async {
    if (namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Nama Wajib Diisi!"),
        ),
      );
      return;
    }

    setState(() => loading = true);
    String url = "http://$ipAddress/aplikasi_kasir/api_tambah_pelanggan.php";

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          "nama": namaController.text,
          "hp": hpController.text,
          "alamat": alamatController.text,
          "ongkir": ongkirController.text.isEmpty ? "0" : ongkirController.text,
        },
      );

      // --- DEBUGGING: TAMPILKAN ERROR ASLI ---
      try {
        var data = json.decode(response.body);
        if (data['status'] == 'sukses') {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Pelanggan Berhasil Disimpan!"),
            ),
          );
        } else {
          _showErrorDialog(
            "Gagal Simpan",
            data['pesan'] ?? "Error tidak diketahui",
          );
        }
      } catch (e) {
        // Kalau respon bukan JSON (Error PHP / Server Error 500)
        _showErrorDialog(
          "Server Error",
          "Respon aneh dari server:\n\n${response.body}",
        );
      }
    } catch (e) {
      _showErrorDialog(
        "Koneksi Gagal",
        "Pastikan IP Benar: $ipAddress\n\nDetail: $e",
      );
    }
    setState(() => loading = false);
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(title, style: TextStyle(color: Colors.red)),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
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
          "Pelanggan Baru",
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
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Data Pelanggan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Lengkapi form di bawah ini",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informasi Pribadi",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _inputModern(namaController, "Nama Lengkap", Icons.badge),
                    const SizedBox(height: 15),
                    _inputModern(
                      hpController,
                      "Nomor WhatsApp/HP",
                      Icons.phone_iphone,
                      number: true,
                    ),
                    const SizedBox(height: 15),
                    _inputModern(
                      alamatController,
                      "Alamat Lengkap",
                      Icons.home_filled,
                    ),
                    const SizedBox(height: 15),
                    _inputModern(
                      ongkirController,
                      "Default Ongkir (Rp)",
                      Icons.motorcycle,
                      number: true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : () => simpanPelanggan(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child:
                            loading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  "SIMPAN DATA",
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _inputModern(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool number = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: primaryColor),
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
