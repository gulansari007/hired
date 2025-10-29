import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final internetController = Get.put(InternetController());
  var obj = Hive.box('myBox');

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: Obx(
          () =>
              internetController.hasInternet.value
                  ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      slivers: [
                        // Custom App Bar
                        SliverAppBar(
                          expandedHeight: 120,
                          floating: false,
                          pinned: true,
                          elevation: 0,
                          backgroundColor:
                              CupertinoColors.systemGroupedBackground,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              'Profile',
                              style: TextStyle(
                                color: CupertinoColors.label,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
                            centerTitle: true,
                          ),
                        ),

                        // Profile Content
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Profile Picture Section
                              _buildProfilePictureSection(),

                              const SizedBox(height: 32),

                              // Profile Info Card
                              _buildProfileInfoCard(),

                              const SizedBox(height: 24),

                              // Action Buttons
                              _buildActionButtons(),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : _buildNoInternetView(),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Stack(
      children: [
        // Profile picture with shadow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: CupertinoColors.systemGrey5,
            child: CircleAvatar(
              radius: 58,
              backgroundImage: const AssetImage('assets/profile.jpg'),
              backgroundColor: CupertinoColors.systemGrey6,
            ),
          ),
        ),

        // Edit button overlay
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              shape: BoxShape.circle,
              border: Border.all(
                color: CupertinoColors.systemGroupedBackground,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Handle profile picture edit
                _showEditOptions();
              },
              icon: const Icon(
                CupertinoIcons.camera_fill,
                color: Colors.white,
                size: 18,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name
          Text(
            obj.get('name'),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            FirebaseAuth.instance.currentUser?.email ?? 'No Email',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 20),

          // Stats Row (Optional - you can add user stats)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Applications', '12'),
              Container(width: 1, height: 40, color: CupertinoColors.separator),
              _buildStatItem('Interviews', '5'),
              Container(width: 1, height: 40, color: CupertinoColors.separator),
              _buildStatItem('Offers', '2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Edit Profile Button
          Container(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.zero,
              onPressed: () {
                // Handle Edit Profile
                _handleEditProfile();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.person_crop_circle_badge_checkmark,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Logout Button
          Container(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.zero,
              onPressed: () {
                // Handle Logout
                _showLogoutDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.square_arrow_right,
                    color: CupertinoColors.systemRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemRed,
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

  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
            color: CupertinoColors.systemBlue,
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

  void _showEditOptions() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: Text('Change Profile Picture'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  // Handle camera
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera, size: 20),
                    SizedBox(width: 8),
                    Text('Take Photo'),
                  ],
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  // Handle gallery
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo, size: 20),
                    SizedBox(width: 8),
                    Text('Choose from Gallery'),
                  ],
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
          ),
    );
  }

  void _handleEditProfile() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Navigate to edit profile screen
    // Get.to(() => EditProfileScreen());
    print('Navigate to Edit Profile');
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () => Get.back(),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Logout'),
                onPressed: () {
                  Get.back();
                  // Handle logout logic
                  _handleLogout();
                },
              ),
            ],
          ),
    );
  }

  void _handleLogout() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Clear user data and navigate to login
    obj.clear();
    // Get.offAllNamed('/login');
    print('User logged out');
  }
}
