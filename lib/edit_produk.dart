import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class EditProdukPage extends StatefulWidget {
  final Map dataProduk;
  const EditProdukPage({super.key, required this.dataProduk});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  // ⚠️ PASTIKAN IP SAMA (1.2)
  final String ipAddress = "192.168.1.2";

  final Color primaryColor = const Color(0xFF005BEA);
  final Color bgColor = const Color(0xFFF4F7FE);

  TextEditingController kodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController stokController = TextEditingController();

  File? image;
  List listKategori = [];
  String? kategoriTerpilih;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // --- PENGAMAN ANTI LAYAR MERAH ---
    // Pakai ?.toString() ?? "" untuk mencegah nilai NULL masuk ke controller
    kodeController.text = widget.dataProduk['produk_kode']?.toString() ?? "";
    namaController.text = widget.dataProduk['produk_nama']?.toString() ?? "";
    hargaBeliController.text =
        widget.dataProduk['produk_harga_modal']?.toString() ?? "0";
    hargaJualController.text =
        widget.dataProduk['produk_harga_jual']?.toString() ?? "0";
    stokController.text = widget.dataProduk['produk_stok']?.toString() ?? "0";

    // Ambil ID Kategori awal (jika ada)
    kategoriTerpilih = widget.dataProduk['produk_kategori']?.toString();

    getKategori();
  }

  Future<void> getKategori() async {
    String url = "http://$ipAddress/aplikasi_kasir/api_kategori.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        var data = json.decode(response.body);
        listKategori = (data is List) ? data : [];
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> pilihGambar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> updateProduk() async {
    setState(() => loading = true);
    String url = "http://$ipAddress/aplikasi_kasir/api_edit_produk.php";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['id'] = widget.dataProduk['produk_id'].toString();
      request.fields['kode'] = kodeController.text;
      request.fields['nama'] = namaController.text;
      request.fields['kategori'] = kategoriTerpilih ?? "";
      request.fields['harga_beli'] = hargaBeliController.text;
      request.fields['harga_jual'] = hargaJualController.text;
      request.fields['stok'] = stokController.text;

      // OBAT DATABASE REWEL (Kirim data dummy)
      request.fields['satuan'] = "Pcs";
      request.fields['keterangan'] = "-";

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', image!.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      try {
        var data = json.decode(responseBody);
        if (data['status'] == 'sukses') {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Produk Berhasil Diupdate!"),
            ),
          );
        } else {
          _showDialog("Gagal Update", data['pesan'] ?? "Error tidak diketahui");
        }
      } catch (e) {
        _showDialog("Server Error", responseBody);
      }
    } catch (e) {
      _showDialog("Koneksi Gagal", "Cek IP: $ipAddress\nError: $e");
    }
    setState(() => loading = false);
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: Text(title),
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
    String fotoLama = widget.dataProduk['produk_foto'] ?? "";
    String urlFotoLama = "http://$ipAddress/aplikasi_kasir/uploads/$fotoLama";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Edit Produk",
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
            GestureDetector(
              onTap: () => pilihGambar(),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image:
                      image != null
                          ? DecorationImage(
                            image: FileImage(image!),
                            fit: BoxFit.cover,
                          )
                          : (fotoLama != ""
                              ? DecorationImage(
                                image: NetworkImage(urlFotoLama),
                                fit: BoxFit.cover,
                              )
                              : null),
                ),
                child: Stack(
                  children: [
                    if (image == null && fotoLama == "")
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            Text(
                              "Upload Foto",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 5, color: Colors.black12),
                          ],
                        ),
                        child: Icon(Icons.edit, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Informasi",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _inputModern(kodeController, "Kode Barang", Icons.qr_code),
                    const SizedBox(height: 15),
                    _inputModern(
                      namaController,
                      "Nama Produk",
                      Icons.shopping_bag,
                    ),
                    const SizedBox(height: 15),

                    // Dropdown Kategori Aman
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FE),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: kategoriTerpilih,
                          isExpanded: true,
                          hint: Text(
                            "Pilih Kategori",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          items:
                              listKategori.map((item) {
                                String nama =
                                    item['nama_kategori'] ??
                                    item['kategori_nama'] ??
                                    item['kategori'] ??
                                    "-";
                                String id =
                                    item['kategori_id']?.toString() ??
                                    item['id_kategori']?.toString() ??
                                    "";
                                return DropdownMenuItem(
                                  value: id,
                                  child: Text(
                                    nama,
                                    style: GoogleFonts.poppins(),
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              kategoriTerpilih = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _inputModern(
                            hargaBeliController,
                            "Harga Beli",
                            Icons.attach_money,
                            number: true,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _inputModern(
                            hargaJualController,
                            "Harga Jual",
                            Icons.sell,
                            number: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _inputModern(
                      stokController,
                      "Stok Saat Ini",
                      Icons.inventory_2,
                      number: true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : () => updateProduk(),
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
                                  "UPDATE PRODUK",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
          prefixIcon: Icon(icon, color: Colors.blueGrey),
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
