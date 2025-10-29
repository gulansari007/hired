import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/internetController.dart';
import 'package:hired/controllers/postController.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final postController = Get.put(PostController());
  final User? user = FirebaseAuth.instance.currentUser;
  final internetController = Get.find<InternetController>();
  Box? obj;

  @override
  void initState() {
    obj = Hive.box('myBox');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const CupertinoPageScaffold(
        child: Center(
          child: Text(
            'No user is logged in',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
      );
    }

    return Obx(
      () =>
          internetController.hasInternet.value
              ? CupertinoPageScaffold(
                backgroundColor: CupertinoColors.systemGroupedBackground,
                navigationBar: CupertinoNavigationBar(
                  backgroundColor: CupertinoColors.systemBackground.withOpacity(
                    0.9,
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image:
                                obj?.get('profileImage') ??
                                const NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNvbuFlaLcHBvBbA7faxcix1kzm1nu88A81Q&s',
                                ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        obj?.get('name') ?? 'User',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),

                  trailing: Obx(
                    () => CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed:
                          (postController.postText.value.isNotEmpty ||
                                  postController.mediaFile.value != null)
                              ? () {
                                postController.uploadPost(
                                  postController.postTextController.text
                                      .toString(),
                                  user!.uid,
                                );
                                postController.postTextController.clear();
                                Get.back();
                              }
                              : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (postController.postText.value.isNotEmpty ||
                                      postController.mediaFile.value != null)
                                  ? Theme.of(context).primaryColor
                                  : CupertinoColors.systemGrey4,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color:
                                (postController.postText.value.isNotEmpty ||
                                        postController.mediaFile.value != null)
                                    ? CupertinoColors.white
                                    : CupertinoColors.systemGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Obx(() {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text input area
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CupertinoColors.systemGrey
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CupertinoTextField(
                                      controller:
                                          postController.postTextController,
                                      maxLines: null,
                                      minLines: 4,
                                      placeholder: "What's on your mind?",
                                      placeholderStyle: const TextStyle(
                                        fontSize: 17,
                                        color: CupertinoColors.placeholderText,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: CupertinoColors.label,
                                      ),
                                      decoration: null,
                                      onChanged:
                                          (text) =>
                                              postController.postText.value =
                                                  text,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Media preview
                                  if (postController.mediaFile.value !=
                                      null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.systemGrey
                                                .withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                postController.isVideo.value
                                                    ? 'Video'
                                                    : 'Photo',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: CupertinoColors.label,
                                                ),
                                              ),
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  postController.removeMedia();
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            CupertinoColors
                                                                .systemGrey4,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    CupertinoIcons.xmark,
                                                    size: 16,
                                                    color:
                                                        CupertinoColors
                                                            .systemGrey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color:
                                                  CupertinoColors.systemGrey6,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child:
                                                  postController.isVideo.value
                                                      ? (postController
                                                                  .videoController
                                                                  ?.value
                                                                  .isInitialized ??
                                                              false)
                                                          ? VideoPlayer(
                                                            postController
                                                                .videoController!,
                                                          )
                                                          : const Center(
                                                            child:
                                                                CupertinoActivityIndicator(),
                                                          )
                                                      : Image.file(
                                                        postController
                                                            .mediaFile
                                                            .value!,
                                                        fit: BoxFit.cover,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }),
                          ),
                        ),
                      ),

                      // Bottom toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          border: Border(
                            top: BorderSide(
                              color: CupertinoColors.separator,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.all(12),
                              onPressed: () {
                                postController.pickImage();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  CupertinoIcons.photo,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CupertinoButton(
                              padding: const EdgeInsets.all(12),
                              onPressed: () {
                                postController.pickVideo();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  CupertinoIcons.videocam_fill,
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${postController.postText.value.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : CupertinoPageScaffold(
                backgroundColor: CupertinoColors.systemGroupedBackground,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: Get.height * 0.3,
                        width: Get.width * 0.5,
                        child: Lottie.asset(
                          'assets/animations/no_internet.json',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your connection and try again',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.secondaryLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
