
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'seed_data_page.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({super.key});

  
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      await AuthService().logout();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout. Silakan coba lagi.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NuTrack - Owner'),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selamat Datang, Owner!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeedDataPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Inisialisasi Database'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
