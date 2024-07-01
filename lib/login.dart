import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'jasaEmployee.dart';
import 'rentalEmployee.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _timeString = '';
  bool _obscureText = true;
  String? _selectedEmployeeType;
  String? _selectedJobDesk;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, dynamic>? _userData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Input Error', 'Email and password cannot be empty.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/users/login'), // Gunakan 10.0.2.2 untuk emulator Android
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userName': email, // Ubah sesuai dengan field yang digunakan di backend
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _userData = responseData['user'];
          if (_userData != null) {
            // Simpan URL gambar lengkap jika ada
            if (_userData!['image'] != null) {
              _userData!['image'] = 'http://10.0.2.2:5000' + _userData!['image'];
            }
          }
        });
        print('Login successful: $_userData');
        print('Profile image URL: ${_userData!['image']}'); // Debug URL gambar
        print('User ID: ${_userData!['id']}'); // Debug ID user

        // Navigasi ke halaman yang sesuai dan hapus semua rute sebelumnya
        if (_selectedEmployeeType == 'Rental Employees') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RentalCheckInOutPage(
                jobDesk: _selectedJobDesk ?? 'Customer Service',
                userData: _userData!,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else if (_selectedEmployeeType == 'Service Employees') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceCheckInOutPage(
                jobDesk: _selectedJobDesk ?? 'Customer Service',
                userData: _userData!,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else if (response.statusCode == 400) {
        print('Login failed: Invalid username or password');
        _showDialog('Login Failed', 'Invalid username or password.');
      } else if (response.statusCode == 404) {
        print('Login failed: Account not registered');
        _showDialog('Login Failed', 'Account not registered.');
      } else {
        print('Login failed: Unexpected error');
        _showDialog('Login Failed', 'An unexpected error occurred.');
      }
    } catch (e) {
      print('Error: $e');
      _showDialog('Login Failed', 'An error occurred while trying to login.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(now);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 55.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 288,
                        height: 108,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                          color: Color(0xFFE66700),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _timeString,
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.email, color: Color(0xFF000000)),
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF000000).withOpacity(0.3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(255, 255, 255, 0.85),
                ),
              ),
              SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  prefixIcon: Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.lock, color: Color(0xFF000000)),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF000000).withOpacity(0.3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(255, 255, 255, 0.85),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
              ),
              SizedBox(height: 14),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Opacity(
                        opacity: 0.3,
                        child: Icon(Icons.work, color: Color(0xFF000000)),
                      ),
                      labelText: 'Job Desk',
                      labelStyle: TextStyle(color: Color(0xFF000000).withOpacity(0.3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFE66700)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFE66700)),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 0.85),
                    ),
                    isExpanded: true,
                    items: <String>[
                      'Pelaksana Project',
                      'Marketing',
                      'Customer Service',
                      'Maintenance'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          width: constraints.maxWidth - 48,
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedJobDesk = newValue;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 14),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  prefixIcon: Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.person, color: Color(0xFF000000)),
                  ),
                  labelText: 'Select Employee',
                  labelStyle: TextStyle(color: Color(0xFF000000).withOpacity(0.3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE66700)),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(255, 255, 255, 0.85),
                ),
                isExpanded: true,
                items: <String>[
                  'Rental Employees',
                  'Service Employees'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEmployeeType = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE66700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _login,
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600, // Poppins-SemiBold
                      color: Color.fromARGB(255, 255, 255, 255), 
                      fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
