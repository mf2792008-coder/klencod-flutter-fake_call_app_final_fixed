import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const FakeCallApp());
}

class FakeCallApp extends StatelessWidget {
  const FakeCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Call App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'أحمد محمد');
  final TextEditingController _numberController = TextEditingController(text: '01012345678');
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isScheduled = false;
  Timer? _scheduleTimer;

  void _startInstantCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RingingScreen(
          callerName: _nameController.text,
          callerNumber: _numberController.text,
        ),
      ),
    );
  }

  void _scheduleCall() {
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    var difference = scheduledDateTime.difference(now);
    if (difference.isNegative) {
      difference = difference + const Duration(days: 1);
    }

    setState(() {
      _isScheduled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم جدولة المكالمة بعد ${difference.inMinutes} دقيقة')),
    );

    _scheduleTimer?.cancel();
    _scheduleTimer = Timer(difference, () {
      if (mounted) {
        setState(() {
          _isScheduled = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RingingScreen(
              callerName: _nameController.text,
              callerNumber: _numberController.text,
            ),
          ),
        );
      }
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق الاتصالات الوهمية'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phone_android, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتصل الوهمي',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                'جدولة مكالمة واردة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'وقت المكالمة: ${_selectedTime.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text('اختر الوقت'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScheduled ? Colors.orange : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isScheduled ? null : _scheduleCall,
                child: Text(
                  _isScheduled ? 'المكالمة مجدولة الآن...' : 'تفعيل الجدولة',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _startInstantCall,
                icon: const Icon(Icons.call),
                label: const Text('اتصال وهمي فوري الآن', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RingingScreen extends StatelessWidget {
  final String callerName;
  final String callerNumber;

  const RingingScreen({
    super.key,
    required this.callerName,
    required this.callerNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'مكالمة واردة وهمية',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    callerName,
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    callerNumber,
                    style: const TextStyle(color: Colors.white60, fontSize: 20),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'reject',
                        backgroundColor: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text('رفض', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'accept',
                        backgroundColor: Colors.green,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActiveCallScreen(
                                callerName: callerName,
                                callerNumber: callerNumber,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.call, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text('رد', style: TextStyle(color: Colors.white)),
                    ],
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

class ActiveCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const ActiveCallScreen({
    super.key,
    required this.callerName,
    required this.callerNumber,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    widget.callerName,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(_secondsElapsed),
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 22),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.mic_off, color: Colors.white, size: 30),
                  Icon(Icons.volume_up, color: Colors.white, size: 30),
                  Icon(Icons.pause, color: Colors.white, size: 30),
                ],
              ),
              FloatingActionButton(
                heroTag: 'endCall',
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.call_end, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}