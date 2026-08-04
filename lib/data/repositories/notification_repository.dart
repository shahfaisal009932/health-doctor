import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notifications =>
      _firestore.collection('notifications');

  /// Create an in-app notification for a user.
  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
    String? appointmentId,
  }) async {
    try {
      if (userId.isEmpty) return;
      FirestoreLogger.log(
        collection: 'notifications',
        operation: 'add',
        details: 'userId=$userId type=$type',
      );
      await _notifications.add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'appointmentId': appointmentId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Realtime stream of notifications for a user.
  Stream<List<AppNotificationModel>> listenToNotifications(String userId) {
    if (userId.isEmpty) {
      FirestoreLogger.log(
        collection: 'notifications',
        operation: 'listen',
        details: 'unauthenticated',
      );
      return Stream.value(const []);
    }
    FirestoreLogger.log(
      collection: 'notifications',
      operation: 'listen',
      details: 'userId=$userId orderBy=createdAt(desc) limit=50',
    );
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotificationModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      FirestoreLogger.log(
        collection: 'notifications',
        operation: 'update',
        details: 'doc=$notificationId read=true',
      );
      await _notifications.doc(notificationId).update({'read': true});
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead(String userId) async {
    try {
      FirestoreLogger.log(
        collection: 'notifications',
        operation: 'read',
        details: 'userId=$userId read=false',
      );
      final snapshot = await _notifications
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      FirestoreLogger.log(
        collection: 'notifications',
        operation: 'batch',
        details: 'update read=true for ${snapshot.docs.length} docs',
      );
      await batch.commit();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'batch',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'notifications',
        operation: 'batch',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }
}
