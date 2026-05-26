import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.googleSignIn();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtleText = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.15);
    final outlineBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.2);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.note_alt_outlined,
                    size: 40,
                    color: Color(0xFF1A73E8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '∆nfiniNotes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back',
                style: TextStyle(fontSize: 16, color: subtleText),
              ),
              const SizedBox(height: 40),
              if (auth.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _login,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: TextStyle(color: subtleText)),
                  ),
                  Expanded(child: Divider(color: dividerColor)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: auth.isLoading ? null : _googleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: outlineBorderColor),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF1A73E8),
                        fontWeight: FontWeight.w600,
                      ),
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