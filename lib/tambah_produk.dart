import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  // --- KONFIGURASI IP ---
  final String ipAddress = "192.168.1.2";

  // Warna Tema
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  // Controllers
  TextEditingController kodeController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hargaBeliController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController stokController = TextEditingController();

  File? image;
  List listKategori = [];
  String? kategoriTerpilih;
  bool loading = false;
  bool loadingKategori = true;

  @override
  void initState() {
    super.initState();
    getKategori();
  }

  // 1. AMBIL KATEGORI
  Future<void> getKategori() async {
    setState(() => loadingKategori = true);
    String url = "http://$ipAddress/aplikasi_kasir/api_kategori.php";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          listKategori = (data is List) ? data : [];
          loadingKategori = false;
        });
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      print("Error Kategori: $e");
      setState(() => loadingKategori = false);
    }
  }

  // 2. PILIH GAMBAR
  Future<void> pilihGambar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  // 3. SIMPAN PRODUK
  Future<void> simpanProduk() async {
    if (namaController.text.isEmpty || kategoriTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Nama & Kategori Wajib Diisi!"),
        ),
      );
      return;
    }

    setState(() => loading = true);
    String url = "http://$ipAddress/aplikasi_kasir/api_tambah_produk.php";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['kode'] =
          kodeController.text.isEmpty ? "000" : kodeController.text;
      request.fields['nama'] = namaController.text;
      request.fields['kategori'] = kategoriTerpilih!;
      request.fields['harga_beli'] =
          hargaBeliController.text.isEmpty ? "0" : hargaBeliController.text;
      request.fields['harga_jual'] =
          hargaJualController.text.isEmpty ? "0" : hargaJualController.text;
      request.fields['stok'] =
          stokController.text.isEmpty ? "0" : stokController.text;
      request.fields['satuan'] = "Pcs";

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
              content: Text("Produk Berhasil Disimpan!"),
            ),
          );
        } else {
          _showDialog("Gagal", data['pesan'] ?? "Gagal menyimpan");
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
            content: Text(content),
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
      // AppBar Transparan biar nyatu sama gambar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Tambah Produk",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [const Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. AREA FOTO LENGKUNG (HERO) ---
            GestureDetector(
              onTap: () => pilihGambar(),
              child: Container(
                width: double.infinity,
                height: 320, // Lebih tinggi biar lega
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  // LENGKUNGAN BAWAH YANG CANTIK
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  image:
                      image != null
                          ? DecorationImage(
                            image: FileImage(image!),
                            fit: BoxFit.cover,
                          )
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:
                    image == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tombol Kamera Putih Mengkilap
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                size: 40,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Tap untuk Foto Produk",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Stack(
                          children: [
                            // Tombol Ganti Foto Kecil di Pojok
                            Positioned(
                              bottom: 30,
                              right: 30,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.edit, color: primaryColor),
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            // --- 2. FORM KARTU MENGAMBANG ---
            Transform.translate(
              offset: const Offset(
                0,
                -40,
              ), // Naikkan ke atas biar menumpuk foto
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ), // Kasih jarak kiri kanan biar 'floating'
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Rounded semua sisi
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detail Informasi",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _inputModern(
                        kodeController,
                        "Kode Barang",
                        Icons.qr_code,
                      ),
                      const SizedBox(height: 15),
                      _inputModern(
                        namaController,
                        "Nama Produk",
                        Icons.shopping_bag,
                      ),
                      const SizedBox(height: 15),

                      // Dropdown
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
                                listKategori.isEmpty
                                    ? null
                                    : listKategori.map((item) {
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
                        "Stok Awal",
                        Icons.inventory_2,
                        number: true,
                      ),

                      const SizedBox(height: 30),

                      // Tombol Simpan Gradient
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: loading ? null : () => simpanProduk(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
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
                                    "SIMPAN SEKARANG",
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
            ),
            const SizedBox(height: 20),
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
