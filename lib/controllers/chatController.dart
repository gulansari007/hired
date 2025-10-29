import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:record/record.dart';

class ChatController extends GetxController {
  TextEditingController msgCtrl = TextEditingController();
  final RxString currentUserId = ''.obs; // Placeholder for current user ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // audio
  final AudioRecorder record = AudioRecorder(); // Fixed
  final RxBool isRecording = false.obs;
  var recordedFilePath;

  // offline / online
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final RxString partnerStatus = "offline".obs;

  /// online/offline state
  void listenPartnerStatus(String partnerUid) {
    _db.child("status/$partnerUid/state").onValue.listen((event) {
      partnerStatus.value = event.snapshot.value?.toString() ?? "offline";
    });
  }

  /// Start recording
  Future<void> startRecording() async {
    if (await record.hasPermission()) {
      final path = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      recordedFilePath = '/storage/emulated/0/Download/$path'; // Example path
      await record.start(RecordConfig(), path: recordedFilePath);
      isRecording.value = true;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    final path = await record.stop();
    isRecording.value = false;
    recordedFilePath = path;
    return path;
  }

  /// Upload audio file to Firebase Storage
  Future<String?> uploadAudio(String chatId) async {
    if (recordedFilePath == null) return null;

    final file = File(recordedFilePath!);
    final ref = FirebaseStorage.instance.ref(
      'chats/$chatId/audio/${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  //
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String text,
    required String currentUserId,
    required String otherUserId,
    String? audioUrl,
  }) async {
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatRoomId);

    // Determine message content and type
    final isAudioMessage = (audioUrl != null && audioUrl.isNotEmpty);
    final messageData = {
      'text': text,
      'audioUrl': audioUrl ?? "",
      'type': isAudioMessage ? 'audio' : 'text',
      'senderId': currentUserId,
      'receiverId': otherUserId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add message to messages subcollection
    await chatRef.collection('messages').add(messageData);

    // Update last message in chat room
    await chatRef.set({
      'users': [currentUserId, otherUserId],
      'lastMessage': isAudioMessage ? "🎤 Voice Message" : text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Send notification
    await sendPushNotification(
      toUserId: otherUserId,
      message: isAudioMessage ? "🎤 Voice Message" : text,
    );
  }

  //
  Future<void> sendPushNotification({
    required String toUserId,
    required String message,
  }) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(toUserId)
            .get();

    if (!userDoc.exists) {
      print('User document does not exist');
      return;
    }

    final data = userDoc.data();
    final fcmToken = data?['fcmToken'];

    if (fcmToken == null || fcmToken.isEmpty) {
      print('User has no FCM token');
      return;
    }

    await _sendFCMRequest(token: fcmToken, message: message);
  }

  Future<void> _sendFCMRequest({
    required String token,
    required String message,
  }) async {
    final serverKey =
        'AIzaSyApx8rAO05tmnKVgJ7cenwi3fE_q83avFg'; // Get from Firebase Console

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': 'New Message',
          'body': message,
          'sound': 'default',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': message,
        },
      }),
    );
  }

  //
  String getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }

  Future<String> getUserName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['name'];
  }

  //
  Future<void> deleteChatRoom(String currentUserId, String otherUserId) async {
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatRoomId);

    try {
      // Delete all messages
      final messages = await chatRef.collection('messages').get();
      for (var msg in messages.docs) {
        await msg.reference.delete();
      }

      // Delete chat document itself
      await chatRef.delete();

      print('Chat room deleted successfully.');
    } catch (e) {
      print('Error deleting chat room: $e');
    }
  }

  //
  Future<void> deleteSingleMessage({
    required String currentUserId,
    required String otherUserId,
    required String messageId,
  }) async {
    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    final messageRef = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    try {
      await messageRef.delete();
      print('Message deleted successfully.');
    } catch (e) {
      print('Error deleting message: $e');
    }
  }
}
