import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();

  Map<String, dynamic>? user;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final result = await apiService.getProfile();

      setState(() {
        user = result['user'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> handleLogout() async {
    try {
      await apiService.logout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget buildUserInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$label: ${value ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: handleLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : user == null
                  ? const Center(child: Text('No user data found'))
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        children: [
                          buildUserInfo('ID', user!['id']),
                          buildUserInfo('Username', user!['username']),
                          buildUserInfo('First Name', user!['firstname']),
                          buildUserInfo('Middle Name', user!['middlename']),
                          buildUserInfo('Surname', user!['surname']),
                          buildUserInfo('Phone', user!['phonenum']),
                          buildUserInfo('Address', user!['address']),
                          buildUserInfo('Email', user!['email']),
                          buildUserInfo('Role', user!['role']),
                          buildUserInfo('Created At', user!['created_at']),
                        ],
                      ),
                    ),
    );
  }
}