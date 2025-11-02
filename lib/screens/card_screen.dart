import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/brightness.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  String name = '';
  String title = '';
  String company = '';
  String phone = '';
  String email = '';
  String website = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupDisplay();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      title = prefs.getString('title') ?? '';
      company = prefs.getString('company') ?? '';
      phone = prefs.getString('phone') ?? '';
      email = prefs.getString('email') ?? '';
      website = prefs.getString('website') ?? '';
    });
  }

  Future<void> _setupDisplay() async {
    await BrightnessUtils.setMaxBrightness();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _resetDisplay() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _resetDisplay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Business Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Error loading data'));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (company.isNotEmpty)
                  Text(
                    company,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                if (website.isNotEmpty)
                  Text(
                    website,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}