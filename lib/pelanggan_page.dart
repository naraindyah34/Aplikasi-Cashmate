import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
// Import halaman tambah agar tombol berfungsi
import 'tambah_pelanggan.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  // --- KONFIGURASI WARNA & IP ---
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  // ⚠️ IP 1.2
  final String ipAddress = "192.168.1.2";

  List listPelanggan = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getPelanggan();
  }

  // --- AMBIL DATA PELANGGAN ---
  Future<void> getPelanggan() async {
    String url = "http://$ipAddress/aplikasi_kasir/api_pelanggan.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        loading = false;
        var data = json.decode(response.body);
        // Pastikan data berbentuk List
        listPelanggan = (data is List) ? data : [];
      });
    } catch (e) {
      print(e);
      setState(() => loading = false);
    }
  }

  // --- FUNGSI HAPUS (Optional) ---
  Future<void> hapusPelanggan(String id) async {
    // Pastikan ada file api_hapus_pelanggan.php jika mau dipakai
    String url = "http://$ipAddress/aplikasi_kasir/api_hapus_pelanggan.php";
    try {
      var response = await http.post(Uri.parse(url), body: {"id": id});
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        getPelanggan();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pelanggan Dihapus")));
      }
    } catch (e) {
      print(e);
    }
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
          "Daftar Pelanggan",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // TOMBOL TAMBAH
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: primaryColor),
            tooltip: "Tambah Pelanggan",
            onPressed: () async {
              // Pindah ke halaman Tambah
              var refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahPelangganPage(),
                ),
              );

              // Jika berhasil simpan (dapat nilai true), refresh data
              if (refresh == true) {
                setState(() => loading = true);
                getPelanggan();
              }
            },
          ),
        ],
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : listPelanggan.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 60,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Belum ada data pelanggan",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: listPelanggan.length,
                itemBuilder: (context, index) {
                  final data = listPelanggan[index];

                  // --- PERBAIKAN BACA NAMA KOLOM (SESUAI DB KAMU) ---
                  // Prioritas: 'Nama' -> 'pelanggan_nama' -> 'nama'
                  String nama =
                      data['Nama'] ??
                      data['pelanggan_nama'] ??
                      data['nama'] ??
                      "Tanpa Nama";
                  String hp =
                      data['nomor_hp'] ??
                      data['pelanggan_hp'] ??
                      data['hp'] ??
                      "-";
                  String alamat =
                      data['Alamat'] ??
                      data['pelanggan_alamat'] ??
                      data['alamat'] ??
                      "-";
                  String ongkir = data['saran_ongkir'] ?? "0";
                  String id =
                      data['id']?.toString() ??
                      data['id_pelanggan']?.toString() ??
                      "";

                  // Ambil Inisial untuk Avatar
                  String inisial =
                      nama.isNotEmpty ? nama[0].toUpperCase() : "?";

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
                        // AVATAR
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            inisial,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // INFO TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_iphone_rounded,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    hp,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      alamat,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // HARGA ONGKIR & TOMBOL DELETE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Rp $ongkir",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Tombol Hapus (Optional)
                            InkWell(
                              onTap: () {
                                // Konfirmasi Hapus
                                showDialog(
                                  context: context,
                                  builder:
                                      (c) => AlertDialog(
                                        title: const Text("Hapus?"),
                                        content: Text("Hapus pelanggan $nama?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(c),
                                            child: const Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(c);
                                              hapusPelanggan(id);
                                            },
                                            child: const Text(
                                              "Hapus",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
