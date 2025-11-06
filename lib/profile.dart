import 'dart:io';
import 'package:elearning/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elearning/auth/login.dart';
import 'package:elearning/api/api.dart'; // getUser & updateUser

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _email = '';
  String? _avatarPath; // bisa local file OR network URL
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt("user_id");

    if (_userId == null) return;

    try {
      final user = await getUser(_userId!); // ambil dari API

      setState(() {
        _name = user["name"] ?? "User";
        _email = user["email"] ?? "user@example.com";
        _avatarPath = user["photo_url"]; // URL dari server
        _isLoading = false;
      });

      // Simpan ulang ke prefs biar konsisten
      prefs.setString("user_name", _name);
      prefs.setString("user_email", _email);
      prefs.setString("user_photo", _avatarPath ?? "");
    } catch (e) {
      print("Gagal getUser: $e");
      // fallback ke prefs
      setState(() {
        _name = prefs.getString("user_name") ?? "User";
        _email = prefs.getString("user_email") ?? "user@example.com";
        _avatarPath = prefs.getString("user_photo");
        _isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("user_photo", picked.path);

      await updateUser(_userId!, photoUrl: picked.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto profil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.contains("@") ? null : "Invalid Email",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final newName = nameController.text.trim();
              final newEmail = emailController.text.trim();

              await updateUser(
                _userId!,
                name: newName,
                email: newEmail,
                photoUrl: _avatarPath,
              );

              final prefs = await SharedPreferences.getInstance();
              prefs.setString("user_name", newName);
              prefs.setString("user_email", newEmail);

              setState(() {
                _name = newName;
                _email = newEmail;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profil berhasil diperbarui!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void showChangePasswordDialog() {
    final pass1 = TextEditingController();
    final pass2 = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pass1,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
                validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
              ),
              TextFormField(
                controller: pass2,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
                validator: (v) => v != pass1.text ? "Password not match" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              await updateUser(_userId!, password: pass1.text.trim());

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password berhasil diubah!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 70),
                  Text(
                    'Profil Saya',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  (_avatarPath != null &&
                                      _avatarPath!.isNotEmpty)
                                  ? (_avatarPath!.startsWith('http')
                                        ? NetworkImage(_avatarPath!)
                                        : FileImage(File(_avatarPath!))
                                              as ImageProvider)
                                  : null,
                              child: (_avatarPath == null || _avatarPath == "")
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white70,
                                    )
                                  : null,
                              backgroundColor: const Color.fromARGB(
                                255,
                                210,
                                210,
                                210,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: InkWell(
                                  onTap: pickImage,
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // ... di dalam Row(children: [ ...
                      Expanded(
                        child: SizedBox(
                          height: 45, // Mungkin dinaikkan sedikit
                          child: ElevatedButton(
                            onPressed: showEditProfileDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .secondary, // Tetap biru, sebagai primary action
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Samakan dengan card
                              ),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: OutlinedButton(
                            // Ganti ke OutlinedButton
                            onPressed: showChangePasswordDialog,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.blueGrey,
                                width: 1.5,
                              ), // Warna border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Samakan dengan card
                              ),
                            ),
                            child: const Text(
                              "Change Password",
                              style: TextStyle(color: Colors.blueGrey),
                            ), // Text color
                          ),
                        ),
                      ),
                      // ...
                    ],
                  ),

                  const SizedBox(height: 20),

                  Divider(),
                  const SizedBox(height: 10),

                  // Container(
                  //   padding: const EdgeInsets.only(bottom: 8),
                  //   child: Row(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 8.0,
                  //           horizontal: 12,
                  //         ),
                  //         child: Icon(
                  //           Icons.mail_outline,
                  //           color: Colors.black26,
                  //         ),
                  //       ),
                  //       SizedBox(width: 10),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             "Email",
                  //             style: TextStyle(
                  //               fontSize: 15,
                  //               fontWeight: FontWeight.w400,
                  //               color: const Color.fromARGB(255, 160, 160, 160),
                  //             ),
                  //           ),
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 _email,
                  //                 style: TextStyle(
                  //                   fontSize: 17,
                  //                   fontWeight: FontWeight.w200,
                  //                 ),
                  //               ),
                  //               Container(
                  //                 width:
                  //                     MediaQuery.of(context).size.width - 100,
                  //                 child: const Divider(
                  //                   color: Color.fromARGB(66, 167, 167, 167),
                  //                   thickness: 2,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // Container(
                  //   padding: const EdgeInsets.only(bottom: 8),
                  //   child: Row(
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 8.0,
                  //           horizontal: 12,
                  //         ),
                  //         child: Icon(
                  //           Icons.mail_outline,
                  //           color: Colors.black26,
                  //         ),
                  //       ),
                  //       SizedBox(width: 10),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             "Email",
                  //             style: TextStyle(
                  //               fontSize: 15,
                  //               fontWeight: FontWeight.w400,
                  //               color: const Color.fromARGB(255, 160, 160, 160),
                  //             ),
                  //           ),
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 _email,
                  //                 style: TextStyle(
                  //                   fontSize: 17,
                  //                   fontWeight: FontWeight.w200,
                  //                 ),
                  //               ),
                  //               Container(
                  //                 width:
                  //                     MediaQuery.of(context).size.width - 100,
                  //                 child: const Divider(
                  //                   color: Color.fromARGB(66, 167, 167, 167),
                  //                   thickness: 2,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kesan & Pesan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Selama mengikuti mata kuliah Pemrograman Aplikasi Mobile, saya merasa mendapatkan pengalaman belajar yang sangat berharga. ..."
                          "\n\nSaya berterima kasih kepada dosen dan teman-teman yang telah membantu dalam proses belajar ini. Harapannya, ke depannya pembelajaran dapat diberikan lebih banyak contoh penerapan dalam konteks project nyata sehingga mahasiswa bisa lebih siap menghadapi kasus pengembangan aplikasi yang sesungguhnya.",
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
    );
  }
}
