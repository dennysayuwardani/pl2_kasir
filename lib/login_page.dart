import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Username dan Password wajib diisi!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: username,
      password: password,
    );

    // Memeriksa apakah login berhasil
    if (response.user == null) {
      // Jika pengguna null, berarti login gagal
      _showSnackBar('Login gagal. Periksa username dan password Anda!');
    } else {
      // Login berhasil
      _showSnackBar('Login berhasil!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  } catch (error) {
    // Menangkap kesalahan dan menampilkan pesan yang sesuai
    _showSnackBar('Error: ${error.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
  }

    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    @override
    void dispose() {
      _usernameController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Icon User
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 85,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Selamat Datang",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    // const SizedBox(height: 5),
                    Text(
                      "Silahkan Login",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 45),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Username Field
                        Text(
                          "Username",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ))
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        //Password Field
                        Text(
                          "Password",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              )),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible; // Toggle visibilitas
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 15),
                      ),
                      child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        :Text("Login",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                          )),
                    )
                  ]),
            ),
          ));
    }
  }

