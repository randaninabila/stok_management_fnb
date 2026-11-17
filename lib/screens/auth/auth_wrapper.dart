
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'login_page.dart';
import '../owner/owner_home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorPage(
            'Terjadi kesalahan saat memeriksa autentikasi.',
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginPage();
        }

        return FutureBuilder<UserModel?>(
          future: authService.getCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return _buildErrorPage(
                'Gagal mengambil profil pengguna.',
              );
            }

            final user = profileSnapshot.data;

            if (user == null) {
              return _buildErrorPage(
                'Profil pengguna tidak ditemukan atau tidak aktif.',
              );
            }

            switch (user.role) {
              case 'owner':
                return const OwnerHomePage();

              case 'staf gudang':
              case 'staf dapur':
              case 'kasir':
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Halaman ${user.role} belum tersedia.',
                    ),
                  ),
                );

              default:
                return _buildErrorPage(
                  'Role pengguna tidak dikenali.',
                );
            }
          },
        );
      },
    );
  }

  Widget _buildErrorPage(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await AuthService().logout();
                },
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
