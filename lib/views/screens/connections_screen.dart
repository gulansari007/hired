import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/connectionController.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:lottie/lottie.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final connectionController = Get.put(ConnectionController());
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final internetController = Get.find<InternetController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          internetController.hasInternet.value
              ? CupertinoPageScaffold(
                backgroundColor: CupertinoColors.systemGroupedBackground,
                navigationBar: const CupertinoNavigationBar(
                  backgroundColor: CupertinoColors.systemBackground,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Follow Requests Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Text(
                            'Follow Requests',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildFollowRequestsSection()),

                      // Connections Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                          child: Text(
                            'Your Connections',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildConnectionsSection()),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
              )
              : Center(
                child: Container(
                  height: Get.height * 0.3,
                  width: Get.width * 0.5,

                  child: Lottie.asset('assets/animations/no_internet.json'),
                ),
              ),
    );
  }

  Widget _buildFollowRequestsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('follow_requests')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.person_add,
            title: 'No Follow Requests',
            subtitle:
                'When someone requests to follow you,\nthey\'ll appear here.',
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 60,
                    color: CupertinoColors.separator,
                  ),
              itemBuilder: (context, index) {
                final request = requests[index];
                final fromUserId = request.id;

                return _buildFollowRequestTile(fromUserId);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('connections')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final connections = snapshot.data!.docs;

        if (connections.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.person_2,
            title: 'No Connections Yet',
            subtitle: 'Start connecting with people to see\nthem appear here.',
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: connections.length,
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 60,
                    color: CupertinoColors.separator,
                  ),
              itemBuilder: (context, index) {
                final connection = connections[index];
                final connectedUserId = connection.id;

                return _buildConnectionTile(connectedUserId);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowRequestTile(String fromUserId) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                CupertinoIcons.person_circle,
                size: 44,
                color: CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'User ID: ${fromUserId.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Accept Button
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(20),
              minSize: 0,
              onPressed: () async {
                await connectionController.acceptFollowRequest(
                  fromUserId: fromUserId,
                  toUserId: currentUserId,
                );
              },
              child: const Text(
                'Accept',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionTile(String connectedUserId) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                CupertinoIcons.person_circle_fill,
                size: 44,
                color: CupertinoColors.systemGreen,
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'User ID: ${connectedUserId.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Unfollow Button
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(20),
              minSize: 0,
              onPressed: () async {
                // Show confirmation dialog
                showCupertinoDialog(
                  context: context,
                  builder:
                      (context) => CupertinoAlertDialog(
                        title: const Text('Unfollow User'),
                        content: const Text(
                          'Are you sure you want to unfollow this user?',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('Unfollow'),
                            onPressed: () async {
                              Navigator.pop(context);
                              await connectionController.unfollowUser(
                                currentUserId: currentUserId,
                                unfollowUserId: connectedUserId,
                              );
                            },
                          ),
                        ],
                      ),
                );
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
