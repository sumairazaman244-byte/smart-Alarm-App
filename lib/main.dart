import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartAlarmApp());
}

class SmartAlarmApp extends StatelessWidget {
  const SmartAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Alarm App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        primaryColor: const Color(0xFFEE5353),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE5353),
          primary: const Color(0xFFEE5353),
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

// ==================== MAIN HOME SCREEN ====================
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> alarms = [
    {'time': '6:20', 'period': 'AM', 'isActive': true, 'sound': 'Jungle Morning'},
    {'time': '5:00', 'period': 'AM', 'isActive': true, 'sound': 'Ceramic'},
    {'time': '7:00', 'period': 'AM', 'isActive': false, 'sound': 'Rooster Crow'},
  ];

  void _addNewAlarm(Map<String, dynamic> newAlarm) {
    setState(() {
      alarms.add(newAlarm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Alarm',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Color(0xFFEE5353)),
            tooltip: 'Test Wake-up Challenge',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WakeUpChallengeScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onSelect: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildTabPill('ALARM', 0),
                  _buildTabPill('TIMER', 1),
                  _buildTabPill('STOPWATCH', 2),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  AlarmTabContent(
                    alarms: alarms,
                    onToggle: (index, val) {
                      setState(() {
                        alarms[index]['isActive'] = val;
                      });
                    },
                    onAddPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SetAlarmScreen()),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        _addNewAlarm(result);
                      }
                    },
                    onEditAlarm: (index) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditAlarmScreen(alarmData: alarms[index])),
                      );
                      if (result == 'DELETE') {
                        setState(() {
                          alarms.removeAt(index);
                        });
                      } else if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          alarms[index] = result;
                        });
                      }
                    },
                  ),
                  const Center(child: Text('Timer Feature Coming Soon', style: TextStyle(color: Colors.grey))),
                  const StopwatchTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SIDE DRAWER ====================
