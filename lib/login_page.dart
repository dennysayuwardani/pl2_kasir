import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pl2_kasir/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Untuk mengontrol visibilitas password
  bool _isLoading = false; // Untuk mengontrol loading state

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      // Query ke Supabase untuk validasi user
      final response = await supabase
          .from('user')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        // Login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // Login gagal
        _showSnackBar('Invalid username or password');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
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
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 85, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text("Selamat Datang", style: _textStyle(24, FontWeight.bold)),
              Text("Silahkan Login", style: _textStyle(16, FontWeight.normal)),
              const SizedBox(height: 45),
              _buildTextField("Username", _usernameController),
              const SizedBox(height: 10),
              _buildPasswordField(),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Login", style: GoogleFonts.poppins(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(double fontSize, FontWeight fontWeight) {
    return GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: Colors.blue);
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _textStyle(16, FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", style: _textStyle(16, FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
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
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ],
          ),
        ),
      ],
    );
  }
}