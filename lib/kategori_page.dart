import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  List listKategori = [];
  bool loading = true;
  final Color primaryColor = const Color(0xFF005BEA);

  // Controller
  TextEditingController namaController = TextEditingController();

  Future<void> getKategori() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_kategori.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listKategori = json.decode(response.body);
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> tambahKategori() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_tambah_kategori.php";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {"nama_kategori": namaController.text},
      );
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        namaController.clear();
        Navigator.pop(context);
        getKategori();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kategori Ditambah!")));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> hapusKategori(String id) async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_hapus_kategori.php";
    try {
      var response = await http.post(Uri.parse(url), body: {"id": id});
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kategori Dihapus!")));
        getKategori();
      }
    } catch (e) {
      print(e);
    }
  }

  void showDialogInput() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Kategori Baru",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Kategori",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.category, color: primaryColor),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Batal",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => tambahKategori(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Simpan",
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
    getKategori();
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
          "Kategori Produk",
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
                itemCount: listKategori.length,
                itemBuilder: (context, index) {
                  final data = listKategori[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.category_rounded,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              data['kategori'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => hapusKategori(data['kategori_id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: Text(
          "Kategori",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialogInput();
        },
      ),
    );
  }
}
