import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ConnectionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final obj = Hive.box('myBox');

  /// SEND FOLLOW REQUEST
  Future<void> sendFollowRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      if (fromUserId == toUserId) {
        print("You can't follow yourself.");
        return;
      }

      // Check if already connected
      final alreadyConnected =
          await _firestore
              .collection('users')
              .doc(toUserId)
              .collection('connections')
              .doc(fromUserId)
              .get();

      if (alreadyConnected.exists) {
        print("Already connected.");
        return;
      }

      // Check if already requested
      final alreadyRequested =
          await _firestore
              .collection('users')
              .doc(toUserId)
              .collection('follow_requests')
              .doc(fromUserId)
              .get();

      if (alreadyRequested.exists) {
        print("Request already sent.");
        return;
      }

      // Send follow request
      await _firestore
          .collection('users')
          .doc(toUserId)
          .collection('follow_requests')
          .doc(fromUserId)
          .set({
            'fromUserId': fromUserId,
            'status': 'pending',
            'userName': obj.get('name') ?? 'Unknown User',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Add notification
      await _firestore.collection('notifications').add({
        'type': 'follow_request',
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Follow request sent.");
    } catch (e) {
      print("❌ Error sending follow request: $e");
    }
  }

  /// ACCEPT FOLLOW REQUEST
  Future<void> acceptFollowRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      // Add to each other's connections
      await _firestore
          .collection('users')
          .doc(toUserId)
          .collection('connections')
          .doc(fromUserId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      await _firestore
          .collection('users')
          .doc(fromUserId)
          .collection('connections')
          .doc(toUserId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      // Remove follow request
      await _firestore
          .collection('users')
          .doc(toUserId)
          .collection('follow_requests')
          .doc(fromUserId)
          .delete();

      // Update notification
      final notifQuery =
          await _firestore
              .collection('notifications')
              .where('fromUserId', isEqualTo: fromUserId)
              .where('toUserId', isEqualTo: toUserId)
              .where('type', isEqualTo: 'follow_request')
              .get();

      for (var doc in notifQuery.docs) {
        await doc.reference.update({'status': 'accepted'});
      }

      print("✅ Follow request accepted.");
    } catch (e) {
      print("❌ Error accepting request: $e");
    }
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String unfollowUserId,
  }) async {
    // Remove the connection document from currentUser's connections
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('connections')
        .doc(unfollowUserId)
        .delete();

    // Also optionally remove currentUser from unfollowUser's followers or connections
  }
}
