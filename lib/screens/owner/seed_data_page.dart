
import 'package:flutter/material.dart';
import '../../services/database_seeder.dart';

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  bool _isLoading = false;
  Map<String, int>? _seedResults;
  String? _errorMessage;

  Future<void> _runSeeder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inisialisasi Database'),
        content: const Text(
          'Apakah kamu ingin memasukkan data master NuTrack '
          'ke Firestore sekarang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _seedResults = null;
    });

    try {
      final results = await DatabaseSeeder().seedInitialData();

      if (!mounted) return;

      setState(() {
        _seedResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAdded = _seedResults?.values.fold<int>(
          0,
          (total, count) => total + count,
        ) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inisialisasi Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Data Master NuTrack',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan data menu, bahan baku, resep, '
              'dan stok awal ke Firestore.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DataCountRow(
                      label: 'Menus',
                      count: 22,
                    ),
                    _DataCountRow(
                      label: 'Ingredients',
                      count: 24,
                    ),
                    _DataCountRow(
                      label: 'Recipes',
                      count: 16,
                    ),
                    _DataCountRow(
                      label: 'Inventory',
                      count: 48,
                    ),
                    Divider(),
                    _DataCountRow(
                      label: 'Total Dokumen',
                      count: 110,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _runSeeder,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Jalankan Seeder'),
              ),
            ),

            if (_seedResults != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Hasil Proses Seeder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._seedResults!.entries.map(
                (entry) => _DataCountRow(
                  label: entry.key,
                  count: entry.value,
                ),
              ),
              const Divider(),
              _DataCountRow(
                label: 'Total Dokumen Baru',
                count: totalAdded,
                isBold: true,
              ),
              const SizedBox(height: 8),
              Text(
                totalAdded == 0
                    ? 'Semua dokumen sudah tersedia. Tidak ada data baru.'
                    : 'Berhasil menambahkan $totalAdded dokumen baru.',
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                'Terjadi kesalahan:\n$_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DataCountRow extends StatelessWidget {
  final String label;
  final int count;
  final bool isBold;

  const _DataCountRow({
    required this.label,
    required this.count,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
