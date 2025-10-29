import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class PostController extends GetxController {
  final postText = ''.obs;
  final mediaFile = Rxn<File>();
  final isVideo = false.obs;
  VideoPlayerController? videoController;
  final obj = Hive.box('myBox'); // Assuming you have a Hive box named 'myBox'

  final picker = ImagePicker();
  final TextEditingController postTextController = TextEditingController();
  final FocusNode postFocusNode = FocusNode();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      mediaFile.value = File(picked.path);
      isVideo.value = false;
      disposeVideo();
    }
  }

  Future<void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      mediaFile.value = File(picked.path);
      isVideo.value = true;
      initVideoPlayer(File(picked.path));
    }
  }

  void initVideoPlayer(File file) {
    videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        videoController?.play();
        update();
      });
  }

  void disposeVideo() {
    videoController?.dispose();
    videoController = null;
  }

  // void submitPost() {
  //   if (postText.value.isEmpty && mediaFile.value == null) {
  //     Get.snackbar("Empty Post", "Write something or add media!");
  //     return;
  //   }
  // Here you would call your API or save post
  //   Get.snackbar("Posted", "Your post has been submitted!");
  //   postText.value = '';
  //   mediaFile.value = null;
  //   isVideo.value = false;
  //   disposeVideo();
  // }

  @override
  void onClose() {
    disposeVideo();
    super.onClose();
  }

  // Method to remove media from the post
  void removeMedia() {
    mediaFile.value = null;
    isVideo.value = false;
    disposeVideo();
  }

  // post

  uploadPost(String desc, postId) async {
    if (desc.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "No user is logged in");
      return;
    }

    try {
      final postData = {
        'description': desc,
        'timestamp': FieldValue.serverTimestamp(),

        'user': obj.get('name') ?? 'Anonymous',
        'phone': obj.get('phone') ?? '',
        'userImage': user.photoURL ?? '',
        'uid': user.uid,
        'likes': 0,
        'likedBy': [],
        'postid': postId,
      };

      await FirebaseFirestore.instance
          .collection('post')
          .add(postData); // use `.add()` for auto-generated ID

      Get.snackbar("Success", "Post uploaded successfully");
      Get.back();
    } catch (error) {
      Get.snackbar("Error", "Failed to upload post: $error");
    }
  }

  //firebase methods can be added here for saving posts
  // uploadPost(String desc) async {
  //   if (desc == '' || desc.isEmpty) {
  //     Get.snackbar("Error", "Description cannot be empty");
  //   } else {
  //     FirebaseFirestore.instance
  //         .collection('post')
  //         .doc(desc)
  //         .set({
  //           'description': desc,
  //           // 'mediaUrl': mediaFile.value != null ? mediaFile.value!.path : null,
  //           // 'isVideo': isVideo.value,
  //           'timestamp': FieldValue.serverTimestamp(),
  //         })
  //         .then((value) {
  //           Get.snackbar("Success", "Post uploaded successfully");
  //           Get.back();
  //           // postText.value = '';
  //           // mediaFile.value = null;
  //           // isVideo.value = false;
  //           // disposeVideo();
  //           // Navigate back after successful upload
  //         })
  //         .catchError((error) {
  //           Get.snackbar("Error", "Failed to upload post: $error");
  //         });
  //   }
  // }
}
