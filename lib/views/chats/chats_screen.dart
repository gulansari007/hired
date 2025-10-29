import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/callController.dart';
import 'package:hired/controllers/chatController.dart';
import 'package:hired/views/agora/agora_screen.dart';

class ChatsScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  const ChatsScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final chatController = Get.put(ChatController());
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  final callController = Get.put(CallController());

  String get currentUserId => auth.currentUser!.uid;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    chatController.partnerStatus.value == 'online'
                        ? 'Online'
                        : 'Offline',

                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined),
            onPressed: () {
              Get.to(
                () => AgoraScreen(
                  channelId: '${widget.chatRoomId}_video',
                  callerId: currentUserId,
                  receiverId: widget.otherUserName,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.call_outlined),
            onPressed: () {
              Get.to(
                () => AgoraScreen(
                  channelId: '${widget.chatRoomId}_audio',
                  callerId: currentUserId,
                  receiverId: widget.otherUserName,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;

              final Offset buttonPosition = button.localToGlobal(
                Offset.zero,
                ancestor: overlay,
              );
              final RelativeRect position = RelativeRect.fromLTRB(
                buttonPosition.dx +
                    button.size.width, // Right side of the button
                buttonPosition.dy,
                0,
                0,
              );

              showMenu<String>(
                context: context,
                position: position,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: [
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [SizedBox(width: 10), Text('Block User')],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [SizedBox(width: 10), Text('Report User')],
                    ),
                  ),
                ],
              ).then((value) {
                if (value == 'block') {
                  // Handle block user
                } else if (value == 'report') {
                  // Handle report user
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading messages...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final data = messages[index];
                    final isMe = data['senderId'] == currentUserId;
                    final timestamp = data['timestamp'] as Timestamp?;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment:
                            isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                widget.otherUserName.isNotEmpty
                                    ? widget.otherUserName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                          Flexible(
                            child: GestureDetector(
                              onLongPress: () {
                                // Handle message tap if needed
                                Get.defaultDialog(
                                  title: "Delete Message",
                                  middleText:
                                      "Do you want to delete this message?",
                                  textConfirm: "Delete",
                                  textCancel: "Cancel",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    await chatController.deleteSingleMessage(
                                      currentUserId: currentUserId,
                                      otherUserId: widget.otherUserName,
                                      messageId: data.id,
                                    );
                                    Get.back(); // Close dialog
                                  },
                                );
                              },
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isMe
                                          ? Colors.blue.shade500
                                          : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        // Handle long press if needed
                                        Get.defaultDialog(
                                          title: "Delete Message",
                                          middleText:
                                              "Do you want to delete this message?",
                                          textConfirm: "Delete",
                                          textCancel: "Cancel",
                                          confirmTextColor: Colors.white,
                                          onConfirm: () async {
                                            await chatController
                                                .deleteSingleMessage(
                                                  currentUserId: currentUserId,
                                                  otherUserId:
                                                      widget.otherUserName,
                                                  messageId: data.id,
                                                );
                                            Get.back(); // Close dialog
                                          },
                                        );
                                      },
                                      child: Text(
                                        data['text'] ?? '',
                                        style: TextStyle(
                                          color:
                                              isMe
                                                  ? Colors.white
                                                  : Colors.black87,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    if (timestamp != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        _formatTime(timestamp.toDate()),
                                        style: TextStyle(
                                          color:
                                              isMe
                                                  ? Colors.white.withOpacity(
                                                    0.7,
                                                  )
                                                  : Colors.grey.shade500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 8),
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: Colors.blue.shade300,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      showMediaOptionsBottomSheet(context);
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: chatController.msgCtrl,

                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          suffixIcon: Obx(
                            () => IconButton(
                              onPressed: () async {
                                final path =
                                    await chatController.stopRecording();
                                if (path != null) {
                                  // Upload and send message
                                  final url = await chatController.uploadAudio(
                                    "CHAT_ID",
                                  );
                                  // Save the URL to Firestore chat
                                }
                              },
                              onLongPress: () async {
                                chatController.startRecording();
                              },

                              icon: Icon(
                                chatController.isRecording.value
                                    ? Icons.mic
                                    : Icons.mic_none,
                                color:
                                    chatController.isRecording.value
                                        ? Colors.red
                                        : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      if (chatController.msgCtrl.text.trim().isNotEmpty) {
                        // Send Text Message
                        chatController.sendMessage(
                          text: chatController.msgCtrl.text,
                          currentUserId: currentUserId,
                          otherUserId: widget.otherUserName,
                        );
                        chatController.msgCtrl.clear();
                      } else if (chatController.recordedFilePath != null) {
                        // Send Recorded Audio
                        String? audioUrl = await chatController.uploadAudio(
                          "CHAT_ID",
                        );
                        if (audioUrl != null) {
                          chatController.sendMessage(
                            text: "", // No text, just audio
                            audioUrl: audioUrl, // Add a field for audio
                            currentUserId: currentUserId,
                            otherUserId: widget.otherUserName,
                          );
                          chatController.recordedFilePath = null; // Reset
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

//
void showMediaOptionsBottomSheet(BuildContext context) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement camera function
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.green),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement gallery function
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file, color: Colors.orange),
            title: const Text('Files'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement file picker function
            },
          ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.red),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
