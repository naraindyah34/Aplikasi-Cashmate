import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List listUser = [];
  bool loading = true;
  // Warna Electric
  final Color primaryColor = const Color(0xFF005BEA);

  // Form Controller
  TextEditingController namaController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String levelTerpilih = "kasir";

  Future<void> getUser() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_user.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        listUser = json.decode(response.body);
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> tambahUser() async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_tambah_user.php";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          "nama": namaController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "level": levelTerpilih,
        },
      );
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        namaController.clear();
        usernameController.clear();
        passwordController.clear();
        Navigator.pop(context);
        getUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Berhasil Ditambah!")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> hapusUser(String id) async {
    // ⚠️ IP 1.2
    String url = "http://192.168.1.2/aplikasi_kasir/api_hapus_user.php";
    try {
      var response = await http.post(Uri.parse(url), body: {"id": id});
      var data = json.decode(response.body);
      if (data['status'] == 'sukses') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User Dihapus!")));
        getUser();
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
              "Hapus User?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text("Yakin ingin menghapus akses '$nama'?"),
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
                  hapusUser(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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

  void showDialogTambah() {
    levelTerpilih = "kasir";
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Tambah User",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputSimple(namaController, "Nama Lengkap", Icons.badge),
                    const SizedBox(height: 10),
                    _inputSimple(usernameController, "Username", Icons.person),
                    const SizedBox(height: 10),
                    _inputSimple(
                      passwordController,
                      "Password",
                      Icons.lock,
                      secure: true,
                    ),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: levelTerpilih,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: "admin",
                              child: Text("Admin (Full Akses)"),
                            ),
                            DropdownMenuItem(
                              value: "kasir",
                              child: Text("Kasir (Terbatas)"),
                            ),
                          ],
                          onChanged: (val) {
                            setStateDialog(() {
                              levelTerpilih = val!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
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
                  onPressed: () => tambahUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text(
                    "Simpan",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _inputSimple(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool secure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: secure,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUser();
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
          "Kelola Pengguna",
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
                itemCount: listUser.length,
                itemBuilder: (context, index) {
                  final data = listUser[index];
                  String level = data['level'] ?? 'kasir';
                  bool isAdmin = level == 'admin';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              isAdmin
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: isAdmin ? primaryColor : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['user_nama'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "@${data['user_username']}",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge Level & Delete
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isAdmin
                                        ? Colors.blue[50]
                                        : Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                level.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? Colors.blue : Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                if (data['user_id'] == '1') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Admin Utama tidak boleh dihapus!",
                                      ),
                                    ),
                                  );
                                } else {
                                  konfirmasiHapus(
                                    data['user_id'],
                                    data['user_nama'],
                                  );
                                }
                              },
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
        icon: const Icon(Icons.person_add),
        label: Text(
          "User Baru",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialogTambah();
        },
      ),
    );
  }
}
