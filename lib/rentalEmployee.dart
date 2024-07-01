import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RentalCheckInOutPage extends StatefulWidget {
  final String jobDesk;
  final Map<String, dynamic> userData;

  RentalCheckInOutPage({required this.jobDesk, required this.userData});

  @override
  _RentalCheckInOutPageState createState() => _RentalCheckInOutPageState();
}

class _RentalCheckInOutPageState extends State<RentalCheckInOutPage> {
  String _timeString = '00:00:00';
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedShift;
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _startTimer();
    tz.initializeTimeZones();
    print('Profile image URL: ${widget.userData['image']}'); // Debug URL gambar
    print('User ID: ${widget.userData['id']}'); // Debug ID user
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _startClock() {
    setState(() {
      _stopwatch.start();
    });
  }

  void _stopClock() {
    setState(() {
      _stopwatch.stop();
    });
  }

  void _resetClock() {
    setState(() {
      _stopwatch.reset();
      _timeString = '00:00:00';
    });
  }

  void _updateTime() {
    final int seconds = _stopwatch.elapsed.inSeconds;
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;
    setState(() {
      _timeString =
          '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void scheduleNotifications(DateTime checkInTime, String shift) {
    List<DateTime> notificationTimes = [];

    if (shift == '6661cc7d1a9531aff2b656c3') {
      // Shift Morning
      notificationTimes = [
        DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 15, 45),
        DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 16, 00),
      ];
    } else if (shift == '6661d425f8e471a74829e25c') {
      // Shift Afternoon
      notificationTimes = [
        DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 21, 45),
        DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 22, 00),
      ];
    }

    for (DateTime notificationTime in notificationTimes) {
      if (notificationTime.isAfter(DateTime.now())) {
        flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Reminder',
          'It\'s almost time to check out!',
          tz.TZDateTime.from(notificationTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              // 'your_channel_description',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: false,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  void _submitAttendance(bool isCheckOut) async {
    final String url = isCheckOut
        ? 'http://10.0.2.2:5000/api/attendance/checkout'
        : 'http://10.0.2.2:5000/api/attendance/checkin';
    final DateTime now = DateTime.now();
    final Map<String, dynamic> data = {
      'userID': widget.userData['id'],
      'date': DateFormat('yyyy-MM-dd').format(now),
      'notes': _notesController.text,
    };

    if (isCheckOut) {
      data['checkOut'] = now.toIso8601String();
    } else {
      data['checkIn'] = now.toIso8601String();
      data['userRole'] = 'Rental Employees'; // Sesuaikan dengan role yang digunakan
      data['jobdesk'] = widget.jobDesk;
      data['shiftIDs'] = [_selectedShift];
      data['branch'] = _selectedBranch;

      // Tentukan waktu check-out otomatis berdasarkan shift
      if (_selectedShift == '6661cc7d1a9531aff2b656c3') {
        // Shift Morning - Check-out otomatis pukul 16:00
        DateTime checkOutTime =
            DateTime(now.year, now.month, now.day, 16, 0, 0);
        int secondsUntilCheckOut = checkOutTime.difference(now).inSeconds;
        _timer = Timer(Duration(seconds: secondsUntilCheckOut), () {
          _stopClock();
          _resetClock();
          _submitAttendance(true); // Lakukan check-out otomatis
        });
      } else if (_selectedShift == '6661d425f8e471a74829e25c') {
        // Shift Afternoon - Check-out otomatis pukul 22:00
        DateTime checkOutTime =
            DateTime(now.year, now.month, now.day, 22, 0, 0);
        int secondsUntilCheckOut = checkOutTime.difference(now).inSeconds;
        _timer = Timer(Duration(seconds: secondsUntilCheckOut), () {
          _stopClock();
          _resetClock();
          _submitAttendance(true); // Lakukan check-out otomatis
        });
      }
      scheduleNotifications(now, _selectedShift!);
    }

    print('Data to be sent: $data');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Attendance recorded successfully.');
        if (isCheckOut) {
          _stopClock();
          _resetClock();
        }
      } else {
        print('Failed to record attendance: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height:
                            255, // Increased height to accommodate all content
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 204, 128, 0.05),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(Icons.logout,
                                    color: Color(0xFFFF7200)),
                                onPressed: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 70,
                                    backgroundImage: widget.userData['image'] !=
                                                null &&
                                            widget.userData['image'].isNotEmpty
                                        ? NetworkImage(widget.userData['image'])
                                        : AssetImage(
                                                'assets/images/profile.png')
                                            as ImageProvider,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    (widget.userData['fullName'] ?? 'User Name')
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.jobDesk,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w600, // Semi-bold
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, -1),
                                blurRadius: 2,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 1), // Adjust spacing as needed
                        Center(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                    color: Color(0xFFE66700),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _timeString,
                                style: TextStyle(
                                    fontSize: 45, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Shift Selection:',
                            labelStyle: TextStyle(
                                color: Color(0xFF000000).withOpacity(0.3)),
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
                          items: [
                            DropdownMenuItem<String>(
                              value: '6661cc7d1a9531aff2b656c3',
                              child: Text('Morning'),
                            ),
                            DropdownMenuItem<String>(
                              value: '6661d425f8e471a74829e25c',
                              child: Text('Afternoon'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedShift = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Branch:',
                            labelStyle: TextStyle(
                                color: Color(0xFF000000).withOpacity(0.3)),
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
                          items: [
                            DropdownMenuItem<String>(
                              value: '666df520c7cd6a48918135e5',
                              child: Text('iFrame Jogokarian'),
                            ),
                            DropdownMenuItem<String>(
                              value: '666dd3d107116854903e0cf3',
                              child: Text('iFrame Laptop'),
                            ),
                            DropdownMenuItem<String>(
                              value: '666dd3e607116854903e0cf5',
                              child: Text('iFrame Jasa'),
                            ),
                            DropdownMenuItem<String>(
                              value: '666dd3f507116854903e0cf7',
                              child: Text('iFrame Palagan'),
                            ),
                            DropdownMenuItem<String>(
                              value: '666dd40507116854903e0cf9',
                              child: Text('iFrame Kusumanegara'),
                            ),
                            DropdownMenuItem<String>(
                              value: '666df47ec7cd6a48918135e1',
                              child: Text('iFrame Condongcatur'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedBranch = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes:',
                            labelStyle: TextStyle(
                                color: Color(0xFF000000).withOpacity(0.3)),
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
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF05B92C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side:
                                BorderSide(color: Color(0xFF008A27), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (!_stopwatch.isRunning) {
                              _startClock();
                              _submitAttendance(false);
                            }
                          },
                          child: Text(
                            'Check In',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600, // Poppins-SemiBold
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF7200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side:
                                BorderSide(color: Color(0xFFB35100), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (_stopwatch.isRunning) {
                              _stopClock();
                              _submitAttendance(true);
                            }
                          },
                          child: Text(
                            'Check Out',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600, // Poppins-SemiBold
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
