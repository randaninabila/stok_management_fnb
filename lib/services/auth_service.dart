
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _allowedRoles = [
    'owner',
    'staf gudang',
    'staf dapur',
    'kasir',
  ];

  // Mengambil dan memvalidasi profil pengguna.
  Future<UserModel?> _getValidProfile(User firebaseUser) async {
    final document = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    final userData = document.data()!;

    if (userData['uid'] != firebaseUser.uid ||
        userData['isActive'] != true ||
        !_allowedRoles.contains(userData['role'])) {
      return null;
    }

    return UserModel.fromMap(userData);
  }

  // Login menggunakan email dan password.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Login gagal. Pengguna tidak ditemukan.');
    }

    final userProfile = await _getValidProfile(firebaseUser);

    if (userProfile == null) {
      await _auth.signOut();
      throw Exception(
        'Profil pengguna tidak valid, tidak aktif, atau role tidak dikenali.',
      );
    }

    return userProfile;
  }

  // Mengambil profil pengguna yang sedang login.
  Future<UserModel?> getCurrentUserProfile() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final userProfile = await _getValidProfile(firebaseUser);

    if (userProfile == null) {
      await _auth.signOut();
      return null;
    }

    return userProfile;
  }

  // Memantau status autentikasi.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Logout.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
