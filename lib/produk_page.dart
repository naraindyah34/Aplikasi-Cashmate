import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_produk.dart';
import 'edit_produk.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List listProduk = [];
  bool loading = true;

  // KONSTANTA WARNA
  final Color primaryColor = const Color(0xFF005BEA);

  Future<void> getProduk() async {
    // ⚠️ IP BARU
    String url = "http://192.168.1.2/aplikasi_kasir/api_produk.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listProduk = json.decode(response.body);
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> hapusProduk(String id) async {
    // ⚠️ IP BARU
    String url = "http://192.168.1.2/aplikasi_kasir/api_hapus_produk.php";
    try {
      var response = await http.post(Uri.parse(url), body: {"id": id});
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Produk Dihapus!")));
        getProduk();
      }
    } catch (e) {
      print(e);
    }
  }

  void konfirmasiHapus(String id, String nama) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Hapus Produk?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text("Yakin ingin menghapus '$nama'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Batal",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  hapusProduk(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Hapus",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    getProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Background Putih Kebiruan
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Katalog Produk",
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
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: listProduk.length,
                itemBuilder: (context, index) {
                  final data = listProduk[index];
                  // ⚠️ IP BARU untuk Gambar
                  String urlFoto =
                      "http://192.168.1.2/aplikasi_kasir/uploads/${data['produk_foto']}";
                  bool adaFoto =
                      data['produk_foto'] != null && data['produk_foto'] != "";
                  int stok = int.parse(data['produk_stok']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // Shadow Biru Muda
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C6FB).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // --- FOTO PRODUK ---
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[50],
                            child:
                                adaFoto
                                    ? Image.network(urlFoto, fit: BoxFit.cover)
                                    : Center(
                                      child: Text(
                                        data['produk_nama'][0],
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                          ),
                        ),

                        // --- INFO PRODUK ---
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['produk_nama'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Rp ${data['produk_harga_jual']}",
                                  style: GoogleFonts.poppins(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Chip Stok Modern
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        stok < 5
                                            ? Colors.redAccent.withOpacity(0.1)
                                            : const Color(
                                              0xFF00C6FB,
                                            ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Stok: $stok",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color:
                                          stok < 5
                                              ? Colors.redAccent
                                              : const Color(0xFF005BEA),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --- TOMBOL AKSI ---
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.orangeAccent,
                              ),
                              onPressed: () async {
                                var refresh = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EditProdukPage(dataProduk: data),
                                  ),
                                );
                                if (refresh == true) getProduk();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed:
                                  () => konfirmasiHapus(
                                    data['produk_id'],
                                    data['produk_nama'],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          "Tambah",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          var refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahProdukPage()),
          );
          if (refresh == true) getProduk();
        },
      ),
    );
  }
}
