import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;
  static final _users = _firestore.collection('users');

  /// 🔹 Tạo tài khoản ẩn danh nếu chưa có
  static Future<void> ensureFirebaseLogin() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  /// 🔹 Lưu hoặc cập nhật hồ sơ người dùng (dùng UID Supabase làm ID)
  static Future<void> saveUserProfile({
    required String name,
    required String bio,
    required String? avatarUrl,
    required String userId, // 🔸 truyền từ Supabase user.id
    required String email,
  }) async {
    await ensureFirebaseLogin();

    await _users.doc(userId).set({
      'name': name,
      'bio': bio,
      'avatar': avatarUrl,
      'email': email,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Lấy hồ sơ người dùng
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    await ensureFirebaseLogin();

    final doc = await _users.doc(userId).get();
    return doc.data();
  }
}
