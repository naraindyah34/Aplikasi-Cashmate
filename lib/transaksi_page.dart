import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  // --- KONSTANTA WARNA ---
  final Color primaryColor = const Color(0xFF005BEA);
  final Color secondaryColor = const Color(0xFF00C6FB);
  final Color bgColor = const Color(0xFFF4F7FE);

  // Variable Data
  List listProdukAsli = [];
  List listProdukDisplay = [];
  List listPelanggan = [];
  bool loading = true;
  int totalBayar = 0;
  int totalItemCart = 0;

  // Input Controller
  TextEditingController searchController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController ongkirController = TextEditingController();

  // Status Transaksi
  String tipeTransaksi = "Offline";
  String? pelangganTerpilih;
  String namaPelanggan = "Umum";

  // --- 1. AMBIL DATA ---
  Future<void> getProduk() async {
    // ⚠️ IP BARU
    String url = "http://192.168.1.2/aplikasi_kasir/api_produk.php";
    try {
      var response = await http.get(Uri.parse(url));
      var data = json.decode(response.body);
      for (var i = 0; i < data.length; i++) {
        data[i]['qty'] = 0;
      }
      setState(() {
        listProdukAsli = data;
        listProdukDisplay = data;
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPelanggan() async {
    String url = "http://192.168.1.2/aplikasi_kasir/api_pelanggan.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listPelanggan = json.decode(response.body);
      });
    } catch (e) {
      print(e);
    }
  }

  void runFilter(String keyword) {
    List results = [];
    if (keyword.isEmpty) {
      results = listProdukAsli;
    } else {
      results =
          listProdukAsli
              .where(
                (item) => item["produk_nama"].toLowerCase().contains(
                  keyword.toLowerCase(),
                ),
              )
              .toList();
    }
    setState(() {
      listProdukDisplay = results;
    });
  }

  // --- 2. LOGIKA KERANJANG ---
  void updateCart(String idProduk, int delta) {
    setState(() {
      int index = listProdukAsli.indexWhere(
        (item) => item['produk_id'] == idProduk,
      );
      if (index != -1) {
        int currentQty = listProdukAsli[index]['qty'];
        int stock = int.parse(listProdukAsli[index]['produk_stok']);

        if (delta > 0 && currentQty >= stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Stok Habis Bos!", style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 500),
            ),
          );
          return;
        }

        listProdukAsli[index]['qty'] += delta;
        if (listProdukAsli[index]['qty'] < 0) listProdukAsli[index]['qty'] = 0;

        hitungTotal();
      }
    });
  }

  void hitungTotal() {
    int tempTotal = 0;
    int tempQty = 0;
    for (var item in listProdukAsli) {
      int qty = item['qty'];
      int harga = int.parse(item['produk_harga_jual'].toString());
      tempTotal += (qty * harga);
      tempQty += qty;
    }
    setState(() {
      totalBayar = tempTotal;
      totalItemCart = tempQty;
    });
  }

  // --- 3. PROSES BAYAR ---
  Future<void> prosesBayar() async {
    int nilaiDiskon =
        diskonController.text.isEmpty ? 0 : int.parse(diskonController.text);
    int nilaiOngkir =
        ongkirController.text.isEmpty ? 0 : int.parse(ongkirController.text);
    if (tipeTransaksi == 'Offline') nilaiOngkir = 0;

    List barangDibeli = [];
    for (var item in listProdukAsli) {
      if (item['qty'] > 0) {
        barangDibeli.add({
          "produk_id": item['produk_id'],
          "harga": item['produk_harga_jual'],
          "qty": item['qty'],
        });
      }
    }

    var dataKirim = {
      "total_bayar": totalBayar,
      "diskon": nilaiDiskon,
      "ongkir": nilaiOngkir,
      "tipe": tipeTransaksi,
      "pelanggan_nama": namaPelanggan,
      "items": barangDibeli,
    };

    String url = "http://192.168.1.2/aplikasi_kasir/api_transaksi.php";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dataKirim),
      );
      var hasil = jsonDecode(response.body);

      if (hasil['status'] == 'sukses') {
        Navigator.pop(context);

        // DIALOG SUKSES
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.green,
                      size: 70,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Transaksi Berhasil!",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total: Rp ${(totalBayar + nilaiOngkir) - nilaiDiskon}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          getProduk();
                          setState(() {
                            totalBayar = 0;
                            totalItemCart = 0;
                            searchController.clear();
                            diskonController.clear();
                            ongkirController.clear();
                            tipeTransaksi = "Offline";
                            pelangganTerpilih = null;
                            namaPelanggan = "Umum";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          "Transaksi Baru",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  // --- 4. PANEL PEMBAYARAN (SLIDE UP) ---
  void showCheckoutPanel() {
    diskonController.text = "0";
    if (tipeTransaksi == 'Offline') ongkirController.text = "0";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.90, // Hampir Fullscreen
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // --- HEADER BIRU GRADASI (BARU) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 25,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ), // Gradasi Biru
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Konfirmasi Pembayaran",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Rp $totalBayar",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- ISI FORM ---
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(25),
                      children: [
                        // Pilih Pelanggan
                        Text(
                          "Info Pelanggan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: pelangganTerpilih,
                              isExpanded: true,
                              hint: Text(
                                "Pilih Pelanggan",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text("Umum (Bukan Member)"),
                                ),
                                ...listPelanggan.map(
                                  (item) => DropdownMenuItem(
                                    value: item['id'].toString(),
                                    child: Text(
                                      "${item['Nama']} (Ongkir: ${item['saran_ongkir']})",
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setStateSheet(() {
                                  pelangganTerpilih = val as String?;
                                  if (val != null) {
                                    var p = listPelanggan.firstWhere(
                                      (e) => e['id'].toString() == val,
                                    );
                                    namaPelanggan = p['Nama'];
                                    if (tipeTransaksi == 'Online')
                                      ongkirController.text =
                                          p['saran_ongkir'].toString();
                                  } else {
                                    namaPelanggan = "Umum";
                                    ongkirController.text = "0";
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          "Jenis Pesanan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              _buildToggle(
                                "Offline",
                                tipeTransaksi == "Offline",
                                () {
                                  setStateSheet(() {
                                    tipeTransaksi = "Offline";
                                    ongkirController.text = "0";
                                  });
                                },
                              ),
                              _buildToggle(
                                "Online",
                                tipeTransaksi == "Online",
                                () {
                                  setStateSheet(() {
                                    tipeTransaksi = "Online";
                                    if (pelangganTerpilih != null) {
                                      var p = listPelanggan.firstWhere(
                                        (e) =>
                                            e['id'].toString() ==
                                            pelangganTerpilih,
                                      );
                                      ongkirController.text =
                                          p['saran_ongkir'].toString();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Input Tambahan
                        if (tipeTransaksi == 'Online')
                          _buildInput(
                            ongkirController,
                            "Biaya Ongkir",
                            Icons.motorcycle,
                          ),
                        if (tipeTransaksi == 'Online')
                          const SizedBox(height: 15),
                        _buildInput(
                          diskonController,
                          "Potongan Diskon (Rp)",
                          Icons.discount,
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // --- TOMBOL PROSES BAWAH ---
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => prosesBayar(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: Text(
                          "PROSES SEKARANG",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Widget Bantuan
  Widget _buildToggle(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                active
                    ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: active ? primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: secondaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getProduk();
    getPelanggan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Kasir",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => runFilter(val),
                decoration: InputDecoration(
                  hintText: "Cari menu...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // Grid Produk
          Expanded(
            child:
                loading
                    ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemCount: listProdukDisplay.length,
                      itemBuilder: (context, index) {
                        final item = listProdukDisplay[index];
                        String urlFoto =
                            "http://192.168.1.2/aplikasi_kasir/uploads/${item['produk_foto']}";
                        bool adaFoto =
                            item['produk_foto'] != null &&
                            item['produk_foto'] != "";
                        int stock = int.parse(item['produk_stok']);
                        int qty = item['qty'];
                        bool isActive = qty > 0;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                isActive
                                    ? Border.all(color: primaryColor, width: 2)
                                    : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey[50],
                                        child:
                                            adaFoto
                                                ? Image.network(
                                                  urlFoto,
                                                  fit: BoxFit.cover,
                                                )
                                                : Center(
                                                  child: Icon(
                                                    Icons.fastfood,
                                                    size: 40,
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                      ),
                                    ),
                                    if (stock < 5)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            "Sisa $stock",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['produk_nama'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "Rp ${item['produk_harga_jual']}",
                                            style: GoogleFonts.poppins(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      isActive
                                          ? Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                IconButton(
                                                  onPressed:
                                                      () => updateCart(
                                                        item['produk_id'],
                                                        -1,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                                Text(
                                                  "$qty",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed:
                                                      () => updateCart(
                                                        item['produk_id'],
                                                        1,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          )
                                          : SizedBox(
                                            width: double.infinity,
                                            height: 35,
                                            child: OutlinedButton(
                                              onPressed:
                                                  () => updateCart(
                                                    item['produk_id'],
                                                    1,
                                                  ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: primaryColor,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                              child: Text(
                                                "Tambah",
                                                style: GoogleFonts.poppins(
                                                  color: primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
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
                        );
                      },
                    ),
          ),
        ],
      ),

      // Floating Checkout Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          totalItemCart > 0
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => showCheckoutPanel(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$totalItemCart Item",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Rp $totalBayar",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Bayar",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
