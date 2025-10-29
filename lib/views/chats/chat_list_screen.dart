import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/chatController.dart';
import 'package:hired/views/chats/chats_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        titleSpacing: 20,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('users', arrayContains: currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            );
          }

          // Filter only chats with lastMessageTime
          final chatDocs =
              snapshot.data!.docs
                  .where((doc) => doc['lastMessageTime'] != null)
                  .toList();

          // Sort manually by lastMessageTime (descending)
          chatDocs.sort((a, b) {
            final aTime = (a['lastMessageTime'] as Timestamp).toDate();
            final bTime = (b['lastMessageTime'] as Timestamp).toDate();
            return bTime.compareTo(aTime);
          });

          if (chatDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.chat_bubble_2,
                    size: 80,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Messages",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start a conversation with someone",
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: chatDocs.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 2,
                    indent: 72,
                    endIndent: 16,
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
              itemBuilder: (context, index) {
                final chatData = chatDocs[index].data() as Map<String, dynamic>;

                final lastMessage = chatData['lastMessage'] ?? '';
                final lastMessageTime =
                    (chatData['lastMessageTime'] as Timestamp?)?.toDate() ??
                    DateTime.now();

                final users = List<String>.from(chatData['users']);
                final otherUserId = users.firstWhere(
                  (id) => id != currentUserId,
                );

                return Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        index == 0
                            ? const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            )
                            : index == chatDocs.length - 1
                            ? const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                            : null,
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      Get.dialog(
                        CupertinoAlertDialog(
                          title: const Text("Delete Chat"),
                          content: const Text(
                            "Are you sure you want to delete this chat?",
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("Cancel"),
                              onPressed: () => Get.back(),
                            ),
                            CupertinoDialogAction(
                              child: const Text("Delete"),
                              onPressed: () {
                                chatController.deleteChatRoom(
                                  currentUserId,
                                  otherUserId,
                                );
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: CupertinoListTile(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _generateAvatarColor(otherUserId),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(otherUserId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        _formatUserName(otherUserId),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        lastMessage.isEmpty ? "No messages yet" : lastMessage,
                        style: TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeAgo(lastMessageTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel.resolveFrom(
                                context,
                              ),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),

                      onTap: () {
                        // Add haptic feedback for iOS feel
                        HapticFeedback.lightImpact();

                        final chatRoomId = chatController.getChatRoomId(
                          currentUserId,
                          otherUserId,
                        );

                        Get.to(
                          () => ChatsScreen(
                            chatRoomId: chatRoomId,
                            otherUserName: otherUserId,
                          ),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Helper to show time ago format (e.g., "5 min ago")
  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}d";
    return "${diff.inDays ~/ 7}w";
  }

  /// Generate a consistent color for user avatar based on user ID
  Color _generateAvatarColor(String userId) {
    final colors = [
      CupertinoColors.systemBlue,
      CupertinoColors.systemGreen,
      CupertinoColors.systemOrange,
      CupertinoColors.systemRed,
      CupertinoColors.systemPurple,
      CupertinoColors.systemTeal,
      CupertinoColors.systemIndigo,
      CupertinoColors.systemPink,
    ];

    final index = userId.hashCode % colors.length;
    return colors[index.abs()];
  }

  /// Get initials from user ID (you might want to replace this with actual user names)
  String _getInitials(String userId) {
    if (userId.length >= 2) {
      return userId.substring(0, 2).toUpperCase();
    }
    return userId.substring(0, 1).toUpperCase();
  }

  /// Format user name (you might want to fetch actual user names from your user collection)
  String _formatUserName(String userId) {
    // This is a placeholder - you should replace this with actual user name fetching
    return "User ${userId.substring(0, 8)}";
  }
}
