import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../app_store.dart';

class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  Timer? _debounceTimer;

  bool get isAvailable => _firestore != null && _auth != null;

  /// Syncs the store with the cloud for the given user.
  /// If cloud data exists, it merges it with local data and uploads the unified state.
  /// If no cloud data exists, it uploads local data.
  Future<void> syncStore(AppStore store, [String? userUid]) async {
    final firestore = _firestore;
    final uid = userUid ?? _auth?.currentUser?.uid;
    if (firestore == null || uid == null) return;

    try {
      final docRef = firestore.collection('users').doc(uid);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data() != null) {
        final cloudData = docSnap.data()!;
        debugPrint('CloudSyncService: Merging cloud progress for $uid');
        await store.mergeFromCloud(cloudData);
        // Upload the merged canonical state back to cloud
        await docRef.set(store.toSyncJson(), SetOptions(merge: true));
      } else {
        debugPrint('CloudSyncService: Uploading initial local state for $uid');
        await docRef.set(store.toSyncJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('CloudSyncService error during syncStore: $e');
    }
  }

  /// Schedules a debounced upload of the store's current state to Firestore.
  void scheduleUpload(AppStore store) {
    final firestore = _firestore;
    final uid = _auth?.currentUser?.uid;
    if (firestore == null || uid == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      try {
        final docRef = firestore.collection('users').doc(uid);
        await docRef.set(store.toSyncJson(), SetOptions(merge: true));
        debugPrint(
          'CloudSyncService: Progress and preferences uploaded for $uid',
        );
      } catch (e) {
        debugPrint('CloudSyncService upload error: $e');
      }
    });
  }
}
