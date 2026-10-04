import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await ProfileService.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Gagal memuat profil'))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                      const SizedBox(height: 16),
                      Text(_user!['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(_user!['email'], style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ListTile(title: const Text('Role'), trailing: Text(_user!['role'] ?? 'Student')),
                      ListTile(title: const Text('WhatsApp'), trailing: Text(_user!['phone'] ?? '-')),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          await AuthService.logout();
                          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
