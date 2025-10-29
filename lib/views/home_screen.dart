import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/basicController.dart';
import 'package:hired/controllers/chatController.dart';
import 'package:hired/controllers/connectionController.dart';
import 'package:hired/controllers/homeController.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:hired/update/app_update.dart';
import 'package:hired/views/chats/chat_list_screen.dart';
import 'package:hired/views/chats/chats_screen.dart';
import 'package:hired/views/screens/search_screen.dart';
import 'package:hired/views/screens/setting_screen.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put(HomeController());
  final connectionController = Get.put(ConnectionController());
  final internetController = Get.find<InternetController>();
  final chatController = Get.put(ChatController());
  final basicController = Get.put(BasicController());

  Box? obj;

  @override
  void initState() {
    obj = Hive.box('myBox');
    checkForFlexibleUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Obx(
      () =>
          internetController.hasInternet.value
              ? CupertinoPageScaffold(
                backgroundColor: CupertinoColors.systemGroupedBackground,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // iOS-style navigation bar
                    CupertinoSliverNavigationBar(
                      backgroundColor: CupertinoColors.systemBackground
                          .withOpacity(0.8),
                      border: null,
                      stretch: true,
                      largeTitle: GestureDetector(
                        onTap: () {
                          Get.to(JobSearchExpandable());
                          // Get.to(
                          //   IncomingCallScreen(
                          //     callerId: currentUser?.displayName ?? 'Caller',
                          //     channelId: chatController.getChatRoomId(
                          //       currentUser?.uid ?? '',
                          //       'otherUserId', // Replace with actual user ID
                          //     ),
                          //   ),
                          // );
                        },
                        child: Text(
                          'Hired',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 34,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      leading: GestureDetector(
                        onTap: () => _showProfileSheet(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                CupertinoColors.systemBlue,
                                CupertinoColors.systemPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            child: Image.file(
                              File(basicController.savedFilePath.value),
                            ),
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => ChatListScreen()),
                            child: Container(
                              width: 37,
                              height: 37,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(
                                CupertinoIcons.chat_bubble_2,
                                color: CupertinoColors.systemBlue,
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search bar section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CupertinoSearchTextField(
                                controller: homeController.searchController,
                                onTap: () {
                                  setState(() {
                                    homeController.isSearching = true;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty &&
                                      !homeController.searchHistory.contains(
                                        value,
                                      )) {
                                    setState(() {
                                      homeController.searchHistory.insert(
                                        0,
                                        value,
                                      );
                                    });
                                  }
                                },
                                onSuffixTap: () {
                                  setState(() {
                                    homeController.isSearching = false;
                                    homeController.searchController.clear();
                                  });
                                },
                                backgroundColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                placeholder: 'Search jobs...',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.label,
                                ),
                                placeholderStyle: const TextStyle(
                                  color: CupertinoColors.placeholderText,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            if (homeController.isSearching) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Recent Searches',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...homeController.searchHistory.map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item),
                                  trailing: const Icon(CupertinoIcons.time),
                                  onTap: () {
                                    setState(() {
                                      homeController.searchController.text =
                                          item;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Posts section
                    SliverToBoxAdapter(
                      child: StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection('post')
                                .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.active) {
                            if (snap.hasData) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: snap.data!.docs.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  var post = snap.data!.docs[index];
                                  final String postId = post.id;
                                  final int likeCount = post['likes'] ?? 0;
                                  final List<dynamic> likedBy =
                                      post['likedBy'] ?? [];
                                  bool isLiked = likedBy.contains(
                                    currentUser?.uid,
                                  );

                                  return _buildPostCard(
                                    context,
                                    post,
                                    postId,
                                    likeCount,
                                    isLiked,
                                  );
                                },
                              );
                            } else if (snap.hasError) {
                              return _buildErrorState(snap.error.toString());
                            } else {
                              return _buildEmptyState();
                            }
                          } else {
                            return _buildLoadingState();
                          }
                        },
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              )
              : _buildNoInternetState(),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    QueryDocumentSnapshot post,
    String postId,
    int likeCount,
    bool isLiked,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemTeal,
                          CupertinoColors.systemBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['user'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Flutter Developer',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post['timestamp'] != null
                              ? timeago.format(
                                post['timestamp'].toDate(),
                                locale: 'short',
                              )
                              : 'No date',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleFollowRequest(post),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Description
            if (post['description'] != null &&
                post['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  post['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.label,
                    height: 1.4,
                  ),
                ),
              ),

            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNvbuFlaLcHBvBbA7faxcix1kzm1nu88A81Q&s',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.hand_thumbsup_fill,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$likeCount',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    CupertinoIcons.chat_bubble,
                    color: CupertinoColors.systemGrey,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => Text(
                      '${homeController.commentCount.value} ',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon:
                          isLiked
                              ? CupertinoIcons.hand_thumbsup_fill
                              : CupertinoIcons.hand_thumbsup,
                      label: 'Like',
                      isActive: isLiked,
                      onTap: () => _handleLike(postId, isLiked, currentUser),
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.chat_bubble,
                      label: 'Comment',
                      onTap: () => showCommentBottomSheet(context, postId),
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.share,
                      label: 'Share',
                      onTap: () => Share.share('Check out this job: $post'),
                    ),
                    _buildActionButton(
                      icon: CupertinoIcons.paperplane,
                      label: 'Message',
                      onTap: () => _handleMessage(post),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? CupertinoColors.systemRed
                      : CupertinoColors.secondaryLabel,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive
                        ? CupertinoColors.systemRed
                        : CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CupertinoActivityIndicator(radius: 16),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new job posts',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: Get.height * 0.25,
            width: Get.width * 0.5,
            child: Lottie.asset('assets/animations/no_internet.json'),
          ),

          const SizedBox(height: 24),

          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          CupertinoButton(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              // Retry connection
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.refresh, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Fetch user document from Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // Extract name
      final name = doc.data()?['name'] ?? 'Profile';

      // Now show the action sheet with the name
      showCupertinoModalPopup(
        context: context,
        builder:
            (context) => CupertinoActionSheet(
              title: Text(
                obj?.get('name') ?? name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed('/profile');
                  },
                  child: const Text('View Profile'),
                ),

                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.to(SettingScreen());
                  },
                  child: const Text('Settings'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  },
                  isDestructiveAction: true,
                  child: const Text('Logout'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
      );
    } catch (e) {
      print("Error showing profile sheet: $e");
      // Optionally show fallback sheet
      showCupertinoModalPopup(
        context: context,
        builder:
            (context) => CupertinoActionSheet(
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.toNamed('/profile');
                  },
                  child: const Text('View Profile'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
      );
    }
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  homeController.logout();
                  Get.snackbar(
                    'Logout',
                    'You have been logged out',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
                isDestructiveAction: true,
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  //////////////////////
  Future<void> _handleLike(
    String postId,
    bool isLiked,
    User? currentUser,
  ) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print('Post with ID $postId not found.');
      return; // You can also show a snackbar or toast to the user here.
    }

    try {
      if (isLiked) {
        await docRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([currentUser?.uid]),
        });
      } else {
        await docRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([currentUser?.uid]),
        });
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }

  Future<void> _handleFollowRequest(QueryDocumentSnapshot post) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final fromUserId = currentUser?.uid;

    await connectionController.sendFollowRequest(
      fromUserId: fromUserId ?? '',
      toUserId: post['user'] ?? '',
    );

    Get.snackbar(
      'Follow Request Sent',
      'Your request has been sent',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      backgroundColor: CupertinoColors.systemGreen,
      colorText: CupertinoColors.white,
    );
  }

  void _handleMessage(QueryDocumentSnapshot post) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final postOwnerId = post['uid'];

    if (currentUserId == postOwnerId) {
      Get.snackbar(
        "Oops",
        "You can't message yourself",
        snackPosition: SnackPosition.TOP,
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
      return;
    }

    final chatRoomId = chatController.getChatRoomId(currentUserId, postOwnerId);
    Get.to(
      () => ChatsScreen(chatRoomId: chatRoomId, otherUserName: postOwnerId),
    );
  }

  void showCommentBottomSheet(BuildContext context, String currentPostId) {
    final TextEditingController commentController = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Material(
            color: Colors.transparent, // for smooth rounded corners
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: CupertinoColors.systemGrey2,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Comments list
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('comments')
                                .where('postId', isEqualTo: currentPostId)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }

                          final comments = snapshot.data!.docs;

                          if (comments.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.chat_bubble_2,
                                    size: 48,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Be the first to comment',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: comments.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final comment =
                                  comments[index].data()
                                      as Map<String, dynamic>;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          CupertinoColors.systemIndigo,
                                          CupertinoColors.systemPurple,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment['user'] ?? 'Anonymous',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              comment['timestamp'] != null
                                                  ? timeago.format(
                                                    comment['timestamp']
                                                        .toDate(),
                                                    locale: 'short',
                                                  )
                                                  : 'Now',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    CupertinoColors
                                                        .secondaryLabel,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment['comments'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Input section
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: CupertinoColors.separator,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 12,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                controller: commentController,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                placeholder: 'Add a comment...',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                maxLines: null,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                final comment = commentController.text.trim();
                                if (comment.isNotEmpty) {
                                  homeController.comments(
                                    comment,
                                    currentPostId,
                                  );
                                  commentController.clear();
                                  homeController.commentCount.value++;
                                }
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.systemBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.paperplane_fill,
                                  color: CupertinoColors.white,
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
              ),
            ),
          ),
    );
  }
}
