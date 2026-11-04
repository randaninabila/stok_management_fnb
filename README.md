# stok_management-_fnb

Aplikasi Manajemen Stok Bahan Baku F&B
Aplikasi mobile untuk membantu pengelolaan persediaan bahan baku pada usaha F&B melalui pencatatan stok, pemindahan bahan antara gudang dan dapur, serta pemantauan penggunaan bahan.
Pengguna aplikasi: Owner, Staf Dapur, Staf Gudang
Lokasi penyimpanan: Gudang Utama dan Dapur

Struktur Aplikasi
A. Owner
Tugas Owner: memantau stok dan menyetujui pembelian.
Navigasi Owner: 

Beranda - Stok - Profil
Isi setiap menu
1. Beranda
Ringkasan stok Gudang Utama.
Ringkasan stok Dapur.
Informasi stok menipis.
Daftar permintaan pembelian yang menunggu persetujuan.
2. Stok
Daftar bahan baku.
Jumlah stok Gudang Utama.
Jumlah stok Dapur.
Detail bahan dan status stok.
Tambah, edit, dan hapus data bahan baku (CRUD).
3. Profil
Informasi akun.
Ubah kata sandi.
Logout.
Fitur tambahan dari Beranda: Persetujuan Pembelian
Melihat daftar pengajuan.
Melihat detail bahan dan jumlah yang diminta.
Menyetujui atau menolak pengajuan.
B. Staf Dapur
Tugas Staf Dapur: melihat stok dapur, mencatat penggunaan bahan, dan meminta bahan dari gudang.
Navigasi Staf Dapur:

Beranda - Stok - Aktivitas - Profil
Isi setiap menu
1. Beranda
Ringkasan stok dapur.
Informasi bahan menipis.
Ringkasan pesanan yang sedang diproses.
Status permintaan bahan.
2. Stok
Daftar bahan baku dapur.
Jumlah stok.
Status ketersediaan bahan.
Detail bahan.
3. Aktivitas
Cukup berisi tiga aktivitas:
Pesanan: melihat pesanan, menambah pesanan, dan menyelesaikan pesanan.
Permintaan Bahan: mengajukan permintaan bahan ke gudang.
Penerimaan Bahan: mengonfirmasi bahan yang diterima dari gudang.
4. Profil
Informasi akun.
Ubah kata sandi.
Logout.
Untuk fitur pesanan, cukup ada dua halaman:
Tambah Pesanan: pilih menu, masukkan jumlah porsi, dan catatan opsional.
Detail Pesanan: melihat detail pesanan dan menekan tombol Pesanan Selesai.
Ketika pesanan selesai, sistem mengurangi stok bahan dapur sesuai komposisi bahan yang sudah ditentukan.Komposisi bahan bisa disimpan sebagai data awal di database.
C. Staf Gudang
Tugas Staf Gudang: mengelola stok gudang, mencatat barang masuk, memenuhi permintaan dapur, dan mengajukan pembelian.
Navigasi Staf Gudang

Beranda - Stok - Transaksi - Profil
Isi setiap menu
1. Beranda
Ringkasan stok gudang.
Informasi bahan menipis.
Permintaan bahan dari dapur.
Status pengajuan pembelian.
2. Stok
Daftar bahan baku gudang.
Jumlah stok.
Detail bahan.
Tambah, edit, dan pencatatan stok.
3. Transaksi
Cukup berisi tiga aktivitas:
Barang Masuk: mencatat bahan yang baru diterima.
Permintaan Dapur: melihat dan memproses permintaan bahan.
Pengajuan Pembelian: mengajukan pembelian kepada Owner.
4. Profil
Informasi akun.
Ubah kata sandi.
Logout.










Ringkasan struktur aplikasi

