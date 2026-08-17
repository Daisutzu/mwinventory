import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// L'app non ha account individuali: tutto lo staff usa la stessa password
// condivisa, che internamente accede a un unico utente Firebase fisso.
// Serve solo per sbloccare l'app la prima volta (Firebase Auth ricorda la
// sessione sul dispositivo) e per far valere le regole di Firestore anche
// a chi provasse a leggere/scrivere il database scavalcando l'app.
const _sharedAccountEmail = 'staff@mwinventory-59853.firebaseapp.com';

class AuthGateScreen extends StatefulWidget {
  final Widget child;

  const AuthGateScreen({super.key, required this.child});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: kBrandRed)),
          );
        }
        if (snapshot.data != null) {
          return widget.child;
        }
        return const _PasswordScreen();
      },
    );
  }
}

class _PasswordScreen extends StatefulWidget {
  const _PasswordScreen();

  @override
  State<_PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<_PasswordScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _controller.text;
    if (password.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _sharedAccountEmail,
        password: password,
      );
    } on FirebaseAuthException {
      setState(() => _error = 'Password errata.');
    } catch (_) {
      setState(() => _error = 'Connessione non disponibile, riprova.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121317),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC2436), kBrandRed],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'MW INVENTORY',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'App riservata allo staff MediaWorld',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Entra'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
