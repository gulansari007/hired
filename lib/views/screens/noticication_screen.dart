import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:hired/controllers/notificationController.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class NoticicationScreen extends StatefulWidget {
  const NoticicationScreen({super.key});

  @override
  State<NoticicationScreen> createState() => _NoticicationScreenState();
}

class _NoticicationScreenState extends State<NoticicationScreen>
    with TickerProviderStateMixin {
  final internetController = Get.find<InternetController>();
  final notificationController = Get.put(NotificationController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    notificationController.initFCM();
    notificationController.initLocalNotification();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  var obj = Hive.box('myBox');

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          internetController.hasInternet.value
              ? _buildNotificationScreen()
              : _buildNoInternetScreen(),
    );
  }

  Widget _buildNotificationScreen() {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // iOS-style Large Title App Bar
          SliverAppBar(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: 100,
            floating: false,
            pinned: true,

            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed:
                      () => notificationController.sendTestNotification(),
                  child: const Icon(
                    CupertinoIcons.add_circled,
                    color: CupertinoColors.systemBlue,
                    size: 24,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Notifications",
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),

          // Notification List
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Obx(() => _buildNotificationContent()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent() {
    if (notificationController.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.bell_fill,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${notificationController.notifications.length} Notifications",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  "Recent",
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),

          // Notification Items
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notificationController.notifications.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: CupertinoColors.separator.resolveFrom(context),
                    indent: 60,
                  ),
              itemBuilder: (context, index) => _buildNotificationItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.app_fill,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Hired",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "now",
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notificationController.notifications[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Unread indicator
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 8, top: 4),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBlue,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.bell_slash,
              size: 40,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Notifications",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When you receive notifications, they'll appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => notificationController.sendTestNotification(),
            borderRadius: BorderRadius.circular(12),
            child: const Text(
              "Send Test Notification",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: Get.height * 0.2,
                width: Get.width * 0.4,
                child: Lottie.asset('assets/animations/no_internet.json'),
              ),
              const SizedBox(height: 24),
              Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please check your connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  // Add retry logic here
                },
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  "Try Again",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