class AppDrawer extends StatelessWidget {
  final Function(int) onSelect;
  const AppDrawer({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFEE5353),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 25.0, top: 40.0, bottom: 30.0),
                child: Text(
                  'Smart Alarm',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              _drawerTile(context, 'Dashboard', () => Navigator.pop(context)),
              _drawerTile(context, 'Alarms', () {
                onSelect(0);
                Navigator.pop(context);
              }, isActive: true),
              _drawerTile(context, 'Timer', () {
                onSelect(1);
                Navigator.pop(context);
              }),
              _drawerTile(context, 'Stopwatch', () {
                onSelect(2);
                Navigator.pop(context);
              }),
              _drawerTile(context, 'Wake-up Challenge', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WakeUpChallengeScreen()));
              }),
              _drawerTile(context, 'Night Mode', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NightModeSettingsScreen()));
              }),
              _drawerTile(context, 'Settings', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
              _drawerTile(context, 'Profile', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerTile(BuildContext context, String title, VoidCallback onTap, {bool isActive = false}) {
    return Container(
      color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ==================== ALARM TAB CONTENT ====================
class AlarmTabContent extends StatelessWidget {
  final List<Map<String, dynamic>> alarms;
  final Function(int, bool) onToggle;
  final VoidCallback onAddPressed;
  final Function(int) onEditAlarm;

  const AlarmTabContent({
    super.key,
    required this.alarms,
    required this.onToggle,
    required this.onAddPressed,
    required this.onEditAlarm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: CustomPaint(
                size: const Size(80, 80),
                painter: ClockIconPainter(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Text(
                  '7:20',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFEE5353),
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'AM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEE5353),
                  ),
                ),
              ],
            ),
            const Text(
              'FRIDAY, 12 JUNE 2026',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.8),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  bool isActive = alarm['isActive'];
                  return GestureDetector(
                    onTap: () => onEditAlarm(index),
                    child: Container(
                      height: 65,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                alarm['time'],
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w300,
                                  color: isActive ? const Color(0xFFEE5353) : Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                alarm['period'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? const Color(0xFFEE5353) : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isActive,
                            activeColor: const Color(0xFFEE5353),
                            onChanged: (val) => onToggle(index, val),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 30,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFEE5353),
            elevation: 4,
            onPressed: onAddPressed,
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ==================== SET ALARM SCREEN ====================
class SetAlarmScreen extends StatefulWidget {
  const SetAlarmScreen({super.key});

  @override
  State<SetAlarmScreen> createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends State<SetAlarmScreen> {
  int selectedHour = 7;
  int selectedMinute = 20;
  bool isAM = true;
  bool snooze = true;
  String selectedSound = 'Jungle Morning';
  List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  Set<int> selectedDays = {0, 1, 2, 3, 4};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Set Alarm', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWheelPicker(12, selectedHour - 1, (index) {
                    setState(() => selectedHour = index + 1);
                  }),
                  const Text(':', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  _buildWheelPicker(60, selectedMinute, (index) {
                    setState(() => selectedMinute = index);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                bool isSelected = selectedDays.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedDays.remove(index);
                      } else {
                        selectedDays.add(index);
                      }
                    });
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEE5353) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SNOOZE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 2),
                    Text('10 mins', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Switch(
                  value: snooze,
                  activeColor: const Color(0xFFEE5353),
                  onChanged: (val) => setState(() => snooze = val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('ALARM SOUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmSoundPickerScreen(currentSound: selectedSound)),
                );
                if (result != null) {
                  setState(() => selectedSound = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedSound, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE5353),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  String minStr = selectedMinute.toString().padLeft(2, '0');
                  Navigator.pop(context, {
                    'time': '$selectedHour:$minStr',
                    'period': isAM ? 'AM' : 'PM',
                    'isActive': true,
                    'sound': selectedSound,
                  });
                },
                child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelPicker(int count, int initialIndex, Function(int) onSelected) {
    return SizedBox(
      width: 70,
      child: CupertinoPicker(
        itemExtent: 35,
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: onSelected,
        children: List.generate(count, (index) {
          int displayVal = (count == 12) ? index + 1 : index;
          return Center(
            child: Text(
              displayVal.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          );
        }),
      ),
    );
  }
}

// ==================== EDIT ALARM SCREEN ====================
class EditAlarmScreen extends StatelessWidget {
  final Map<String, dynamic> alarmData;
  const EditAlarmScreen({super.key, required this.alarmData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Edit Alarm', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  '${alarmData['time']} ${alarmData['period']}',
                  style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w300, color: Color(0xFFEE5353)),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE5353), elevation: 0),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE5353), elevation: 0),
                    onPressed: () => Navigator.pop(context, 'DELETE'),
                    child: const Text('DELETE', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE5353), elevation: 0),
                    onPressed: () => Navigator.pop(context, alarmData),
                    child: const Text('SAVE', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==================== WAKE UP CHALLENGE SCREEN ====================
class WakeUpChallengeScreen extends StatefulWidget {
  const WakeUpChallengeScreen({super.key});

  @override
  State<WakeUpChallengeScreen> createState() => _WakeUpChallengeScreenState();
}

class _WakeUpChallengeScreenState extends State<WakeUpChallengeScreen> {
  final TextEditingController _answerController = TextEditingController();
  final int num1 = 24;
  final int num2 = 17;
  String _feedback = '';

  void _checkAnswer() {
    final int? userAnswer = int.tryParse(_answerController.text.trim());
    if (userAnswer == (num1 + num2)) {
      Navigator.pop(context);
    } else {
      setState(() {
        _feedback = 'Incorrect! Try again to stop the alarm.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEE5353),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm_on, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'WAKE UP!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              const Text(
                'Solve the math challenge to dismiss the alarm:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$num1 + $num2 = ?',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter answer',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              if (_feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_feedback, style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _checkAnswer,
                  child: const Text('SUBMIT & DISMISS', style: TextStyle(color: Color(0xFFEE5353), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ALARM SOUND PICKER SCREEN ====================
class AlarmSoundPickerScreen extends StatelessWidget {
  final String currentSound;
  AlarmSoundPickerScreen({super.key, required this.currentSound});

  final List<String> sounds = [
    'Jungle Morning', 'Ceramic', 'Rooster Crow', 'Ocean Breeze', 'Electric Bell',
    'Morning Dew', 'Gentle Stream', 'Digital Echo', 'Soft Chime', 'Sunrise Melody',
    ...List.generate(40, (i) => 'Alarm Tone ${i + 11}')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15, top: 12, bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE5353),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('SAVE', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          )
        ],
      ),
      body: ListView.separated(
        itemCount: sounds.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sound = sounds[index];
          bool isSelected = sound == currentSound;
          return ListTile(
            title: Text(
              sound,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFFEE5353) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () => Navigator.pop(context, sound),
          );
        },
      ),
    );
  }
}

// ==================== STOPWATCH TAB CONTENT ====================
class StopwatchTabContent extends StatefulWidget {
  const StopwatchTabContent({super.key});

  @override
  State<StopwatchTabContent> createState() => _StopwatchTabContentState();
}

class _StopwatchTabContentState extends State<StopwatchTabContent> {
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    final hundreds = (milliseconds / 10).truncate() % 100;
    final seconds = (milliseconds / 1000).truncate() % 60;

    String formattedSeconds = seconds.toString().padLeft(2, '0');
    String formattedHundreds = hundreds.toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formattedSeconds,
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: Color(0xFFEE5353)),
            ),
            const Text('s', style: TextStyle(fontSize: 24, color: Color(0xFFEE5353))),
            Text(
              ':$formattedHundreds',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w300, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE5353),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                child: Text(_stopwatch.isRunning ? 'PAUSE' : 'START', style: const TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 100,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _resetStopwatch,
                child: const Text('LAP', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== FULLY FUNCTIONAL NIGHT MODE SETTINGS ====================
class NightModeSettingsScreen extends StatefulWidget {
  const NightModeSettingsScreen({super.key});

  @override
  State<NightModeSettingsScreen> createState() => _NightModeSettingsScreenState();
}

class _NightModeSettingsScreenState extends State<NightModeSettingsScreen> {
  bool nightMode = true;
  bool dimScreen = false;
  bool bedtimeMode = false;
  bool displayWeather = false;
  bool showDate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Night Mode', style: TextStyle(color: Colors.black87, fontSize: 16)),
      ),
      body: ListView(
        children: [
          _switchTile('Night Mode', nightMode, (v) => setState(() => nightMode = v)),
          _switchTile('Dim Screen', dimScreen, (v) => setState(() => dimScreen = v)),
          _switchTile('Bedtime Mode', bedtimeMode, (v) => setState(() => bedtimeMode = v)),
          _switchTile('Display Weather', displayWeather, (v) => setState(() => displayWeather = v)),
          _switchTile('Show Date', showDate, (v) => setState(() => showDate = v)),
        ],
      ),
    );
  }

  Widget _switchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        value: value,
        activeColor: const Color(0xFFEE5353),
        onChanged: onChanged,
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black87, fontSize: 16)),
      ),
      body: ListView(
        children: [
          _settingItem('Alarm Settings'),
          _settingItem('Sound & Vibration'),
          _settingItem('Display'),
          _settingItem('Theme'),
          _settingItem('Account'),
        ],
      ),
    );
  }

  Widget _settingItem(String title) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        onTap: () {},
      ),
    );
  }
}

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Smart Alarm User');
  final TextEditingController _emailController = TextEditingController(text: 'user@smartalarm.com');
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black87, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Color(0xFFEE5353), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFEE5353),
                  child: Icon(Icons.person, size: 55, color: Colors.white),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              enabled: isEditing,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Color(0xFFEE5353)),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(color: Color(0xFFEE5353), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM CLOCK ICON PAINTER ====================
class ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEE5353)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final center = Offset(size.width / 2, size.height / 2 + 5);
    final radius = size.width / 2.8;

    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.5), paint);
    canvas.drawLine(center, Offset(center.dx + radius * 0.35, center.dy), paint);

    canvas.drawLine(
      Offset(center.dx - radius * 0.7, center.dy - radius * 0.7),
      Offset(center.dx - radius * 0.9, center.dy - radius * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.7),
      Offset(center.dx + radius * 0.9, center.dy - radius * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}