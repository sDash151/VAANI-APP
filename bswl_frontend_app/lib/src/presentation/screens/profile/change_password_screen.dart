import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bswl_frontend_app/src/presentation/providers/auth_provider.dart'
    as my_auth;
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newController.text.trim());
      setState(() {
        _successMessage =
            'Password changed successfully. All sessions will be logged out.';
      });
      // --- BACKEND LOGIC (commented out, for future use) ---
      // Example: Call your backend API to update password
      // try {
      //   final response = await apiService.post('auth/reset-password', {
      //     'token': '<JWT or session token>',
      //     'newPassword': _newController.text.trim(),
      //   });
      //   if (response['success'] != true) {
      //     throw Exception('Backend failed to update password');
      //   }
      // } catch (e) {
      //   setState(() {
      //     _errorMessage = 'Backend error: ' + e.toString();
      //   });
      // }
      // ------------------------------------------------------
      // Optionally, sign out user everywhere
      await Provider.of<my_auth.AuthProvider>(context, listen: false).signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  if (_successMessage != null)
                    Text(_successMessage!,
                        style: const TextStyle(color: Colors.green)),
                  TextFormField(
                    controller: _currentController,
                    decoration:
                        const InputDecoration(labelText: 'Current Password'),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Enter current password'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newController,
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter new password';
                      if (v.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    decoration: const InputDecoration(
                        labelText: 'Confirm New Password'),
                    obscureText: true,
                    validator: (v) => v != _newController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Change Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
