import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['name'] ?? '';
    _phoneController.text = widget.user['phone'] ?? '';
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await ProfileService.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'WhatsApp')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password Baru (opsional)'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _isLoading ? null : _save, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}